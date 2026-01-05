/// 매칭 액션 열거형
///
/// 사용자가 다른 프로필에 대해 취할 수 있는 행동
enum MatchingAction {
  /// 관심
  like('LIKE'),

  /// 패스 (관심 없음)
  pass('PASS'),

  /// 부스트
  superLike('SUPER_LIKE'),

  /// 차단
  block('BLOCK');

  const MatchingAction(this.value);

  final String value;

  static MatchingAction fromString(String value) {
    return MatchingAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => MatchingAction.pass,
    );
  }

  /// 아이콘
  String get icon {
    switch (this) {
      case MatchingAction.like:
        return '✨';
      case MatchingAction.pass:
        return '👎';
      case MatchingAction.superLike:
        return '⚡';
      case MatchingAction.block:
        return '🚫';
    }
  }

  /// 색상 (Hex)
  String get colorHex {
    switch (this) {
      case MatchingAction.like:
        return '#FF6B6B'; // Warm Coral
      case MatchingAction.pass:
        return '#9E9E9E'; // Grey
      case MatchingAction.superLike:
        return '#2BB0A0'; // Teal
      case MatchingAction.block:
        return '#F44336'; // Red
    }
  }

  /// 표시 텍스트
  String get displayText {
    switch (this) {
      case MatchingAction.like:
        return '관심';
      case MatchingAction.pass:
        return '패스';
      case MatchingAction.superLike:
        return '부스트';
      case MatchingAction.block:
        return '차단';
    }
  }
}
