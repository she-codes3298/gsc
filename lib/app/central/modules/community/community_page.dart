import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:gsc/services/translation_service.dart';


class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Removed file from class level to avoid state persistence between dialogs
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
              return PostCard(post: post, context: context);
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
    // Create local image file variable for this dialog instance
    File? dialogImage;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        // Add image quality parameter to reduce file size and prevent overflow
        imageQuality: 85,
      );
      if (pickedFile != null) {
        // Update local dialog image, not class level image
        dialogImage = File(pickedFile.path);
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
                      maxLines: 5, // Allow multiple lines for content
                      decoration: InputDecoration(hintText: "Content"),
                    ),
                    SizedBox(height: 16),
                    dialogImage != null
                        ? Container(
                      height: 150,
                      width: double.infinity,
                      child: Image.file(
                        dialogImage!,
                        fit: BoxFit.contain,
                      ),
                    )
                        : TranslatableText("No image selected"),
                    TextButton(
                      onPressed: () async {
                        await pickImage();
                        setState(() {}); // Update dialog state
                      },
                      child: TranslatableText("Select Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: TranslatableText("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    // Show loading indicator while posting
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(child: CircularProgressIndicator()),
                    );

                    String? imageUrl;
                    if (dialogImage != null) {
                      imageUrl = await _uploadImage(dialogImage!);
                    }

                    await _addPost(titleController.text, contentController.text, imageUrl);

                    // Close loading dialog
                    if (mounted) Navigator.pop(context);
                    // Close post dialog
                    if (mounted) Navigator.pop(context);
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

      // Compress image before uploading to reduce file size
      UploadTask uploadTask = storageReference.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'picked-file-path': image.path,
          },
        ),
      );

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _addPost(String title, String content, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Posts').add({
        'title': title,
        'content': content,
        'postedBy': _auth.currentUser?.email ?? "Unknown",
        'author': _auth.currentUser?.displayName ?? "Unknown",
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'imageUrl': imageUrl ?? "",
      });
    } catch (e) {
      debugPrint("Error adding post: $e");
    }
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot post;
  final BuildContext context;

  const PostCard({
    Key? key,
    required this.post,
    required this.context,
  }) : super(key: key);

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
                Expanded(
                  child: TranslatableText(
                    post['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isGovernmentUser)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(post.id, post['imageUrl']),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // Wrap with Expanded to prevent overflow
            TranslatableText(post['content']),
            SizedBox(height: 12),
            if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 250, // Set maximum height
                  ),
                  width: double.infinity,
                  child: Image.network(
                    post['imageUrl'],
                    fit: BoxFit.contain, // Change to contain to prevent distortion
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Posted by: ${post['author'] ?? 'Unknown'}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
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
      // Show confirmation dialog
      bool confirmDelete = await _showDeleteConfirmation(context, postId);
      if (!confirmDelete) return;

      await FirebaseFirestore.instance.collection('Posts').doc(postId).delete();

      // Delete image from Firebase Storage if it exists
      if (imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      debugPrint("Error deleting post: $e");
    }
  }

  // Simplified delete confirmation dialog
  Future<bool> _showDeleteConfirmation(BuildContext context, String postId) async {
    bool result = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return result;
  }
}
