import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Community Announcements"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    return PostCard(post: post);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
        print("Image selected: ${image!.path}"); // Debug print
      } else {
        print("No image selected"); // Debug print
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Create a Post"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: "Title"),
                    ),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(hintText: "Content"),
                    ),
                    SizedBox(height: 16),
                    image != null
                        ? Image.file(image!, height: 100)
                        : Text("No image selected"),
                    TextButton(
                      onPressed: () async {
                        await pickImage();
                        setState(() {}); // Update UI
                      },
                      child: Text("Select Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      image = null; // Clear image
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String? imageUrl;
                    if (image != null) {
                      print("Uploading image..."); // Debug print
                      imageUrl = await _uploadImage(image!);
                      print("Image URL after upload: $imageUrl"); // Debug print
                    }
                    _addPost(
                      titleController.text,
                      contentController.text,
                      imageUrl,
                    );
                    setState(() {
                      image = null; // Reset image after posting
                    });
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _uploadImage(File image) async {
    try {
      print("Starting image upload..."); // Debug print
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
      FirebaseStorage.instance.ref().child('posts/$fileName.jpg');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      print("Image uploaded. URL: $downloadURL"); // Debug print
      return downloadURL;
    } catch (e) {
      debugPrint("Error uploading image: $e"); // Debug print
      return "";
    }
  }

  void _addPost(String title, String content, String? imageUrl) {
    print("Adding post with title: $title, content: $content, imageUrl: $imageUrl"); // Debug print
    FirebaseFirestore.instance.collection('Posts').add({
      'title': title,
      'content': content,
      'postedBy': FirebaseAuth.instance.currentUser!.email,
      'timestamp': DateTime.now(),
      'likes': 0,
      'imageUrl': imageUrl ?? "",
    }).then((_) {
      print("Post added successfully"); // Debug print
    }).catchError((error) {
      print("Failed to add post: $error"); // Debug print
    });
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGovernmentUser = FirebaseAuth.instance.currentUser?.email?.endsWith("@gov.in") ?? false;

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isGovernmentUser)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(post.id),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(post['content']),
            SizedBox(height: 8),
            if ((post.data() as Map<String, dynamic>).containsKey('imageUrl') && post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
              Image.network(post['imageUrl'], height: 150, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () => _likePost(post.id),
                ),
                Text(post['likes'].toString()),
              ],
            ),
            CommentSection(postId: post.id),
          ],
        ),
      ),
    );
  }

  void _likePost(String postId) {
    FirebaseFirestore.instance.collection('Posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  void _deletePost(String postId) {
    FirebaseFirestore.instance.collection('Posts').doc(postId).delete();
  }
}

class CommentSection extends StatelessWidget {
  final String postId;
  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        return Column(
          children: [
            ...snapshot.data!.docs.map((comment) {
              return ListTile(
                title: Text(comment['commentText']),
                subtitle: Text(comment['commentedBy']),
              );
            }),
            TextField(
              onSubmitted: (text) => _addComment(postId, text),
              decoration: InputDecoration(hintText: 'Add a comment...'),
            ),
          ],
        );
      },
    );
  }

  void _addComment(String postId, String text) {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .add({
      'commentText': text,
      'commentedBy': FirebaseAuth.instance.currentUser!.email,
      'timestamp': DateTime.now(),
    });
  }
}