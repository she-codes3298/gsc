import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class AIChatbotScreen extends StatefulWidget {
  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  late final Gemini _gemini;
  final ChatUser _user = ChatUser(id: '1', firstName: 'User');
  final ChatUser _bot = ChatUser(id: '2', firstName: 'E-sahyog');
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _gemini = Gemini.instance;
  }

  final List<String> _customPrompts = [
    "How can we coordinate emergency response for an earthquake?",
    "What steps should be taken to manage flood-affected areas?",
    "How do we set up emergency shelters for cyclone victims?",
    "What protocols should be followed for issuing an SOS alert?",
    "How can we update the database of active refugee centers?",
    "What are the best practices for maintaining medical records of displaced individuals?",
    "How do we distribute essential supplies during a disaster?",
    "What are the guidelines for deploying rescue teams?",
    "How can we track real-time disaster reports from different regions?",
    "How do we ensure proper communication between central and state emergency teams?",
  ];

  bool _showPrompts = true;

  void _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _showPrompts = false;
    });

    try {
      final response = await _gemini.text(message.text);
      if (response != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _bot,
              text: response.output!,
              createdAt: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _bot,
            text: 'Error: Failed to fetch response.',
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  void _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _user,
            createdAt: DateTime.now(),
            medias: [
              ChatMedia(
                url: image.path,
                fileName: "image.jpg",
                type: MediaType.image,
              ),
            ],
          ),
        );
      });

      try {
        final response = await _gemini.text(
          'Describe this image: $base64Image',
        );
        if (response != null) {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                user: _bot,
                text: response.output!,
                createdAt: DateTime.now(),
              ),
            );
          });
        }
      } catch (e) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _bot,
              text: 'Error: Failed to process image.',
              createdAt: DateTime.now(),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Sahyog', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: DashChat(
                  currentUser: _user,
                  messages: _messages,
                  messageOptions: MessageOptions(
                    containerColor: const Color.fromARGB(255, 66, 66, 66),
                    textColor: Colors.white,
                  ),
                  inputOptions: InputOptions(
                    inputTextStyle: TextStyle(color: Colors.white),
                    inputDecoration: InputDecoration(
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    trailing: [
                      IconButton(
                        icon: Icon(Icons.image, color: Colors.white),
                        onPressed: _sendImage,
                      ),
                    ],
                  ),
                  onSend: (ChatMessage message) {
                    _sendMessage(message);
                  },
                ),
              ),
            ],
          ),
          if (_showPrompts)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _customPrompts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          _sendMessage(
                            ChatMessage(
                              user: _user,
                              text: _customPrompts[index],
                              createdAt: DateTime.now(),
                            ),
                          );
                        },
                        child: Text(
                          _customPrompts[index],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
