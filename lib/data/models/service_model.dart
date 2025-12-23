class ServiceModel {
  final String id;
  final String barbershopId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final String? imageUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    this.durationMinutes = 30,
    this.category,
    this.imageUrl,
    this.isActive = true,
    this.displayOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      barbershopId: json['barbershop_id'] ?? '',
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['duration_minutes'] ?? json['duration_min'] ?? 30,
      category: json['category'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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
      'duration_minutes': durationMinutes,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive,
      'display_order': displayOrder,
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

  // Alias para compatibilidade
  int get durationMin => durationMinutes;

  ServiceModel copyWith({
    String? id,
    String? barbershopId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    String? imageUrl,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Serviço customizado por barbeiro
class BarberServiceModel {
  final String id;
  final String barberId;
  final String serviceId;
  final double? priceOverride;
  final int? durationOverride;
  final bool isActive;

  // Dados do serviço (preenchidos via join)
  final ServiceModel? service;

  BarberServiceModel({
    required this.id,
    required this.barberId,
    required this.serviceId,
    this.priceOverride,
    this.durationOverride,
    this.isActive = true,
    this.service,
  });

  factory BarberServiceModel.fromJson(Map<String, dynamic> json) {
    return BarberServiceModel(
      id: json['id'],
      barberId: json['barber_id'],
      serviceId: json['service_id'],
      priceOverride: json['price_override']?.toDouble(),
      durationOverride: json['duration_override'],
      isActive: json['is_active'] ?? true,
      service: json['barbershop_services'] != null
          ? ServiceModel.fromJson(json['barbershop_services'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'service_id': serviceId,
      'price_override': priceOverride,
      'duration_override': durationOverride,
      'is_active': isActive,
    };
  }

  /// Retorna o preço efetivo (override ou original)
  double get effectivePrice => priceOverride ?? service?.price ?? 0;

  /// Retorna a duração efetiva (override ou original)
  int get effectiveDuration => durationOverride ?? service?.durationMinutes ?? 30;
}
