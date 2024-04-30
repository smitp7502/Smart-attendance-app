// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'dart:math';

import 'package:attend/providers/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CreateAttendacneSheet extends StatefulWidget {
  static const routeName = '/create-attendance-sheet-screen';
  const CreateAttendacneSheet({super.key});

  @override
  State<CreateAttendacneSheet> createState() => CreateAttendacneSheetState();
}

class CreateAttendacneSheetState extends State<CreateAttendacneSheet> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  final _branchCon = TextEditingController();
  final _semCon = TextEditingController();
  final _divisionCon = TextEditingController();
  final _subjectCon = TextEditingController();

  String generateRandomString() {
    const String capitalLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String smallLetters = "abcdefghijklmnopqrstuvwxyz";
    const String numerics = "0123456789";
    const String specialCharacters = "!-@/\\";
    Random random = Random();

    String result = '';

    for (int i = 0; i < 3; i++) {
      result += capitalLetters[random.nextInt(capitalLetters.length)];
    }

    for (int i = 0; i < 2; i++) {
      result += smallLetters[random.nextInt(smallLetters.length)];
    }

    for (int i = 0; i < 2; i++) {
      result += specialCharacters[random.nextInt(specialCharacters.length)];
    }

    for (int i = 0; i < 3; i++) {
      result += numerics[random.nextInt(numerics.length)];
    }

    List<String> characters = result.split('');
    characters.shuffle();
    result = characters.join('');

    return result;
  }

  void getClassCode() async {
    bool isValid = _formKey.currentState!.validate();
    var facultyName =
        Provider.of<UserDataProvider>(context, listen: false).facultyName;

    if (!isValid) {
      return;
    }

    final classCode = generateRandomString();
    final attendance = [];
    final data = {
      'branch': _branchCon.text.trim(),
      'semester': int.parse(_semCon.text.trim()),
      'division': _divisionCon.text.trim(),
      'subject': _subjectCon.text.trim(),
      'faculty': facultyName,
      'classCode': classCode,
      'session': 'online',
      'createdAt': Timestamp.now(),
      'facultyId': FirebaseAuth.instance.currentUser!.uid,
      'attendance': attendance,
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
    };
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('classes').add(data);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(
                  'Attendance sheet code is ',
                  style: TextStyle(fontSize: 16),
                ),
                content: Text(
                  classCode,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay!'))
                ],
              ));
    } on FirebaseException catch (e) {
      print('Firebase error ----------->');
      print(e.code);
      print(e.message);
    } catch (e) {
      print('Last catch error ----------->');
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create attendance sheet'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(label: Text("Enter branch name")),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _branchCon,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter branch name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(label: Text("Enter semster")),
                      textInputAction: TextInputAction.next,
                      controller: _semCon,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter semster';
                        } else if (int.tryParse(value)! > 8 ||
                            int.tryParse(value) == 0) {
                          return 'Please enter valid semester';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(label: Text("Enter class division")),
                      textInputAction: TextInputAction.next,
                      controller: _divisionCon,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter class division';
                        }
                        return null;
                      },
                      maxLength: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(label: Text("Enter subject name")),
                      textInputAction: TextInputAction.done,
                      controller: _subjectCon,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter subject name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () async {
                          getClassCode();
                        },
                        child: Text('Ganerate class code')),
                    SizedBox(height: 30)
                  ],
                ),
        ),
      ),
    );
  }
}
