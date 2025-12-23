class ProductModel {
  final String id;
  final String barbershopId;
  final String name;
  final String? description;
  final double price;
  final double? costPrice;
  final int stock;
  final int minStock;
  final String? imageUrl;
  final String? category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    this.stock = 0,
    this.minStock = 5,
    this.imageUrl,
    this.category,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      costPrice: json['cost_price']?.toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 5,
      imageUrl: json['image_url'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'name': name,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'min_stock': minStock,
      'image_url': imageUrl,
      'category': category,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
  double? get profit => costPrice != null ? price - costPrice! : null;
  double? get profitMargin => costPrice != null && costPrice! > 0
      ? ((price - costPrice!) / costPrice!) * 100
      : null;

  ProductModel copyWith({
    String? id,
    String? barbershopId,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    int? stock,
    int? minStock,
    String? imageUrl,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductSaleModel {
  final String id;
  final String barbershopId;
  final String? productId;
  final String? clientId;
  final String? barberId;
  final String? bookingId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? paymentMethod;
  final DateTime createdAt;

  // Dados relacionados
  final ProductModel? product;

  ProductSaleModel({
    required this.id,
    required this.barbershopId,
    this.productId,
    this.clientId,
    this.barberId,
    this.bookingId,
    this.quantity = 1,
    required this.unitPrice,
    required this.totalPrice,
    this.paymentMethod,
    required this.createdAt,
    this.product,
  });

  factory ProductSaleModel.fromJson(Map<String, dynamic> json) {
    return ProductSaleModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      productId: json['product_id'],
      clientId: json['client_id'],
      barberId: json['barber_id'],
      bookingId: json['booking_id'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      product: json['barbershop_products'] != null
          ? ProductModel.fromJson(json['barbershop_products'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'product_id': productId,
      'client_id': clientId,
      'barber_id': barberId,
      'booking_id': bookingId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }
}
