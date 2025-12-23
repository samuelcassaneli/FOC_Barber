import 'barber_model.dart';
import 'client_model.dart';
import 'service_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'no_show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  String toDbValue() {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.noShow:
        return 'no_show';
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  partial,
  refunded;

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  String toDbValue() => name;
}

class BookingModel {
  final String id;
  final String barbershopId;
  final String barberId;
  final String clientId;
  final String? serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final double totalPrice;
  final double discount;
  final String? notes;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Dados relacionados (preenchidos via join)
  final BarberModel? barber;
  final ClientModel? client;
  final ServiceModel? service;

  BookingModel({
    required this.id,
    required this.barbershopId,
    required this.barberId,
    required this.clientId,
    this.serviceId,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    required this.totalPrice,
    this.discount = 0,
    this.notes,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.barber,
    this.client,
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      barbershopId: json['barbershop_id'] ?? '',
      barberId: json['barber_id'],
      clientId: json['client_id'],
      serviceId: json['service_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: BookingStatus.fromString(json['status'] ?? 'pending'),
      paymentStatus: PaymentStatus.fromString(json['payment_status'] ?? 'pending'),
      paymentMethod: json['payment_method'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      notes: json['notes'],
      cancelledBy: json['cancelled_by'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      barber: json['barbers'] != null
          ? BarberModel.fromJson(json['barbers'])
          : null,
      client: json['clients'] != null
          ? ClientModel.fromJson(json['clients'])
          : null,
      service: json['barbershop_services'] != null
          ? ServiceModel.fromJson(json['barbershop_services'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'barber_id': barberId,
      'client_id': clientId,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toDbValue(),
      'payment_status': paymentStatus.toDbValue(),
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'discount': discount,
      'notes': notes,
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
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

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  double get finalPrice => totalPrice - discount;

  BookingModel copyWith({
    String? id,
    String? barbershopId,
    String? barberId,
    String? clientId,
    String? serviceId,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    double? totalPrice,
    double? discount,
    String? notes,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    BarberModel? barber,
    ClientModel? client,
    ServiceModel? service,
  }) {
    return BookingModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      barberId: barberId ?? this.barberId,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barber: barber ?? this.barber,
      client: client ?? this.client,
      service: service ?? this.service,
    );
  }
}
