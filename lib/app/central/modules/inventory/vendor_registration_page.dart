import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:gsc/app/central/modules/inventory/inventory_update_page.dart';
import 'package:gsc/app/central/modules/inventory/inventory_request_page.dart';
import 'package:gsc/app/central/modules/inventory/inventory_page.dart';

class VendorRegistrationPage extends StatefulWidget {
  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemsController = TextEditingController();

  final CollectionReference vendorsCollection =
  FirebaseFirestore.instance.collection('vendors');

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> registerVendor() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      List<String> suppliedItems = _itemsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      await vendorsCollection.add({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'suppliedItems': suppliedItems,
        'isActive': true,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Vendor registered successfully!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _addressController.clear();
      _itemsController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Error registering vendor: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF1A324C),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            labelStyle: const TextStyle(
              color: Color(0xFF3789BB),
              fontWeight: FontWeight.w600,
            ),
            helperStyle: const TextStyle(
              color: Color(0xFF4682B4),
              fontSize: 12,
            ),
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF3789BB),
                width: 2,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF87CEEB).withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Register Vendor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C), // Match inventory page app bar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180), // -40 degrees in radians
            colors: [
              Color(0xFF87CEEB), // Sky Blue - lighter and more vibrant
              Color(0xFF4682B4), // Steel Blue - professional yet lighter
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3789BB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Color(0xFF3789BB),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatableText(
                                "Vendor Registration",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A324C),
                                ),
                              ),
                              SizedBox(height: 4),
                              TranslatableText(
                                "Register new vendors for inventory supply",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3789BB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                const TranslatableText(
                  "Vendor Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nameController,
                  label: "Vendor Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vendor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _contactController,
                  label: "Contact Number",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: "Business Address",
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _itemsController,
                  label: "Supplied Items",
                  maxLines: 3,
                  helperText: "e.g., Water Bottles, Food Packets, Medical Kits",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter supplied items';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3789BB), Color(0xFF1A324C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: registerVendor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const TranslatableText(
                        "Register Vendor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}