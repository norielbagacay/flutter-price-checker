import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDialogs {
  // Show Add Product Dialog
  static Future<Product?> showAddProductDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final barcodeController = TextEditingController();
    final priceController = TextEditingController();

    return await showDialog<Product?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Product Name'),
                const SizedBox(height: 10),
                _buildTextField(brandController, 'Brand'),
                const SizedBox(height: 10),
                _buildTextField(barcodeController, 'Barcode'),
                const SizedBox(height: 10),
                _buildTextField(
                  priceController,
                  'Price',
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                final validationError = ProductService.validateProductData(
                  name: nameController.text,
                  brand: brandController.text,
                  barcode: barcodeController.text,
                  price: priceController.text,
                );

                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(validationError)),
                  );
                  return;
                }

                final product = Product(
                  id: 0, // Will be assigned by the calling code
                  name: nameController.text,
                  brand: brandController.text,
                  barcode: barcodeController.text,
                  price: double.parse(priceController.text),
                );

                Navigator.pop(context, product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show Edit Product Dialog
  static Future<Product?> showEditProductDialog(
    BuildContext context,
    Product product,
  ) async {
    final nameController = TextEditingController(text: product.name);
    final brandController = TextEditingController(text: product.brand);
    final barcodeController = TextEditingController(text: product.barcode);
    final priceController = TextEditingController(text: product.price.toString());

    return await showDialog<Product?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Product Name'),
                const SizedBox(height: 10),
                _buildTextField(brandController, 'Brand'),
                const SizedBox(height: 10),
                _buildTextField(barcodeController, 'Barcode'),
                const SizedBox(height: 10),
                _buildTextField(
                  priceController,
                  'Price',
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                final validationError = ProductService.validateProductData(
                  name: nameController.text,
                  brand: brandController.text,
                  barcode: barcodeController.text,
                  price: priceController.text,
                );

                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(validationError)),
                  );
                  return;
                }

                final updatedProduct = product.copyWith(
                  name: nameController.text,
                  brand: brandController.text,
                  barcode: barcodeController.text,
                  price: double.parse(priceController.text),
                );

                Navigator.pop(context, updatedProduct);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Show Delete Confirmation Dialog
  static Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Are you sure you want to delete "${product.name}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  // Helper method to build text fields
  static Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}