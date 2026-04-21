class PhoneVerificationSession {
  final String sessionToken;
  final String phoneNumber;
  final DateTime expiresAt;
  final int attemptsRemaining;
  final DateTime? resendAllowedAt;

  PhoneVerificationSession({
    required this.sessionToken,
    required this.phoneNumber,
    required this.expiresAt,
    required this.attemptsRemaining,
    this.resendAllowedAt,
  });

  factory PhoneVerificationSession.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationSession(
      sessionToken: json['session_token'] as String,
      phoneNumber: json['phone'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      attemptsRemaining: json['attempts_remaining'] as int? ?? 5,
      resendAllowedAt: json['resend_allowed_at'] != null
          ? DateTime.parse(json['resend_allowed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'session_token': sessionToken,
        'phone': phoneNumber,
        'expires_at': expiresAt.toIso8601String(),
        'attempts_remaining': attemptsRemaining,
        'resend_allowed_at': resendAllowedAt?.toIso8601String(),
      };

  PhoneVerificationSession copyWith({
    String? sessionToken,
    String? phoneNumber,
    DateTime? expiresAt,
    int? attemptsRemaining,
    DateTime? resendAllowedAt,
  }) {
    return PhoneVerificationSession(
      sessionToken: sessionToken ?? this.sessionToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      resendAllowedAt: resendAllowedAt ?? this.resendAllowedAt,
    );
  }
}

class PhoneVerificationResult {
  final String verifiedToken;
  final DateTime verifiedTokenExpiresAt;
  final String phoneNumber;

  PhoneVerificationResult({
    required this.verifiedToken,
    required this.verifiedTokenExpiresAt,
    required this.phoneNumber,
  });

  factory PhoneVerificationResult.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationResult(
      verifiedToken: json['verified_token'] as String,
      verifiedTokenExpiresAt:
          DateTime.parse(json['verified_token_expires_at'] as String),
      phoneNumber: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'verified_token': verifiedToken,
        'verified_token_expires_at': verifiedTokenExpiresAt.toIso8601String(),
        'phone': phoneNumber,
      };
}
