// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'package:attend/screens/student_screens/screens/attended_class_card.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/profile_details_screen.dart';
import 'package:attend/widgets.dart/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  static const routeName = '/student-home-screen';

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool profilDataFilled = false;

  final _classCodeCon = TextEditingController();

  _displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 6,
            backgroundColor: Colors.transparent,
            child: _DialogWithTextField(context),
          );
        });
  }

  Widget _DialogWithTextField(BuildContext context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              "Enter class code here",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 10),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                child: TextFormField(
                  controller: _classCodeCon,
                  maxLines: 1,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Class code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text(
                    "Save".toUpperCase(),
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () async {
                    var alertMessage = '';
                    bool isAttended = false;
                    final userDataProvider =
                        Provider.of<UserDataProvider>(context, listen: false);
                    try {
                      //   DocumentSnapshot userDataSnap = await FirebaseFirestore
                      //       .instance
                      //       .collection('users')
                      //       .doc(userDataProvider.uid)
                      //       .get();
                      //   final Map<String, dynamic> userData =
                      //       userDataSnap.data() as Map<String, dynamic>;
                      // QueryDocumentSnapshot attendedClassData =
                      //     userData['attendedClasses'] ?? [];

                      QuerySnapshot classDataSnap = await FirebaseFirestore
                          .instance
                          .collection('classes')
                          .get();

                      final Map<String, dynamic> attendedClassesData =
                          userDataProvider.attendedClassess;
                      final attendedClassId = attendedClassesData.keys;

                      for (QueryDocumentSnapshot classDocument
                          in classDataSnap.docs) {
                        final classId = classDocument.id;
                        final classData =
                            classDocument.data() as Map<String, dynamic>;

                        if (_classCodeCon.text == classData['classCode']) {
                          if (attendedClassId.contains(classId)) {
                            print('already taken attendance');
                            alertMessage = 'The attendance is already taken';
                            isAttended = true;
                            break;
                          }
                          if (classData['session'] == 'online') {
                            userDataProvider.takeAttendance(
                                classId,
                                classData['faculty'],
                                classData['subject'],
                                classData['date']);

                            print('take attendance');
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userDataProvider.uid)
                                .update({
                              'attendedClasses':
                                  userDataProvider.attendedClassess,
                            });
                            final List<String?> attendance =
                                List<String?>.from(classData['attendance']);
                            attendance.add(userDataProvider.enrollment);
                            attendance.sort();
                            await FirebaseFirestore.instance
                                .collection('classes')
                                .doc(classId)
                                .update({
                              'attendance': attendance,
                            });
                            print('successfully attended');
                            alertMessage = 'Attendance is taken sucessfully';
                            isAttended = true;
                            break;
                          } else {
                            print('session offline');
                            alertMessage = 'Session is offline';
                            isAttended = true;
                            break;
                          }
                        }
                      }
                      if (!isAttended) {
                        print('wrong code');
                        alertMessage = 'Enterd code is wrong';
                      }

                      Navigator.pop(context);
                      _classCodeCon.clear();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(alertMessage)));
                    } on FirebaseException catch (e) {
                      print('firebase --------------------------->');
                      print(e.code);
                      print(e.message);
                    } catch (e) {
                      print('error --------------------------->');
                      print(e.toString());
                    }
                  },
                )
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Attended class'),
      ),
      body: Consumer<UserDataProvider>(
          builder: (ctx, data, _) => RefreshIndicator(
              child: data.attendedClassess.isEmpty
                  ? ListView(children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 1.2,
                        child: Center(
                          child: Column(
                            children: const [
                              Text('No attended classes'),
                              Text('Pull donw to refresh')
                            ],
                          ),
                        ),
                      ),
                    ])
                  : ListView.builder(
                      itemBuilder: (ctx, i) {
                        final d = data.attendedClassess.values.toList();
                        return AttendedClassCard(
                            faculty: d[i][0], date: d[i][2], subject: d[i][1]);
                      },
                      itemCount: data.attendedClassess.length,
                    ),
              onRefresh: () => data.fetchAttendedClass())),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<UserDataProvider>(context, listen: false).name ==
              null) {
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text('First you have to fill profile data'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                profilDataFilled = true;
                              });

                              Navigator.pop(context);
                            },
                            child: Text('Click here'))
                      ],
                    )).then((value) {
              if (profilDataFilled) {
                Navigator.pushReplacementNamed(
                    context, ProfileDetailScreen.routeName);
              }
            });
          } else {
            _displayDialog(context);
          }
        },
        child: Icon(Icons.note_add_rounded),
      ),
    );
  }
}
