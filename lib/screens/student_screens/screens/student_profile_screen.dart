// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:attend/constants.dart/enums.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/faculty_home_screen.dart';
import 'package:attend/screens/student_screens/screens/student_screen.dart';
import 'package:attend/widgets.dart/profile_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentProfileScreen extends StatefulWidget {
  static const routeName = 'student-profile-screen';
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  var selectedGender = 'Male';

  final _nameCon = TextEditingController();
  final _surnameCon = TextEditingController();
  final _enrollmentCon = TextEditingController();

  Widget buildTextField(String titleText, TextEditingController controller,
          TextInputAction inputAction, TextInputType textInputType) =>
      TextFormField(
        keyboardType: textInputType,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: 'Enter your $titleText',
          labelStyle: TextStyle(color: Colors.black, fontSize: 15),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $titleText!';
          } else if (value.length <= 2) {
            return '$titleText at least 3 character long!';
          }
          return null;
        },
        controller: controller,
        textInputAction: inputAction,
      );

  void saveData(BuildContext context) async {
    // final isValid = _formKey.currentState!.validate();

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameCon.text,
        'surname': _surnameCon.text,
        'enrollment': _enrollmentCon.text,
        'gender': selectedGender,
        'attendedClass': [],
      });

      Provider.of<UserDataProvider>(context, listen: false).saveUserData(
        _nameCon.text,
        _surnameCon.text,
        selectedGender == 'Male'
            ? Genders.Male
            : selectedGender == 'Female'
                ? Genders.Female
                : Genders.Other,
        _enrollmentCon.text,
      );
    } on FirebaseException catch (e) {
      print(e.message);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => UserDataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile data'),
          actions: [
            IconButton(
                onPressed: () {
                  saveData(context);
                  if (Provider.of<UserDataProvider>(context, listen: false)
                          .role ==
                      Roles.student) {
                    Navigator.pushReplacementNamed(
                        context, StudentScreen.routeName);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, FacultyHomeScreen.routeName);
                  }
                },
                icon: Icon(
                  Icons.save,
                ))
          ],
        ),
        body: Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ProfileImage(selectedGender: selectedGender),
                  TextButton(
                      onPressed: null, child: Text('Change profile picture')),
                  SizedBox(height: 20),
                  buildTextField('name', _nameCon, TextInputAction.next,
                      TextInputType.text),
                  SizedBox(height: 20),
                  buildTextField('surname', _surnameCon, TextInputAction.next,
                      TextInputType.text),
                  SizedBox(height: 20),
                  buildTextField('enrollment no', _enrollmentCon,
                      TextInputAction.next, TextInputType.number),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Gender ',
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      DropdownButton<String>(
                        dropdownColor: Colors.purple.shade50,
                        value: selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            setState(() {
                              selectedGender = newValue!;
                            });
                          });
                        },
                        items: <String>['Male', 'Female', 'Others']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 15),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
