class Course {
  final int? id;
  final String name;
  final String description;
  int? teacherId;

  Course({
    this.id,
    required this.name,
    required this.description,
    this.teacherId,
  });

  // Convert a Course into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
    };
  }

  // Implement a factory constructor for creating a new Course instance from a map.
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      teacherId: map['teacherId'],
    );
  }

  Course copyWith({
    int? id,
    String? name,
    String? description,
    int? teacherId,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
