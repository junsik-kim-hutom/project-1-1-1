/// 사용자 모델
///
/// 백엔드 User 테이블과 동기화
/// v2.0에서 이메일/전화번호 인증, 로그인 추적, Soft Delete 필드 추가
class UserModel {
  /// 사용자 ID
  final int id;

  /// 이메일
  final String email;

  /// 이메일 인증 여부 - v2.0 추가
  final bool emailVerified;

  /// 전화번호 - v2.0 추가
  final String? phoneNumber;

  /// 전화번호 인증 여부 - v2.0 추가
  final bool phoneVerified;

  /// 인증 제공자 (GOOGLE, LINE, YAHOO, KAKAO, APPLE, FACEBOOK)
  final String authProvider;

  /// OAuth Provider ID (authProviderId)
  final String providerId;

  /// 사용자 상태 (ACTIVE, SUSPENDED, DELETED)
  final String status;

  /// 마지막 로그인 IP - v2.0 추가
  final String? lastLoginIp;

  /// 로그인 횟수 - v2.0 추가
  final int loginCount;

  /// 마지막 로그인 시간
  final DateTime lastLoginAt;

  /// 삭제 시간 (Soft Delete) - v2.0 추가
  final DateTime? deletedAt;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.phoneNumber,
    required this.phoneVerified,
    required this.authProvider,
    required this.providerId,
    required this.status,
    this.lastLoginIp,
    required this.loginCount,
    required this.lastLoginAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseId(json['id']),
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String,
      providerId: json['authProviderId'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      lastLoginIp: json['lastLoginIp'] as String?,
      loginCount: json['loginCount'] as int? ?? 0,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'emailVerified': emailVerified,
        'phoneNumber': phoneNumber,
        'phoneVerified': phoneVerified,
        'authProvider': authProvider,
        'authProviderId': providerId,
        'status': status,
        'lastLoginIp': lastLoginIp,
        'loginCount': loginCount,
        'lastLoginAt': lastLoginAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 활성 사용자인지
  bool get isActive => status == 'ACTIVE';

  /// 정지된 사용자인지
  bool get isSuspended => status == 'SUSPENDED';

  /// 삭제된 사용자인지
  bool get isDeleted => status == 'DELETED' || deletedAt != null;

  /// 전화번호 또는 이메일 인증 완료 여부
  bool get isVerified => emailVerified || phoneVerified;

  /// 전체 인증 완료 여부 (이메일 + 전화번호)
  bool get isFullyVerified => emailVerified && phoneVerified;

  /// 인증 제공자 표시 이름
  String get authProviderDisplayName {
    switch (authProvider.toUpperCase()) {
      case 'GOOGLE':
        return 'Google';
      case 'LINE':
        return 'LINE';
      case 'YAHOO':
        return 'Yahoo';
      case 'KAKAO':
        return 'Kakao';
      case 'APPLE':
        return 'Apple';
      case 'FACEBOOK':
        return 'Facebook';
      default:
        return authProvider;
    }
  }

  /// 가입 경과 일수
  int get daysSinceJoined {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// 신규 사용자인지 (7일 이내)
  bool get isNewUser => daysSinceJoined <= 7;

  /// 마지막 로그인 경과 시간 (초)
  int get secondsSinceLastLogin {
    return DateTime.now().difference(lastLoginAt).inSeconds;
  }

  /// 최근 로그인 여부 (24시간 이내)
  bool get isRecentlyActive {
    return secondsSinceLastLogin < 86400; // 24 hours
  }

  /// 전화번호 마스킹 (예: 010-1234-5678 → 010-****-5678)
  String? get maskedPhoneNumber {
    if (phoneNumber == null) return null;
    if (phoneNumber!.length < 9) return phoneNumber;

    final cleaned = phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11) {
      // 010-1234-5678 형식
      return '${cleaned.substring(0, 3)}-****-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      // 02-1234-5678 형식
      return '${cleaned.substring(0, 2)}-****-${cleaned.substring(6)}';
    }
    return phoneNumber;
  }

  /// 이메일 마스킹 (예: user@example.com → u***@example.com)
  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 1) return email;

    final masked = '${username[0]}${'*' * (username.length - 1)}';
    return '$masked@$domain';
  }

  /// copyWith
  UserModel copyWith({
    int? id,
    String? email,
    bool? emailVerified,
    String? phoneNumber,
    bool? phoneVerified,
    String? authProvider,
    String? providerId,
    String? status,
    String? lastLoginIp,
    int? loginCount,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      authProvider: authProvider ?? this.authProvider,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      loginCount: loginCount ?? this.loginCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ status.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
