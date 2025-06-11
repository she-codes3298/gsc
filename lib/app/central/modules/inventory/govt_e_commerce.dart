import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class EcommercePage extends StatefulWidget {
  const EcommercePage({super.key});

  @override
  State<EcommercePage> createState() => _EcommercePageState();
}

class _EcommercePageState extends State<EcommercePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'government_marketplace_items';

  String _selectedCategory = 'Water & Food';
  final List<String> _categories = ['Water & Food', 'Medical', 'Electronics', 'Shelter', 'Tools', 'Clothing', 'Communication'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newItem = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'description': _descriptionController.text.trim().isEmpty
            ? 'No description available'
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionName).add(newItem);

      // Clear form
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: Color(0xFF3789BB),
          ),
        );
        Navigator.pop(context); // Close the add item dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(String docId, String itemName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection(_collectionName).doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemName deleted successfully!'),
            backgroundColor: const Color(0xFFF39C12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateItemAvailability(String docId, bool isAvailable) async {
    try {
      await _firestore.collection(_collectionName).doc(docId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAvailable ? 'Item marked as available' : 'Item marked as unavailable'),
            backgroundColor: isAvailable ? const Color(0xFF3789BB) : const Color(0xFFF39C12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF1A324C),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF3789BB),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF87CEEB),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF87CEEB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3789BB), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF87CEEB)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3789BB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Color(0xFF3789BB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const TranslatableText(
                      'Add New Item for Sale',
                      style: TextStyle(
                        color: Color(0xFF1A324C),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: _nameController,
                        label: 'Item Name *',
                        hint: 'e.g., Emergency Water Bottles',
                      ),
                      _buildDialogTextField(
                        controller: _priceController,
                        label: 'Price (₹) *',
                        hint: 'e.g., 150',
                        keyboardType: TextInputType.number,
                      ),
                      _buildDialogTextField(
                        controller: _quantityController,
                        label: 'Available Quantity *',
                        hint: 'e.g., 100',
                        keyboardType: TextInputType.number,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          style: const TextStyle(
                            color: Color(0xFF1A324C),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(
                              color: Color(0xFF3789BB),
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF3789BB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setDialogState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        ),
                      ),
                      _buildDialogTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Describe the item details...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF87CEEB)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3789BB), Color(0xFF1A324C)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Add Item', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(String docId, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE74C3C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const TranslatableText(
                'Delete Item',
                style: TextStyle(
                  color: Color(0xFF1A324C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TranslatableText(
            'Are you sure you want to delete "$itemName"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF1A324C)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF87CEEB)),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                _deleteItem(docId, itemName);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            TranslatableText(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A324C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            TranslatableText(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Government E-commerce Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C), // Match inventory page
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3789BB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF3789BB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const TranslatableText(
                        'About',
                        style: TextStyle(
                          color: Color(0xFF1A324C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const TranslatableText(
                    'Manage items that government wants to sell to citizens. These items will be visible to users in the public marketplace app.',
                    style: TextStyle(color: Color(0xFF1A324C)),
                  ),
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3789BB), Color(0xFF1A324C)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
        child: Column(
          children: [
            // Stats Section with Real-time Data
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection(_collectionName).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final items = snapshot.data!.docs;
                  final totalStock = items.fold(0, (sum, doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return sum + (data['quantity'] as int? ?? 0);
                  });
                  final availableItems = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isAvailable'] == true;
                  }).length;

                  return Row(
                    children: [
                      _buildStatsCard(
                        'Total Items',
                        '${items.length}',
                        const Color(0xFF3789BB),
                        Icons.store,
                      ),
                      const SizedBox(width: 12),
                      _buildStatsCard(
                        'Available',
                        '$availableItems',
                        const Color(0xFF27AE60),
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 12),
                      _buildStatsCard(
                        'Total Stock',
                        '$totalStock',
                        const Color(0xFFF39C12),
                        Icons.inventory,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const TranslatableText(
                  "Marketplace Items",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Items List with Real-time Updates
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection(_collectionName)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          TranslatableText(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          TranslatableText(
                            'No items added yet',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          TranslatableText(
                            'Tap the + button to add your first item',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final doc = items[index];
                      final item = doc.data() as Map<String, dynamic>;
                      final isAvailable = item['isAvailable'] ?? true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isAvailable
                                    ? [const Color(0xFF3789BB), const Color(0xFF1A324C)]
                                    : [Colors.grey, Colors.grey.shade600],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (item['name'] ?? 'N')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: TranslatableText(
                            item['name'] ?? 'Unknown Item',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A324C),
                              decoration: isAvailable ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 16, color: const Color(0xFF3789BB)),
                                  const SizedBox(width: 4),
                                  TranslatableText(
                                    '${item['category'] ?? 'N/A'}',
                                    style: const TextStyle(color: Color(0xFF3789BB)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee, size: 16, color: const Color(0xFF27AE60)),
                                  TranslatableText(
                                    '${item['price'] ?? 0}',
                                    style: const TextStyle(
                                      color: Color(0xFF27AE60),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.inventory, size: 16, color: const Color(0xFFF39C12)),
                                  const SizedBox(width: 4),
                                  TranslatableText(
                                    '${item['quantity'] ?? 0} units',
                                    style: const TextStyle(color: Color(0xFFF39C12)),
                                  ),
                                ],
                              ),
                              if ((item['description'] ?? '').isNotEmpty &&
                                  item['description'] != 'No description available')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TranslatableText(
                                    '${item['description']}',
                                    style: const TextStyle(
                                      color: Color(0xFF4682B4),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    isAvailable ? Icons.check_circle : Icons.cancel,
                                    color: isAvailable ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  TranslatableText(
                                    isAvailable ? 'Available' : 'Unavailable',
                                    style: TextStyle(
                                      color: isAvailable ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: (isAvailable ? const Color(0xFFF39C12) : const Color(0xFF27AE60)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isAvailable ? Icons.visibility_off : Icons.visibility,
                                    color: isAvailable ? const Color(0xFFF39C12) : const Color(0xFF27AE60),
                                  ),
                                  onPressed: () => _updateItemAvailability(doc.id, !isAvailable),
                                  tooltip: isAvailable ? 'Mark as Unavailable' : 'Mark as Available',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFE74C3C)),
                                  onPressed: () => _showDeleteConfirmation(
                                    doc.id,
                                    item['name'] ?? 'Unknown Item',
                                  ),
                                  tooltip: 'Delete Item',
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
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
        child: FloatingActionButton(
          onPressed: _isLoading ? null : _showAddItemDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}