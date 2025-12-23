class BarberModel {
  final String id;
  final String? userId;
  final String barbershopId;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final List<String> specialties;
  final double commissionRate;
  final bool isOwner;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BarberModel({
    required this.id,
    this.userId,
    required this.barbershopId,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
    this.bio,
    this.specialties = const [],
    this.commissionRate = 50.0,
    this.isOwner = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'],
      userId: json['user_id'],
      barbershopId: json['barbershop_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      specialties: List<String>.from(json['specialties'] ?? []),
      commissionRate: (json['commission_rate'] ?? 50.0).toDouble(),
      isOwner: json['is_owner'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'barbershop_id': barbershopId,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'specialties': specialties,
      'commission_rate': commissionRate,
      'is_owner': isOwner,
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

  BarberModel copyWith({
    String? id,
    String? userId,
    String? barbershopId,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? bio,
    List<String>? specialties,
    double? commissionRate,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BarberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      commissionRate: commissionRate ?? this.commissionRate,
      isOwner: isOwner ?? this.isOwner,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
