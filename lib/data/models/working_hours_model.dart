class WorkingHoursModel {
  final String id;
  final String barberId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? lunchStart;
  final String? lunchEnd;

  WorkingHoursModel({
    required this.id,
    required this.barberId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.lunchStart,
    this.lunchEnd,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      id: json['id'],
      barberId: json['barber_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      lunchStart: json['lunch_start'],
      lunchEnd: json['lunch_end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'lunch_start': lunchStart,
      'lunch_end': lunchEnd,
    };
  }
}
