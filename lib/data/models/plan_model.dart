class PlanModel {
  final String id;
  final String barbershopId;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final int? maxBookingsPerMonth;
  final double discountPercentage;
  final List<String> includedServices;
  final List<String> benefits;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PlanModel({
    required this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    this.durationDays = 30,
    this.maxBookingsPerMonth,
    this.discountPercentage = 0,
    this.includedServices = const [],
    this.benefits = const [],
    this.isActive = true,
    this.displayOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['duration_days'] ?? 30,
      maxBookingsPerMonth: json['max_bookings_per_month'],
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      includedServices: List<String>.from(json['included_services'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
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
      'duration_days': durationDays,
      'max_bookings_per_month': maxBookingsPerMonth,
      'discount_percentage': discountPercentage,
      'included_services': includedServices,
      'benefits': benefits,
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

  PlanModel copyWith({
    String? id,
    String? barbershopId,
    String? name,
    String? description,
    double? price,
    int? durationDays,
    int? maxBookingsPerMonth,
    double? discountPercentage,
    List<String>? includedServices,
    List<String>? benefits,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      maxBookingsPerMonth: maxBookingsPerMonth ?? this.maxBookingsPerMonth,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      includedServices: includedServices ?? this.includedServices,
      benefits: benefits ?? this.benefits,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String barbershopId;
  final String clientId;
  final String? planId;
  final DateTime startDate;
  final DateTime endDate;
  final int bookingsUsed;
  final bool isActive;
  final bool autoRenew;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Dados relacionados
  final PlanModel? plan;

  SubscriptionModel({
    required this.id,
    required this.barbershopId,
    required this.clientId,
    this.planId,
    required this.startDate,
    required this.endDate,
    this.bookingsUsed = 0,
    this.isActive = true,
    this.autoRenew = false,
    this.paymentStatus = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.plan,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      clientId: json['client_id'],
      planId: json['plan_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      bookingsUsed: json['bookings_used'] ?? 0,
      isActive: json['is_active'] ?? true,
      autoRenew: json['auto_renew'] ?? false,
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      plan: json['barbershop_plans'] != null
          ? PlanModel.fromJson(json['barbershop_plans'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'client_id': clientId,
      'plan_id': planId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'bookings_used': bookingsUsed,
      'is_active': isActive,
      'auto_renew': autoRenew,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  int? get bookingsRemaining {
    if (plan?.maxBookingsPerMonth == null) return null;
    return plan!.maxBookingsPerMonth! - bookingsUsed;
  }
}
