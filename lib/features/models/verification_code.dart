class VerificationCode {
  final int codeId;
  final int userId;
  final String code;
  final String type;
  final DateTime expiresAt;
  final bool isUsed;

  VerificationCode({
    required this.codeId,
    required this.userId,
    required this.code,
    required this.type,
    required this.expiresAt,
    required this.isUsed,
  });

  factory VerificationCode.fromJson(Map<String, dynamic> json) {
    return VerificationCode(
      codeId: json['code_id'] as int,
      userId: json['user_id'] as int,
      code: json['code'] as String,
      type: json['type'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isUsed: json['is_used'] == 1 || json['is_used'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_id': codeId,
      'user_id': userId,
      'code': code,
      'type': type,
      'expires_at': expiresAt.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
    };
  }
}
