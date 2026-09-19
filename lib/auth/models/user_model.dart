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

  /// Whether the user currently has an active paid subscription
  bool get isPaidSubscriptionActive {
    if (subscription != null) {
      final isActive = subscription!['isActive'];
      final status = subscription!['status']?.toString().toLowerCase();
      final type = subscription!['type']?.toString().toLowerCase();
      final plan = subscription!['plan']?.toString().toLowerCase();
      final productId = subscription!['productId']?.toString().toLowerCase();

      // If backend explicitly says isActive: true or status: 'active'/'trialing'
      if (isActive == true || status == 'active' || status == 'trialing') {
        return true;
      }
      // If subscription object has plan details (type / plan / productId)
      if ((type != null && type.isNotEmpty && type != 'free') ||
          (plan != null && plan.isNotEmpty && plan != 'free') ||
          (productId != null && productId.isNotEmpty)) {
        return true;
      }
    }
    // If role is explicitly premium or hasPremiumAccess is true while isTrialActive is false
    if (role?.toLowerCase() == 'premium') return true;
    if (hasPremiumAccess == true && isTrialActive != true) return true;

    return false;
  }

  /// Whether the user is strictly on the 7-day free trial (and NOT on paid subscription)
  bool get isTrialStrictlyActive {
    if (isPaidSubscriptionActive) return false;
    return isTrialActive == true || hasPremiumAccess == true;
  }
}

