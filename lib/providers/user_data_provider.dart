// ignore_for_file: avoid_print

import 'package:attend/constants.dart/enums.dart';
import 'package:attend/models/class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  String? _name;
  String? _surname;
  Genders _gender = Genders.Other;
  Roles? _role;
  String _enrollment = '';
  bool isSignup = false;
  String? uid;
  List<dynamic> attendedClass = [];
  List<ClassModel> classess = [];
  Map<String, dynamic> attendedClassess = {};

  String get enrollment {
    return _enrollment;
  }

  printData() {
    print(_name);
    print(_surname);
    print('gender ${_gender.name}');
    print(_role);
    print('_enrollment ${_enrollment}');
  }

  setRoleEmail(Roles role, String email) {
    _role = role;
    notifyListeners();
  }

  takeAttendance(String classId, String faculty, String subject, String date) {
    var data = [
      faculty,
      subject,
      date,
    ];

    attendedClassess.putIfAbsent(classId, () => data);

    print(attendedClassess);
  }

  setNameSurGender(String name, String surname, String gender,
      [String enrolment = '']) {
    print('data');
    _name = name;
    _surname = surname;
    _enrollment = enrolment;
    if (gender == 'Male') {
      _gender = Genders.Male;
    } else if (gender == "Femals") {
      _gender = Genders.Female;
    } else {
      _gender = Genders.Other;
    }
    print(_name);
    notifyListeners();
  }

  setRole(Roles role) {
    _role = role;
    notifyListeners();
  }

  changePage() {
    isSignup = !isSignup;
    notifyListeners();
  }

  String get gender {
    return _gender.name;
  }

  String? get surname {
    return _surname;
  }

  String? get name {
    return _name;
  }

  Roles? get role {
    return _role;
  }

  String? get facultyName {
    print(_name);
    print(_surname);
    return '$_name $_surname';
  }

  Future<void> fetchAndSetUserData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    //! fetching userdata
    var snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    //! itreate that data and assigned to class or variable
    Map<String, dynamic> userData = snap.data() as Map<String, dynamic>;

    //! roles
    if (userData['role'] == 'student') {
      _role = Roles.student;
    } else {
      _role = Roles.faculty;
    }

    //! gender
    if (userData['gender'] == 'Male') {
      _gender = Genders.Male;
    } else if (userData['gender'] == 'Femalse') {
      _gender = Genders.Female;
    } else {
      _gender = Genders.Other;
    }

    //! other (name, surname, _enrollment)
    _name = userData['name'];
    _surname = userData['surname'];
    _enrollment = userData['enrollment'];
    attendedClass = userData['attendedClass'] ?? [];
    attendedClassess = userData['attendedClasses'] ?? {};
    print('userDAta $attendedClassess');

    notifyListeners();
  }

//! save user detials from profile data
  Future<void> saveUserData([
    name = '',
    surname = '',
    Genders gender = Genders.Other,
    enrollmentNo = '',
    role = '',
  ]) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'surname': surname,
        'gender': gender.name,
        'enrollment': enrollmentNo,
      });

      _name = name;
      _surname = surname;
      _gender = gender;
      _enrollment = enrollmentNo;

      print(_enrollment);
      print('Success');
    } on FirebaseException catch (e) {
      print('Firebase error ----------->');
      print(e.code);
      print(e.message);
      rethrow;
    } catch (e) {
      print('Last catch error ----------->');
      print(e.toString());
      rethrow;
    }
    notifyListeners();
  }

  Future<void> attendClass(String classId) async {
    attendedClass.add(classId);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'attendedClass': attendedClass,
      });
      print('sucees');
    } on FirebaseException catch (e) {
      print(e.message);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchAttendedClass() async {
    try {
      final data =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final d = data.data();
      final subD = d!['attendedClasses'];
      print(subD);
    } on FirebaseException catch (e) {
      print(e.message);
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }
}
