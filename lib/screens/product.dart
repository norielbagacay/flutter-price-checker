import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../data/database_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Product {
  final int? id;
  final String name;
  final String barcode;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.barcode,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      price: (map['price'] as num).toDouble(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  List<Product> _products = [];
  List<Product> _allProducts = [];
  
  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts() async {
    final data = await dbHelper.getAllProducts();
    setState(() {
      _allProducts = data.map((e) => Product.fromMap(e)).toList();
      _currentPage = 0;
      _hasMoreData = true;
      _products = _allProducts.take(_itemsPerPage).toList();
    });
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // Smooth loading effect

    setState(() {
      _currentPage++;
      final startIndex = _currentPage * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      
      if (startIndex < _allProducts.length) {
        final newProducts = _allProducts.skip(startIndex).take(_itemsPerPage).toList();
        _products.addAll(newProducts);
        
        if (endIndex >= _allProducts.length) {
          _hasMoreData = false;
        }
      } else {
        _hasMoreData = false;
      }
      
      _isLoadingMore = false;
    });
  }

  Future<void> _addProduct(Product product) async {
    await dbHelper.insertProduct(product.toMap());
    await _loadProducts();
  }

  Future<void> _updateProduct(Product product) async {
    await dbHelper.updateProduct(product.id!, product.toMap());
    await _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    await dbHelper.deleteProduct(product.id!);
    await _loadProducts();
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      await _loadProducts();
      return;
    }
    final data = await dbHelper.searchProducts(query);
    setState(() {
      _allProducts = data.map((e) => Product.fromMap(e)).toList();
      _currentPage = 0;
      _hasMoreData = _allProducts.length > _itemsPerPage;
      _products = _allProducts.take(_itemsPerPage).toList();
    });
  }

  void _showSuccessSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_shopping_cart, color: Colors.orange[700], size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add New Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(nameController, 'Product Name', Icons.inventory_2),
              const SizedBox(height: 16),
              _buildModernTextField(barcodeController, 'Barcode', FontAwesomeIcons.barcode),
              const SizedBox(height: 16),
              _buildModernTextField(priceController, 'Price', FontAwesomeIcons.pesoSign, isNumber: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final price = double.tryParse(priceController.text);
                      if (price == null || nameController.text.isEmpty) return;
                      await _addProduct(Product(
                        name: nameController.text,
                        barcode: barcodeController.text,
                        price: price,
                      ));
                      Navigator.pop(context);
                      _showSuccessSnackBar('Product added successfully!', Icons.check_circle);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProductDialog(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final barcodeController = TextEditingController(text: product.barcode);
    final priceController = TextEditingController(text: product.price.toString());

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit, color: Colors.blue[700], size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Edit Product',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(nameController, 'Product Name', Icons.inventory_2),
              const SizedBox(height: 16),
              _buildModernTextField(barcodeController, 'Barcode', FontAwesomeIcons.barcode),
              const SizedBox(height: 16),
              _buildModernTextField(priceController, 'Price', FontAwesomeIcons.pesoSign, isNumber: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final price = double.tryParse(priceController.text);
                      if (price == null) return;
                      await _updateProduct(Product(
                        id: product.id,
                        name: nameController.text,
                        barcode: barcodeController.text,
                        price: price,
                      ));
                      Navigator.pop(context);
                      _showSuccessSnackBar('Product updated successfully!', Icons.check_circle);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: Colors.red[700], size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Product?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(product);
      _showSuccessSnackBar('Product deleted successfully!', Icons.check_circle);
    }
  }

  Future<void> _importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('No file selected'),
              ],
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      final file = File(result.files.single.path!);
      
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final bytes = await file.readAsBytes();
      
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      List<List<dynamic>> rows = [];
      final fileExtension = result.files.single.extension?.toLowerCase();

      if (fileExtension == 'csv') {
        try {
          final csvString = String.fromCharCodes(bytes);
          rows = const CsvToListConverter().convert(csvString);
          
          if (rows.isEmpty) {
            throw Exception('CSV file is empty');
          }
        } catch (e) {
          throw Exception('Invalid CSV file format: ${e.toString()}');
        }
      } else {
        Excel excel;
        try {
          excel = Excel.decodeBytes(bytes);
        } catch (e) {
          throw Exception('Invalid Excel file format. Please ensure it\'s a valid .xlsx file');
        }

        if (excel.tables.isEmpty) {
          throw Exception('Excel file has no sheets');
        }

        final sheet = excel.tables.keys.first;
        final table = excel.tables[sheet];
        
        if (table == null || table.rows.isEmpty) {
          throw Exception('Excel sheet is empty');
        }

        rows = table.rows.map((row) {
          return row.map((cell) => cell?.value).toList();
        }).toList();
      }

      // Show progress dialog
      final totalRows = rows.length - 1; // Exclude header
      int processedRows = 0;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, size: 48, color: Colors.orange[700]),
                  const SizedBox(height: 16),
                  const Text(
                    'Importing Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: totalRows > 0 ? processedRows / totalRows : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$processedRows of $totalRows products',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      int importedCount = 0;
      int skippedCount = 0;
      int duplicateCount = 0;

      // Get all existing products for duplicate checking
      final existingProducts = await dbHelper.getAllProducts();
      final existingProductsMap = <String, Map<String, dynamic>>{};
      
      for (var productMap in existingProducts) {
        final name = productMap['name']?.toString().toLowerCase().trim() ?? '';
        final barcode = productMap['barcode']?.toString().toLowerCase().trim() ?? '';
        final key = '$name|$barcode';
        existingProductsMap[key] = productMap;
      }

      // Prepare batch insert list
      List<Map<String, dynamic>> productsToInsert = [];
      
      for (var i = 1; i < rows.length; i++) {
        var row = rows[i];
        
        // Skip empty rows
        if (row.isEmpty || row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
          skippedCount++;
          processedRows++;
          continue;
        }

        try {
          final name = row.length > 0 && row[0] != null 
              ? row[0].toString().trim() 
              : '';
          final barcode = row.length > 1 && row[1] != null 
              ? row[1].toString().trim() 
              : '';
          final priceStr = row.length > 2 && row[2] != null 
              ? row[2].toString().trim() 
              : '0';

          // Validate required fields
          if (name.isEmpty) {
            skippedCount++;
            processedRows++;
            continue;
          }

          // Check for duplicates (case-insensitive)
          final key = '${name.toLowerCase()}|${barcode.toLowerCase()}';
          if (existingProductsMap.containsKey(key)) {
            duplicateCount++;
            processedRows++;
            continue;
          }

          final price = double.tryParse(priceStr) ?? 0.0;

          productsToInsert.add({
            'name': name,
            'barcode': barcode,
            'price': price,
          });
          
          // Add to map to prevent duplicates within the same import
          existingProductsMap[key] = {
            'name': name,
            'barcode': barcode,
            'price': price,
          };
          
          importedCount++;
        } catch (e) {
          skippedCount++;
          print('Error processing row $i: $e');
        }
        
        processedRows++;
        
        // Update progress every 10 rows or at the end
        if (processedRows % 10 == 0 || processedRows == totalRows) {
          // Use a microtask to update the dialog
          await Future.microtask(() {
            if (Navigator.canPop(context)) {
              // Force rebuild of dialog
              (context as Element).markNeedsBuild();
            }
          });
      }
    }

    // Batch insert all products
    if (productsToInsert.isNotEmpty) {
      await dbHelper.batchInsertProducts(productsToInsert);
    }
    
    await _loadProducts();

    Navigator.pop(context); // Dismiss progress dialog

    // Show detailed result message
    String message = 'Imported $importedCount product(s)';
    if (duplicateCount > 0) {
      message += '\n$duplicateCount duplicate(s) skipped';
    }
    if (skippedCount > 0) {
      message += '\n$skippedCount invalid row(s) skipped';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  } catch (e) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Error importing file: ${e.toString()}'),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

  Widget _buildModernTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[700],
        title: const Text('Products', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload, color: Colors.white),
            onPressed: _importFromExcel,
            tooltip: 'Import from Excel',
          ),
        ],

        
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchQuery = value;
                    _searchProducts(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _searchProducts('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product to get started',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length + (_isLoadingMore && _hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _products.length && _isLoadingMore) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                            ),
                          ),
                        );
                      }

                      final product = _products[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(FontAwesomeIcons.tag, color: Colors.orange[700]),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.barcode, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.barcode,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue[700], size: 20),
                                    onPressed: () => _showEditProductDialog(product),
                                    tooltip: 'Edit',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red[700], size: 20),
                                    onPressed: () => _showDeleteConfirmationDialog(product),
                                    tooltip: 'Delete',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}