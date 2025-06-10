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
          backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the add item dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: isAvailable ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const TranslatableText('Add New Item for Sale'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Emergency Water Bottles',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹) *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 150',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available Quantity *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 100',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Describe the item details...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Add Item', style: TextStyle(color: Colors.white)),
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
          title: const TranslatableText('Delete Item'),
          content: TranslatableText('Are you sure you want to delete "$itemName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                _deleteItem(docId, itemName);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText("Government E-commerce Management"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const TranslatableText('About'),
                  content: const TranslatableText(
                      'Manage items that government wants to sell to citizens. These items will be visible to users in the public marketplace app.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card with Real-time Data
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection(_collectionName).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  child: const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
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

              return Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const TranslatableText(
                              'Total Items',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TranslatableText(
                              '${items.length}',
                              style: const TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const TranslatableText(
                              'Available',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TranslatableText(
                              '$availableItems',
                              style: const TextStyle(fontSize: 24, color: Colors.green),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const TranslatableText(
                              'Total Stock',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TranslatableText(
                              '$totalStock',
                              style: const TextStyle(fontSize: 24, color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Items List with Real-time Updates
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(_collectionName)

                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        TranslatableText('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        TranslatableText(
                          'No items added yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        TranslatableText(
                          'Tap the + button to add your first item',
                          style: TextStyle(color: Colors.grey),
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
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAvailable ? Colors.blueGrey : Colors.grey,
                          child: Text(
                            (item['name'] ?? 'N')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: TranslatableText(
                          item['name'] ?? 'Unknown Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isAvailable ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatableText('Category: ${item['category'] ?? 'N/A'}'),
                            TranslatableText('Price: ₹${item['price'] ?? 0}'),
                            TranslatableText('Stock: ${item['quantity'] ?? 0} units'),
                            if ((item['description'] ?? '').isNotEmpty &&
                                item['description'] != 'No description available')
                              TranslatableText('${item['description']}'),
                            Row(
                              children: [
                                Icon(
                                  isAvailable ? Icons.check_circle : Icons.cancel,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                TranslatableText(
                                  isAvailable ? 'Available' : 'Unavailable',
                                  style: TextStyle(
                                    color: isAvailable ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isAvailable ? Icons.visibility_off : Icons.visibility,
                                color: isAvailable ? Colors.orange : Colors.green,
                              ),
                              onPressed: () => _updateItemAvailability(doc.id, !isAvailable),
                              tooltip: isAvailable ? 'Mark as Unavailable' : 'Mark as Available',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(
                                doc.id,
                                item['name'] ?? 'Unknown Item',
                              ),
                              tooltip: 'Delete Item',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showAddItemDialog,
        backgroundColor: _isLoading ? Colors.grey : Colors.green,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}