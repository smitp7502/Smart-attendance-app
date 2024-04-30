// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:attend/providers/class_data_provider.dart';
import 'package:attend/screens/faculty_screens/attance_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassCard extends StatelessWidget {
  final String id;
  final String session;
  final String classCode;
  final String className;
  const ClassCard(
      {required this.id,
      required this.session,
      required this.classCode,
      required this.className,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      height: 170,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(AttandanceClassScreen.routeName, arguments: id);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Class : $className',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              alignment: Alignment.center,
                              scale: 0.5,
                              image: AssetImage(session == 'online'
                                  ? 'assets/images/online.png'
                                  : 'assets/images/offline.png')),
                          boxShadow: [
                            BoxShadow(
                              color: session == 'online'
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle),
                    ),
                    SizedBox(height: 20),
                    Text(
                      session,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              session == 'online' ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Text('Attandance code'),
                        Text(
                          classCode,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Consumer<ClassProvider>(
                      builder: (ctx, data, _) => Text(
                        'Attandance : ${data.getAttendance(id)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
