class WorkingHoursModel {
  final String id;
  final String barbershopId;
  final String? barberId; // NULL = horário da barbearia
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? lunchStart;
  final String? lunchEnd;
  final bool isAvailable;

  WorkingHoursModel({
    required this.id,
    required this.barbershopId,
    this.barberId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.lunchStart,
    this.lunchEnd,
    this.isAvailable = true,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      id: json['id'],
      barbershopId: json['barbershop_id'] ?? '',
      barberId: json['barber_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      lunchStart: json['lunch_start'],
      lunchEnd: json['lunch_end'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'barber_id': barberId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'lunch_start': lunchStart,
      'lunch_end': lunchEnd,
      'is_available': isAvailable,
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  String get dayName {
    const days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    return days[dayOfWeek];
  }

  String get dayNameShort {
    const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return days[dayOfWeek];
  }

  WorkingHoursModel copyWith({
    String? id,
    String? barbershopId,
    String? barberId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? lunchStart,
    String? lunchEnd,
    bool? isAvailable,
  }) {
    return WorkingHoursModel(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      barberId: barberId ?? this.barberId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lunchStart: lunchStart ?? this.lunchStart,
      lunchEnd: lunchEnd ?? this.lunchEnd,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Modelo para bloqueios de horário (folgas, férias, etc.)
class TimeBlockModel {
  final String id;
  final String barbershopId;
  final String? barberId;
  final DateTime startTime;
  final DateTime endTime;
  final String? reason;
  final String blockType; // break, vacation, holiday, other
  final DateTime createdAt;

  TimeBlockModel({
    required this.id,
    required this.barbershopId,
    this.barberId,
    required this.startTime,
    required this.endTime,
    this.reason,
    this.blockType = 'break',
    required this.createdAt,
  });

  factory TimeBlockModel.fromJson(Map<String, dynamic> json) {
    return TimeBlockModel(
      id: json['id'],
      barbershopId: json['barbershop_id'],
      barberId: json['barber_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      reason: json['reason'],
      blockType: json['block_type'] ?? 'break',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'barber_id': barberId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'reason': reason,
      'block_type': blockType,
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
