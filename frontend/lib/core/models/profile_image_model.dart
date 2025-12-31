import 'enums/image_type.dart';

/// 프로필 이미지 모델
///
/// 백엔드 ProfileImage 테이블과 동기화
/// v2.0에서 Profile.profileImages (JSON)에서 분리됨
class ProfileImageModel {
  /// ID
  final String id;

  /// 프로필 ID
  final String profileId;

  /// 이미지 URL
  final String imageUrl;

  /// 이미지 타입 (MAIN, SUB, VERIFICATION)
  final ImageType imageType;

  /// 표시 순서 (0부터 시작)
  final int displayOrder;

  /// 승인 여부
  final bool isApproved;

  /// 거부 사유 (거부된 경우)
  final String? rejectionReason;

  /// 업로드 시간
  final DateTime uploadedAt;

  /// 승인/거부 시간
  final DateTime? reviewedAt;

  ProfileImageModel({
    required this.id,
    required this.profileId,
    required this.imageUrl,
    required this.imageType,
    required this.displayOrder,
    required this.isApproved,
    this.rejectionReason,
    required this.uploadedAt,
    this.reviewedAt,
  });

  /// JSON → Model
  factory ProfileImageModel.fromJson(Map<String, dynamic> json) {
    return ProfileImageModel(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      imageUrl: json['imageUrl'] as String,
      imageType: ImageType.fromString(json['imageType'] as String),
      displayOrder: json['displayOrder'] as int,
      isApproved: json['isApproved'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'imageUrl': imageUrl,
        'imageType': imageType.value,
        'displayOrder': displayOrder,
        'isApproved': isApproved,
        'rejectionReason': rejectionReason,
        'uploadedAt': uploadedAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
      };

  /// 메인 프로필 사진인지
  bool get isMain => imageType == ImageType.main;

  /// 서브 프로필 사진인지
  bool get isSub => imageType == ImageType.sub;

  /// 인증 사진인지
  bool get isVerification => imageType == ImageType.verification;

  /// 승인 대기 중인지
  bool get isPending => !isApproved && rejectionReason == null && reviewedAt == null;

  /// 거부되었는지
  bool get isRejected => !isApproved && rejectionReason != null;

  /// copyWith
  ProfileImageModel copyWith({
    String? id,
    String? profileId,
    String? imageUrl,
    ImageType? imageType,
    int? displayOrder,
    bool? isApproved,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? reviewedAt,
  }) {
    return ProfileImageModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageType: imageType ?? this.imageType,
      displayOrder: displayOrder ?? this.displayOrder,
      isApproved: isApproved ?? this.isApproved,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  String toString() {
    return 'ProfileImageModel(id: $id, imageType: ${imageType.value}, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileImageModel &&
        other.id == id &&
        other.profileId == profileId &&
        other.imageUrl == imageUrl &&
        other.imageType == imageType &&
        other.displayOrder == displayOrder &&
        other.isApproved == isApproved &&
        other.rejectionReason == rejectionReason &&
        other.uploadedAt == uploadedAt &&
        other.reviewedAt == reviewedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        profileId.hashCode ^
        imageUrl.hashCode ^
        imageType.hashCode ^
        displayOrder.hashCode ^
        isApproved.hashCode ^
        rejectionReason.hashCode ^
        uploadedAt.hashCode ^
        reviewedAt.hashCode;
  }
}
