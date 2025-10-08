import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'product.dart';
import 'about.dart';
import 'reset.dart';
import 'inventory.dart';
import '../data/database_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
  });
}

class PriceCheckerHome extends StatefulWidget {
  const PriceCheckerHome({Key? key}) : super(key: key);

  @override
  State<PriceCheckerHome> createState() => _PriceCheckerHomeState();
}

class _PriceCheckerHomeState extends State<PriceCheckerHome> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Product> _products = [];
  List<Product> _allProducts = [];
  
  // Pagination variables
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int? _selectedProductId;
  int _totalProductCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetAndLoadProducts();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _resetAndLoadProducts() async {
    setState(() {
      _currentPage = 0;
      _products = [];
      _allProducts = [];
      _hasMoreData = true;
    });
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final totalCount = await _dbHelper.totalProduct();
    final data = await _dbHelper.getAllProducts();
    setState(() {
      _totalProductCount = totalCount;
      _allProducts = data.map((e) => Product(
        id: e['id'] as int,
        name: e['name'] as String,
        price: (e['price'] as num).toDouble(),
        barcode: e['barcode'] as String,
      )).toList();
      _currentPage = 0;
      _hasMoreData = true;
      _products = _allProducts.take(_pageSize).toList();
    });
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      
      if (startIndex < _allProducts.length) {
        final newProducts = _allProducts.skip(startIndex).take(_pageSize).toList();
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

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      await _loadProducts();
      return;
    }
    final data = await _dbHelper.searchProducts(query);
    setState(() {
      _allProducts = data.map((e) => Product(
        id: e['id'] as int,
        name: e['name'] as String,
        price: (e['price'] as num).toDouble(),
        barcode: e['barcode'] as String,
      )).toList();
      _totalProductCount = _allProducts.length;
      _currentPage = 0;
      _hasMoreData = _allProducts.length > _pageSize;
      _products = _allProducts.take(_pageSize).toList();
    });
  }

  void _showInventoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInventoryPage,
        backgroundColor: Colors.orange[600],
        icon: const Icon(Icons.inventory, color: Colors.white),
        label: const Text(
          'Need Inventory?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 50,
              color: Colors.orange[600],
              alignment: Alignment.center,
              child: const Text(
                'Tinkerpro Price Checker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_check),
              title: const Text('Price Checker'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Product'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductPage()),
                );
                _resetAndLoadProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResetPage()),
                );
                _resetAndLoadProducts();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.orange[600],
        title: const Text(
          'Price Checker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAndLoadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _searchProducts(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products or barcode...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedProductId = null;
                              });
                              _searchProducts('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Colors.orange[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Products: $_totalProductCount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Product List
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _resetAndLoadProducts,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _products.length + (_isLoadingMore && _hasMoreData ? 1 : 0),
                      separatorBuilder: (_, __) => const Divider(height: 1),
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
                        final isSelected = _selectedProductId == product.id;
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedProductId = isSelected ? null : product.id;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange[50] : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.tag,
                                            color: isSelected ? Colors.orange[800] : Colors.orange[700],
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.orange[900] : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.barcode,
                                            color: Colors.grey[600],
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Barcode: ${product.barcode}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Text(
                                  '₱${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange[900] : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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