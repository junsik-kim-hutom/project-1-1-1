import 'profile_image_model.dart';

/// 프로필 모델
///
/// 백엔드 Profile 테이블과 동기화
/// v2.0에서 검색 최적화 필드 추가 및 profileImages를 별도 테이블로 분리
class ProfileModel {
  /// 프로필 ID
  final int id;

  /// 사용자 ID
  final int userId;

  /// 표시 이름
  final String displayName;

  /// 성별 (MALE, FEMALE, OTHER)
  final String gender;

  /// 생년월일
  final DateTime birthDate;

  /// 나이 (v2.0 추가 - 검색 최적화)
  final int? age;

  /// 키 (cm) - v2.0 추가
  final int? height;

  /// 직업 - v2.0 추가
  final String? occupation;

  /// 학력 - v2.0 추가
  final String? education;

  /// 소득 - v2.0 추가
  final String? income;

  /// 흡연 여부 - v2.0 추가
  final String? smoking;

  /// 음주 여부 - v2.0 추가
  final String? drinking;

  /// 자기소개
  final String bio;

  /// 관심사 (JSON 배열)
  final List<String> interests;

  /// 프로필 이미지 목록 (v2.0에서 JSON에서 분리)
  final List<ProfileImageModel>? images;

  /// 인증 여부 - v2.0 추가
  final bool isVerified;

  /// 인증 시간 - v2.0 추가
  final DateTime? verifiedAt;

  /// 프로필 조회수 - v2.0 추가
  final int profileViews;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.gender,
    required this.birthDate,
    this.age,
    this.height,
    this.occupation,
    this.education,
    this.income,
    this.smoking,
    this.drinking,
    required this.bio,
    required this.interests,
    this.images,
    required this.isVerified,
    this.verifiedAt,
    required this.profileViews,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final interestsData = json['interests'];
    final interests = interestsData is List
        ? interestsData.map((e) => e.toString()).toList()
        : <String>[];

    return ProfileModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      displayName: json['displayName']?.toString() ?? '',
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      age: json['age'] as int?,
      height: json['height'] as int?,
      occupation: json['occupation']?.toString(),
      education: json['education']?.toString(),
      income: json['income']?.toString(),
      smoking: json['smoking']?.toString(),
      drinking: json['drinking']?.toString(),
      bio: json['bio']?.toString() ?? '',
      interests: interests,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((e) => ProfileImageModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      profileViews: json['profileViews'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'displayName': displayName,
        'gender': gender,
        'birthDate': birthDate.toIso8601String(),
        'age': age,
        'height': height,
        'occupation': occupation,
        'education': education,
        'income': income,
        'smoking': smoking,
        'drinking': drinking,
        'bio': bio,
        'interests': interests,
        'images': images?.map((e) => e.toJson()).toList(),
        'isVerified': isVerified,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'profileViews': profileViews,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 승인된 이미지만 필터링
  List<ProfileImageModel> get approvedImages {
    // 현재 앱 정책: 대표 사진/프로필 이미지는 승인 여부와 무관하게 노출합니다.
    return images ?? [];
  }

  /// 메인 프로필 이미지
  ProfileImageModel? get mainImage {
    if (approvedImages.isEmpty) return null;
    return approvedImages.where((img) => img.isMain).firstOrNull ??
        approvedImages.first;
  }

  /// 메인 이미지 URL
  String? get mainImageUrl => mainImage?.imageUrl;

  /// 서브 이미지 목록
  List<ProfileImageModel> get subImages {
    return approvedImages.where((img) => img.isSub).toList();
  }

  /// 인증 이미지
  ProfileImageModel? get verificationImage {
    if (images == null) return null;
    return images!
        .where((img) => img.isVerification && img.isApproved)
        .firstOrNull;
  }

  /// 승인 대기 중인 이미지 개수
  int get pendingImagesCount {
    if (images == null) return 0;
    return images!.where((img) => img.isPending).length;
  }

  /// 프로필 완성도 (0-100)
  int get completionPercentage {
    int score = 0;

    // 기본 정보 (30점)
    if (bio.isNotEmpty) score += 10;
    if (interests.isNotEmpty) score += 10;
    if (approvedImages.isNotEmpty) score += 10;

    // 상세 정보 (40점)
    if (height != null) score += 10;
    if (occupation != null) score += 10;
    if (education != null) score += 10;
    if (income != null) score += 10;

    // 추가 정보 (20점)
    if (smoking != null) score += 5;
    if (drinking != null) score += 5;
    if (approvedImages.length >= 3) score += 10;

    // 인증 (10점)
    if (isVerified) score += 10;

    return score;
  }

  /// 프로필이 완성되었는지 (80% 이상)
  bool get isComplete => completionPercentage >= 80;

  /// 나이 계산 (birthDate 기반)
  int get calculatedAge {
    if (age != null) return age!;
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// 키 문자열 (cm 포함)
  String? get heightText {
    if (height == null) return null;
    return '${height}cm';
  }

  /// 성별 한글 표시
  String get genderText {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return '남성';
      case 'FEMALE':
        return '여성';
      case 'OTHER':
        return '기타';
      default:
        return gender;
    }
  }

  /// copyWith
  ProfileModel copyWith({
    int? id,
    int? userId,
    String? displayName,
    String? gender,
    DateTime? birthDate,
    int? age,
    int? height,
    String? occupation,
    String? education,
    String? income,
    String? smoking,
    String? drinking,
    String? bio,
    List<String>? interests,
    List<ProfileImageModel>? images,
    bool? isVerified,
    DateTime? verifiedAt,
    int? profileViews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      height: height ?? this.height,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      income: income ?? this.income,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      profileViews: profileViews ?? this.profileViews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 조회수 증가
  ProfileModel incrementViews() {
    return copyWith(profileViews: profileViews + 1);
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, userId: $userId, age: $calculatedAge, gender: $gender)';
  }
}
