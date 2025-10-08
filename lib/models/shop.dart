class Shop {
int? id;
String name;
String address;
String? logo; // path to logo image
String? colorPalette; // store as hex string


Shop({this.id, required this.name, required this.address, this.logo, this.colorPalette});


Map<String, dynamic> toMap() {
return {
'id': id,
'name': name,
'address': address,
'logo': logo,
'color_palette': colorPalette,
};
}


factory Shop.fromMap(Map<String, dynamic> m) => Shop(
id: m['id'] as int?,
name: m['name'] as String,
address: m['address'] as String,
logo: m['logo'] as String?,
colorPalette: m['color_palette'] as String?,
);
}