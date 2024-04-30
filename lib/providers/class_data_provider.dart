import 'package:attend/models/class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClassProvider extends ChangeNotifier {
  final List<ClassModel> _classes = [];

  List<ClassModel> get classes {
    return [..._classes];
  }

  String getSession(String classId) {
    final classModel = getClassModelById(classId);

    return classModel.session;
  }

  int getAttendance(String classId) {
    int attend = 0;

    final classModel = getClassModelById(classId);
    attend = classModel.attendance == null ? 0 : classModel.attendance!.length;

    return attend;
  }

  makeOfflineSession(String classId) async {
    final classIndex =
        _classes.indexWhere((element) => element.classId == classId);
    final classData = _classes[classIndex];
    final updatedClass = ClassModel(
      classData.branch,
      classData.classCode,
      classData.divison,
      classData.facultyName,
      classData.semester,
      'offline',
      classData.subject,
      classData.classId,
      classData.attendance,
      classData.facultyId,
      classData.date,
    );

    _classes[classIndex] = updatedClass;

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({
        'session': 'offline',
      });
    } catch (e) {
      print('error');
      print(e.toString());
    }
    notifyListeners();
  }

  ClassModel getClassModelById(String id) {
    return _classes.firstWhere((element) => element.classId == id);
  }

  Future<void> fetchAttandance(String id) async {
    try {
      final documentSnap =
          await FirebaseFirestore.instance.collection('classes').doc(id).get();
      print('data===========================');
      print(documentSnap.data());
      final classData = documentSnap.data() as Map<String, dynamic>;
      final List<String> attendance =
          List<String>.from(classData['attendance']);
      final sheet = _classes.firstWhere((element) => element.classId == id);

      sheet.attendance!.clear();
      sheet.attendance!.addAll(attendance);
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchClassesData() async {
    final _tempclasses = _classes;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('classes')
              .orderBy('createdAt')
              .get();

      _classes.clear();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final data = querySnapshot.docs[i].data();
        final id = querySnapshot.docs[i].id;
        final facultyId = FirebaseAuth.instance.currentUser!.uid;

        data.forEach((key, value) {
          if (key == 'facultyId' && value == facultyId) {
            final ClassModel classData = ClassModel(
              data['branch'],
              data['classCode'],
              data['division'],
              data['faculty'],
              data['semester'],
              data['session'],
              data['subject'],
              id,
              data['attendance'],
              facultyId,
              data['date'],
            );
            _classes.insert(0, classData);
          }
        });
      }

      print(_classes.length);
    } on FirebaseException catch (e) {
      _classes.addAll(_tempclasses);
      print('Firebase Error');
      print(e.message);
      print(e.code);
      rethrow;
    } catch (e) {
      _classes.addAll(_tempclasses);
      print('Error');
      print(e.toString());
      rethrow;
    }
    notifyListeners();
  }
}
