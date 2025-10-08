class Product {
  final int id;
  final String name;
  final String brand;
  final String barcode;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.price,
  });

  // Copy method for editing
  Product copyWith({
    int? id,
    String? name,
    String? brand,
    String? barcode,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
    );
  }
}