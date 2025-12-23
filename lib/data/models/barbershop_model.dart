class BarbershopModel {
  final String id;
  final String name;
  final String slug;
  final String? cnpj;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String? ownerId;
  final bool isActive;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BarbershopModel({
    required this.id,
    required this.name,
    required this.slug,
    this.cnpj,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.logoUrl,
    this.coverUrl,
    this.description,
    this.ownerId,
    this.isActive = true,
    this.settings,
    required this.createdAt,
    this.updatedAt,
  });

  factory BarbershopModel.fromJson(Map<String, dynamic> json) {
    return BarbershopModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      cnpj: json['cnpj'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      logoUrl: json['logo_url'],
      coverUrl: json['cover_url'],
      description: json['description'],
      ownerId: json['owner_id'],
      isActive: json['is_active'] ?? true,
      settings: json['settings'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'cnpj': cnpj,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'description': description,
      'owner_id': ownerId,
      'is_active': isActive,
      'settings': settings,
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

  BarbershopModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? cnpj,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? logoUrl,
    String? coverUrl,
    String? description,
    String? ownerId,
    bool? isActive,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BarbershopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      cnpj: cnpj ?? this.cnpj,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
