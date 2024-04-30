class ClassModel {
  final String branch;
  final String classCode;
  final String divison;
  final String facultyName;
  final int semester;
  final String session;
  final String subject;
  final String classId;
  final List<dynamic>? attendance;
  final String facultyId;
  final String? date;

  ClassModel(
    this.branch,
    this.classCode,
    this.divison,
    this.facultyName,
    this.semester,
    this.session,
    this.subject,
    this.classId,
    this.attendance,
    this.facultyId,
    this.date,
  );
}
