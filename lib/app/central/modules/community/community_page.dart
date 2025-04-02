import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gsc/app/central/common/translatable_text.dart';


class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  File? image;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatableText("Community Announcements"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: TranslatableText("No posts available"));
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
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: TranslatableText("Create a Post"),
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
                    image != null ? Image.file(image!, height: 100) : TranslatableText("No image selected"),
                    TextButton(
                      onPressed: () async {
                        await pickImage();
                        setState(() {});
                      },
                      child: TranslatableText("Select Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      image = null;
                    });
                    Navigator.pop(context);
                  },
                  child: TranslatableText("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String? imageUrl;
                    if (image != null) {
                      imageUrl = await _uploadImage(image!);
                    }
                    _addPost(titleController.text, contentController.text, imageUrl);
                    setState(() {
                      image = null;
                    });
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: TranslatableText("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('Posts/$fileName.jpg');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null; // Return null instead of an empty string
    }
  }

  void _addPost(String title, String content, String? imageUrl) {
    FirebaseFirestore.instance.collection('Posts').add({
      'title': title,
      'content': content,
      'postedBy': _auth.currentUser?.email ?? "Unknown",
      'author': _auth.currentUser?.displayName ?? "Unknown", // Author field added
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'imageUrl': imageUrl ?? "",
    });
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final isGovernmentUser = _auth.currentUser?.email?.endsWith("@gmail.com") ?? false;

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
                TranslatableText(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isGovernmentUser)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(post.id, post['imageUrl']),
                  ),
              ],
            ),
            SizedBox(height: 8),
            TranslatableText(post['content']),
            if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
              Image.network(post['imageUrl'], height: 150, width: double.infinity, fit: BoxFit.cover),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () => _likePost(post.id),
                ),
                TranslatableText(post['likes'].toString()),
              ],
            ),
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

  void _deletePost(String postId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Posts').doc(postId).delete();

      // Delete image from Firebase Storage if it exists
      if (imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      debugPrint("Error deleting post: $e");
    }
  }
}
