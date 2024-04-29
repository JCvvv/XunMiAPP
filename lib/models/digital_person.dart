class DigitalPerson {
  int? id;
  String role;
  String name;
  String avatarUrl;
  String prompt;

  DigitalPerson({
    this.id,
    required this.role,
    required this.name,
    required this.avatarUrl,
    required this.prompt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'avatarUrl': avatarUrl,
      'prompt': prompt,
    };
  }

  factory DigitalPerson.fromMap(Map<String, dynamic> map) {
    return DigitalPerson(
      id: map['id'],
      role: map['role'],
      name: map['name'],
      avatarUrl: map['avatarUrl'],
      prompt: map['prompt'],
    );
  }
}
