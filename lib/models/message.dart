class Message {
  int? id;
  int digitalPersonId;
  String content;
  DateTime timestamp;
  bool isSystem;

  Message({
    this.id,
    required this.digitalPersonId,
    required this.content,
    required this.timestamp,
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'digitalPersonId': digitalPersonId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isSystem': isSystem ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      digitalPersonId: map['digitalPersonId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isSystem: map['isSystem'] == 1,
    );
  }
}
