

import 'dart:convert';

class Product {
  String? id;
  bool available;
  String name;
  String? picture;
  double price;

  Product({
    this.id,
    required this.available,
    required this.name,
    this.picture,
    required this.price,
  });

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
      };

  Product copy() => Product(
        id: id,
        available: available,
        name: name,
        picture: picture,
        price: price,
      );
}
