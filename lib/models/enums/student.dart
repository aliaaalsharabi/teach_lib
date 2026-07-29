class Student {
  final String id;
  final String name;
  final String classRoom;
  final String division;

  Student({
    required this.id,
    required this.name,
    required this.classRoom,
    required this.division,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classRoom': classRoom,
      'division': division,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      classRoom: map['classRoom'] ?? '',
      division: map['division'] ?? '',
    );
  }
}