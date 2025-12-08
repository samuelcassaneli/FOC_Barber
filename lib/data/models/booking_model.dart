class BookingModel {
  final String id;
  final String clientId;
  final String barberId;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.barberId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paymentStatus,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      clientId: json['client_id'],
      barberId: json['barber_id'],
      serviceId: json['service_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'],
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'barber_id': barberId,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
