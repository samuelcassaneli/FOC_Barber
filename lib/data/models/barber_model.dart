class BarberModel {
  final String id;
  final String profileId;
  final String? bio;
  final List<String> specializedSkills;
  final bool isAvailable;

  BarberModel({
    required this.id,
    required this.profileId,
    this.bio,
    required this.specializedSkills,
    required this.isAvailable,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'],
      profileId: json['profile_id'],
      bio: json['bio'],
      specializedSkills: List<String>.from(json['specialized_skills'] ?? []),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'bio': bio,
      'specialized_skills': specializedSkills,
      'is_available': isAvailable,
    };
  }
}
