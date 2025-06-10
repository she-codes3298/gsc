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
        SnackBar(content: TranslatableText("Vendor registered successfully!")),
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
        SnackBar(content: TranslatableText("Error registering vendor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatableText("Register Vendor"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Vendor Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vendor name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _itemsController,
                decoration: InputDecoration(
                  labelText: "Supplied Items (comma separated)",
                  border: OutlineInputBorder(),
                  helperText: "e.g., Water Bottles, Food Packets, Medical Kits",
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplied items';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: registerVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: TranslatableText(
                  "Register Vendor",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
