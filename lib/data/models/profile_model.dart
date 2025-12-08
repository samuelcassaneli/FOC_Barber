class ProfileModel {
  final String id;
  final String role;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.role,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      role: json['role'] ?? 'client',
      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
