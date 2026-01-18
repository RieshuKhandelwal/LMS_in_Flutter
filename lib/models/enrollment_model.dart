class Enrollment {
  int? id;
  int? studentId;
  int? courseId;

  Enrollment({this.id, this.studentId, this.courseId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'studentId': studentId, 'courseId': courseId};
  }

  factory Enrollment.fromMapObject(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'],
      studentId: map['studentId'],
      courseId: map['courseId'],
    );
  }
}
