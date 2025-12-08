class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final int durationMin;
  final double price;
  final String? imageUrl;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationMin,
    required this.price,
    this.imageUrl,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      durationMin: json['duration_min'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_min': durationMin,
      'price': price,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
