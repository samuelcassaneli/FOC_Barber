class ClientModel {
  final String id;
  final String? userId;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientModel({
    required this.id,
    this.userId,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
    this.birthDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
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

  ClientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Cliente vinculado a uma barbearia (com dados de exclusividade)
class BarbershopClientModel {
  final String id;
  final String barbershopId;
  final String clientId;
  final String? exclusiveBarberId;
  final bool isExclusive;
  final int loyaltyPoints;
  final String? notes;
  final DateTime? lastVisit;
  final int totalVisits;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Dados do cliente (preenchidos via join)
  final ClientModel? client;

  BarbershopClientModel({
    required this.id,
    required this.barbershopId,
    required this.clientId,
    this.exclusiveBarberId,
    this.isExclusive = false,
    this.loyaltyPoints = 0,
    this.notes,
    this.lastVisit,
    this.totalVisits = 0,
    this.totalSpent = 0,
    required this.createdAt,
    this.updatedAt,
    this.client,
  });

  factory BarbershopClientModel.fromJson(Map<String, dynamic> json) {
    return BarbershopClientModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      clientId: json['client_id'],
      exclusiveBarberId: json['exclusive_barber_id'],
      isExclusive: json['is_exclusive'] ?? false,
      loyaltyPoints: json['loyalty_points'] ?? 0,
      notes: json['notes'],
      lastVisit: json['last_visit'] != null ? DateTime.parse(json['last_visit']) : null,
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      client: json['clients'] != null ? ClientModel.fromJson(json['clients']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'client_id': clientId,
      'exclusive_barber_id': exclusiveBarberId,
      'is_exclusive': isExclusive,
      'loyalty_points': loyaltyPoints,
      'notes': notes,
      'last_visit': lastVisit?.toIso8601String(),
      'total_visits': totalVisits,
      'total_spent': totalSpent,
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

  BarbershopClientModel copyWith({
    String? id,
    String? barbershopId,
    String? clientId,
    String? exclusiveBarberId,
    bool? isExclusive,
    int? loyaltyPoints,
    String? notes,
    DateTime? lastVisit,
    int? totalVisits,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientModel? client,
  }) {
    return BarbershopClientModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      clientId: clientId ?? this.clientId,
      exclusiveBarberId: exclusiveBarberId ?? this.exclusiveBarberId,
      isExclusive: isExclusive ?? this.isExclusive,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      notes: notes ?? this.notes,
      lastVisit: lastVisit ?? this.lastVisit,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
    );
  }
}
