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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatableText(
          "Community Announcements",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180),
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF4682B4),
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3789BB)),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: TranslatableText(
                  "No posts available",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index];
                return PostCard(post: post, context: context);
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showAddPostDialog(context),
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFF3789BB),
          tooltip: 'Add Post',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddPostDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    File? dialogImage;

    Future<void> pickImage() async {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (pickedFile != null) {
          dialogImage = File(pickedFile.path);
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting image. Please try again.")),
        );
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: TranslatableText(
                "Create a Post",
                style: TextStyle(
                  color: Color(0xFF1A324C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Enter post title...",
                        labelText: "Title",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3789BB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3789BB), width: 2),
                        ),
                      ),
                      maxLength: 100,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Write your post content...",
                        labelText: "Content",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3789BB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3789BB), width: 2),
                        ),
                      ),
                      maxLength: 500,
                    ),
                    SizedBox(height: 16),
                    dialogImage != null
                        ? Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF3789BB), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          dialogImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.grey, size: 40),
                            SizedBox(height: 8),
                            TranslatableText(
                              "No image selected",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await pickImage();
                              setState(() {});
                            },
                            icon: Icon(Icons.image, color: Colors.white),
                            label: TranslatableText(
                              dialogImage != null ? "Change Image" : "Select Image",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3789BB),
                            ),
                          ),
                        ),
                        if (dialogImage != null) ...[
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                dialogImage = null;
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: "Remove Image",
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: TranslatableText(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: titleController.text.trim().isEmpty || contentController.text.trim().isEmpty
                      ? null
                      : () async {
                    // Validate inputs
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a title")),
                      );
                      return;
                    }
                    if (contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter content")),
                      );
                      return;
                    }

                    // Show loading indicator with different message if image exists
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3789BB)),
                                ),
                                SizedBox(height: 16),
                                Text(dialogImage != null ? "Publishing post with image..." : "Publishing post..."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    try {
                      String? imageUrl;
                      bool imageUploadFailed = false;

                      // Try to upload image if it exists
                      if (dialogImage != null) {
                        try {
                          debugPrint("Attempting to upload image...");
                          imageUrl = await _uploadImage(dialogImage!);
                          debugPrint("Image upload completed. URL: $imageUrl");
                        } catch (e) {
                          debugPrint("Image upload failed: $e");
                          imageUploadFailed = true;
                          // Don't throw the error, just log it and continue without image
                        }
                      }

                      // Create post regardless of image upload success
                      debugPrint("Creating post...");
                      await _addPost(
                        titleController.text.trim(),
                        contentController.text.trim(),
                        imageUrl, // This will be null if upload failed
                      );

                      // Close dialogs
                      if (mounted) Navigator.pop(context); // Close loading
                      if (mounted) Navigator.pop(context); // Close post dialog

                      // Show success message with appropriate text
                      if (mounted) {
                        String successMessage = "Post published successfully!";
                        if (imageUploadFailed && dialogImage != null) {
                          successMessage = "Post published successfully! (Image could not be uploaded)";
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(successMessage),
                            backgroundColor: imageUploadFailed ? Colors.orange : Colors.green,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint("Post creation error: $e");
                      // Close loading dialog
                      if (mounted) Navigator.pop(context);

                      // Show error message for post creation failure
                      if (mounted) {
                        String errorMessage = "Failed to create post. Please try again.";

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                            action: SnackBarAction(
                              label: 'Retry',
                              textColor: Colors.white,
                              onPressed: () {
                                // Close current dialog and retry
                                Navigator.pop(context);
                                _showAddPostDialog(context);
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3789BB),
                  ),
                  child: TranslatableText(
                    "Post",
                    style: TextStyle(color: Colors.white),
                  ),
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
      debugPrint("Starting image upload...");

      // Check authentication first
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }
      debugPrint("Current user: ${currentUser.email}");

      // Check if file exists and is readable
      if (!await image.exists()) {
        debugPrint("Image file does not exist");
        throw Exception("Image file not found");
      }

      // Check file size (limit to 5MB)
      int fileSizeInBytes = await image.length();
      debugPrint("Image size: ${fileSizeInBytes / (1024 * 1024)} MB");

      if (fileSizeInBytes > 5 * 1024 * 1024) {
        throw Exception("Image too large. Please select an image smaller than 5MB");
      }

      String fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child('Posts/$fileName');

      debugPrint("Uploading to path: Posts/$fileName");

      // Create upload task with metadata
      UploadTask uploadTask = storageReference.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=3600',
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      debugPrint("Image uploaded successfully. URL: $downloadURL");
      return downloadURL;

    } catch (e) {
      debugPrint("Detailed upload error: $e");
      debugPrint("Error type: ${e.runtimeType}");

      // Re-throw the error so it can be caught in the calling function
      throw e;
    }
  }

  Future<void> _addPost(String title, String content, String? imageUrl) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }

      await FirebaseFirestore.instance.collection('Posts').add({
        'title': title,
        'content': content,
        'postedBy': currentUser.email ?? "Unknown",
        'author': currentUser.displayName ?? currentUser.email?.split('@')[0] ?? "Unknown",
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'imageUrl': imageUrl ?? "", // Will be empty string if image upload failed
      });
    } catch (e) {
      debugPrint("Error adding post: $e");
      throw Exception("Failed to create post");
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
    final currentUser = _auth.currentUser;
    final isOwner = currentUser?.email == post['postedBy'];
    final isAdmin = currentUser?.email?.contains('admin') ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.95),
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
                    post['title'] ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),
                ),
                if (isOwner || isAdmin)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Color(0xFF1A324C)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                        value: 'delete',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deletePost(post.id, post['imageUrl'] ?? '');
                      }
                    },
                  ),
              ],
            ),
            SizedBox(height: 8),
            TranslatableText(
              post['content'] ?? '',
              style: TextStyle(
                color: Color(0xFF1A324C).withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  width: double.infinity,
                  child: Image.network(
                    post['imageUrl'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3789BB)),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              Text("Image failed to load", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "By: ${post['author'] ?? 'Unknown'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A324C).withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (post['timestamp'] != null)
                  Text(
                    _formatTimestamp(post['timestamp']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A324C).withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: Color(0xFF3789BB),
                  ),
                  onPressed: () => _likePost(post.id),
                ),
                TranslatableText(
                  (post['likes'] ?? 0).toString(),
                  style: TextStyle(
                    color: Color(0xFF3789BB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  "Tap 👍 to like",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A324C).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  void _likePost(String postId) {
    FirebaseFirestore.instance.collection('Posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  void _deletePost(String postId, String imageUrl) async {
    try {
      bool confirmDelete = await _showDeleteConfirmation(context);
      if (!confirmDelete) return;

      await FirebaseFirestore.instance.collection('Posts').doc(postId).delete();

      if (imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (e) {
          debugPrint("Error deleting image: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Post deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error deleting post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting post. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    bool result = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Delete",
            style: TextStyle(
              color: Color(0xFF1A324C),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this post? This action cannot be undone.",
            style: TextStyle(color: Color(0xFF1A324C)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }
}