// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:async';

import 'package:attend/providers/class_data_provider.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/create_attandance_sheet.dart';
import 'package:attend/screens/faculty_screens/profile_details_screen.dart';
import 'package:attend/screens/faculty_screens/widgets/class_card.dart';
import 'package:attend/widgets.dart/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FacultyHomeScreen extends StatefulWidget {
  const FacultyHomeScreen({super.key});

  static const routeName = '/faculty-home-screen';

  @override
  State<FacultyHomeScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyHomeScreen> {
  bool _isLoading = false;
  bool profilDataFilled = false;
  bool _isInit = true;

  // @override
  // void initState() {
  //   setState(() {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //   });
  //   // Future.delayed(Duration.zero).then((value) {
  //   //   Provider.of<ClassProvider>(context, listen: false).fetchClassesData();
  //   // });
  //   Future.delayed(Duration.zero)
  //       .then((value) => Provider.of<UserDataProvider>(context, listen: false)
  //           .fetchAndSetUserData())
  //       .then((value) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  void didChangeDependencies() async {
    setState(() {
      _isLoading = true;
    });
    if (_isInit) {
      await Provider.of<UserDataProvider>(context, listen: false)
          .fetchAndSetUserData();
      setState(() {
        _isInit = false;
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Class attendances'),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () => Provider.of<ClassProvider>(context, listen: false)
              .fetchClassesData(),
          child: Consumer<ClassProvider>(
              builder: (ctx, data, _) => data.classes.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 1.2,
                          child: Center(
                            child: Column(
                              children: const [
                                Text('No Attendance Sheet'),
                                Text('Pull donw to refresh')
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemBuilder: (ctx, i) {
                        final d = data.classes[i];
                        return ClassCard(
                          id: d.classId,
                          session: d.session,
                          classCode: d.classCode,
                          className: '${d.semester}th ${d.branch}-${d.divison}',
                        );
                      },
                      itemCount: data.classes.length,
                    )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<UserDataProvider>(context, listen: false).name ==
              null) {
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      content: Text(
                        'To create class attendance sheet first you have to fill your profile detials',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                profilDataFilled = true;
                              });

                              Navigator.pop(context);
                            },
                            child: Text('Okay!'))
                      ],
                    )).then((value) {
              if (profilDataFilled) {
                Navigator.pushReplacementNamed(
                    context, ProfileDetailScreen.routeName);
              }
            });
          } else {
            Navigator.pushNamed(context, CreateAttendacneSheet.routeName);
          }
        },
        tooltip: 'Create Class',
        child: Icon(Icons.add),
      ),
    );
  }
}
