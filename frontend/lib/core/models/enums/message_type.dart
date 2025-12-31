/// 채팅 메시지 타입 열거형
enum MessageType {
  /// 일반 텍스트 메시지
  text('TEXT'),

  /// 이미지 메시지
  image('IMAGE'),

  /// 시스템 메시지 (입장/퇴장 등)
  system('SYSTEM');

  const MessageType(this.value);

  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}
