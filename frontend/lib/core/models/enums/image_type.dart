/// 프로필 이미지 타입 열거형
enum ImageType {
  /// 메인 프로필 사진
  main('MAIN'),

  /// 서브 프로필 사진
  sub('SUB'),

  /// 본인 인증 사진
  verification('VERIFICATION');

  const ImageType(this.value);

  final String value;

  static ImageType fromString(String value) {
    return ImageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ImageType.sub,
    );
  }

  /// 표시 텍스트
  String get displayText {
    switch (this) {
      case ImageType.main:
        return '대표 사진';
      case ImageType.sub:
        return '일반 사진';
      case ImageType.verification:
        return '인증 사진';
    }
  }

  /// 우선순위 (낮을수록 먼저 표시)
  int get priority {
    switch (this) {
      case ImageType.main:
        return 0;
      case ImageType.verification:
        return 1;
      case ImageType.sub:
        return 2;
    }
  }
}
