import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import '../models/product.dart';

class ProductService {
  // Import products from Excel file
  static Future<List<Product>> importFromExcel(int currentMaxId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) return [];

      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      List<Product> importedProducts = [];
      int idCounter = currentMaxId + 1;

      for (var i = 1; i < rows.length; i++) {
        var row = rows[i];
        importedProducts.add(Product(
          id: idCounter++,
          name: row[0]?.value.toString() ?? '',
          brand: row[1]?.value.toString() ?? '',
          barcode: row[2]?.value.toString() ?? '',
          price: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
        ));
      }

      return importedProducts;
    } catch (e) {
      rethrow;
    }
  }

  // Filter products based on search query
  static List<Product> filterProducts(List<Product> products, String query) {
    if (query.isEmpty) return products;
    
    return products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.brand.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Validate product data
  static String? validateProductData({
    required String name,
    required String brand,
    required String barcode,
    required String price,
  }) {
    if (name.isEmpty || brand.isEmpty || barcode.isEmpty || price.isEmpty) {
      return 'Please fill all fields';
    }

    if (double.tryParse(price) == null) {
      return 'Invalid price';
    }

    return null;
  }
}