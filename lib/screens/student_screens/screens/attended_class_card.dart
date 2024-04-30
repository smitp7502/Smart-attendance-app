import 'package:flutter/material.dart';

class AttendedClassCard extends StatelessWidget {
  const AttendedClassCard(
      {required this.faculty,
      required this.date,
      required this.subject,
      super.key});
  final faculty;
  final subject;
  final date;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 250,
                  child: Text(
                    'Faculty : $faculty',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Spacer(),
                Text('$date'),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Subject : $subject',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
