class UserModel {
  final String? id;
  final String? email;
  final String? username;
  final String? name;
  final String? role;
  final bool? isTrialActive;
  final bool? hasPremiumAccess;
  final String? trialExpiresAt;
  final Map<String, dynamic>? subscription;

  UserModel({
    this.id,
    this.email,
    this.username,
    this.name,
    this.role,
    this.isTrialActive,
    this.hasPremiumAccess,
    this.trialExpiresAt,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      isTrialActive: json['isTrialActive'] as bool?,
      hasPremiumAccess: json['hasPremiumAccess'] as bool?,
      trialExpiresAt: json['trialExpiresAt']?.toString(),
      subscription: json['subscription'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'role': role,
      'isTrialActive': isTrialActive,
      'hasPremiumAccess': hasPremiumAccess,
      'trialExpiresAt': trialExpiresAt,
      'subscription': subscription,
    };
  }
}

