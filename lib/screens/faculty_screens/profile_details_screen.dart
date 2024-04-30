// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, duplicate_ignore

import 'package:attend/constants.dart/enums.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/faculty_home_screen.dart';
import 'package:attend/screens/student_screens/screens/student_screen.dart';
import 'package:attend/widgets.dart/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  static const routeName = '/profile-detail-screen';
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  var selectedGender = 'Male';
  final _nameCon = TextEditingController();
  final _surnameCon = TextEditingController();
  final _enrollmentCon = TextEditingController();
  var isValid = false;

  @override
  void dispose() {
    _nameCon.dispose();
    _surnameCon.dispose();
    _enrollmentCon.dispose();
    super.dispose();
  }

  void saveData() async {
    isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    var gender = Genders.Other;
    if (selectedGender == Genders.Male.name) {
      gender = Genders.Male;
    } else if (selectedGender == Genders.Female.name) {
      gender = Genders.Female;
    }

    try {
      Provider.of<UserDataProvider>(context, listen: false).saveUserData(
        _nameCon.text,
        _surnameCon.text,
        gender,
        _enrollmentCon.text,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context, listen: false);

    //! set controller data if edit the profile
    print('main ${userData.enrollment}');
    _nameCon.text = userData.name ?? '';
    _surnameCon.text = userData.surname ?? '';
    _enrollmentCon.text = userData.enrollment ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile details'),
        actions: [
          IconButton(
              onPressed: () {
                saveData();
                if (isValid) {
                  if (Provider.of<UserDataProvider>(context, listen: false)
                          .role ==
                      Roles.student) {
                    Navigator.pushReplacementNamed(
                        context, StudentScreen.routeName);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, FacultyHomeScreen.routeName);
                  }
                }
              },
              icon: Icon(
                Icons.save,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ProfileImage(selectedGender: selectedGender),
                SizedBox(height: 20),

                //! name textfield
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    labelText: 'Enter your name',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter name!';
                    } else if (value.length <= 2) {
                      return 'Name at least 3 character long!';
                    }
                    return null;
                  },
                  controller: _nameCon,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),

                //! surname textfield
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    labelText: 'Enter your surname',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter surname!';
                    } else if (value.length <= 2) {
                      return 'Surname at least 3 character long!';
                    }
                    return null;
                  },
                  controller: _surnameCon,
                  textInputAction: userData.role == Roles.student
                      ? TextInputAction.next
                      : TextInputAction.done,
                ),
                SizedBox(height: 20),

                //! if student then he has to add enrollment no
                if (userData.role == Roles.student &&
                    userData.enrollment.isEmpty)
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      labelText: 'Enter your enrollment no',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter enrollment no!';
                      } else if (value.length != 12) {
                        return 'Please enter valid enrollment no!';
                      }
                      return null;
                    },
                    controller: _enrollmentCon,
                    textInputAction: userData.role == Roles.student
                        ? TextInputAction.done
                        : TextInputAction.next,
                  ),
                SizedBox(height: 20),

                //! selected gender
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
                          selectedGender = newValue!;
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
    );
  }
}
