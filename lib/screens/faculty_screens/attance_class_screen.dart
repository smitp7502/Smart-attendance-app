// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';

import 'package:attend/providers/class_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class AttandanceClassScreen extends StatefulWidget {
  static const routeName = '/attandace-class-screen';

  AttandanceClassScreen({super.key});

  @override
  State<AttandanceClassScreen> createState() => _AttandanceClassScreenState();
}

class _AttandanceClassScreenState extends State<AttandanceClassScreen> {
  final _enrollmentCon = TextEditingController();
  var path;

  var _isLoading = false;
  var _isEnd = false;

  Widget _DialogWithTextField(BuildContext context, String id) => Container(
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
              "Enter Enrollment No Mannualy",
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
                  controller: _enrollmentCon,
                  maxLines: 1,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enrollment No',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () {
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
                    setState(() {
                      _isLoading = true;
                    });
                    if (_enrollmentCon.text.length != 12) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enter valid enrollment no')));
                      return;
                    }
                    try {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('classes')
                          .doc(id)
                          .get();
                      final data = snapshot.data() as Map<String, dynamic>;
                      List<String> attendanceList =
                          List<String>.from(data['attendance']);
                      if (attendanceList.contains(_enrollmentCon.text)) {
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).clearSnackBars();

                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Attendance already taken!!')));
                        return;
                      }

                      attendanceList.add(_enrollmentCon.text);
                      attendanceList.sort();
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .doc(id)
                          .update({
                        'attendance': attendanceList,
                      });
                      setState(() {
                        _isLoading = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Attendance taken successfully!')));
                    } on FirebaseException catch (e) {
                      print('Firebase error');
                      print(e.message);
                    } catch (e) {
                      print('error');
                      print(e.toString());
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ],
        ),
      );

  Widget buildRow2(String no, String enrollmentNo, int i) => Container(
        height: 40,
        decoration: BoxDecoration(
          color: i.isOdd ? Colors.grey.shade100 : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 130,
              padding: EdgeInsets.only(left: 10),
              child: Text(no,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            VerticalDivider(
              width: 0.5,
              color: Colors.black26,
            ),
            SizedBox(
              width: 10,
            ),
            Text(enrollmentNo,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
          ],
        ),
      );

  Widget buildRow1(String title, String content) => Row(
        children: [
          Text(title, style: TextStyle(fontSize: 15)),
          Text(
            content,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments.toString();

    final classProvider = Provider.of<ClassProvider>(context);

    final classData = classProvider.getClassModelById(id!);
    final session = classData.session;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 6,
                        backgroundColor: Colors.transparent,
                        child: _DialogWithTextField(context, id),
                      );
                    });
              },
              icon: Icon(Icons.add),
            ),
          )
        ],
        title: Text('Attandance Sheet'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Column(
                children: [
                  //
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    height: 180,
                    width: double.infinity,
                    color: session == 'online'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            buildRow1('Branch : ', classData.branch),
                            buildRow1(
                                'Semester : ', classData.semester.toString()),
                            buildRow1('Division : ', classData.divison),
                            buildRow1('Subject : ', classData.subject),
                            buildRow1('Class code : ', classData.classCode),
                            buildRow1('Session : ', session),
                          ],
                        ),
                        Positioned(
                          bottom: 5,
                          right: 8,
                          child: buildRow1('Attendance : ',
                              '${classData.attendance == null ? 0 : classData.attendance!.length}'),
                        )
                      ],
                    ),

                    //
                  ),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                    ),
                    child: Expanded(
                      child: Column(
                        children: [
                          buildRow2('No.', 'Enrollment no.', 1),
                          Divider(height: 0.5, color: Colors.black26),
                          Expanded(
                            child: Consumer<ClassProvider>(
                              builder: (ctx, classProvider, _) =>
                                  RefreshIndicator(
                                onRefresh: () =>
                                    classProvider.fetchAttandance(id),
                                child: ListView.separated(
                                    itemBuilder: (ctx, i) {
                                      final enromment =
                                          classData.attendance![i];
                                      return buildRow2(
                                          '${i + 1}.', '$enromment', i);
                                    },
                                    separatorBuilder: (ctx, i) => Divider(
                                        height: 0.5, color: Colors.black26),
                                    itemCount: classData.attendance == null
                                        ? 0
                                        : classData.attendance!.length),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  ElevatedButton(
                      onPressed: session != 'online'
                          ? null
                          : () async {
                              setState(() {
                                _isEnd = true;
                              });
                              await classProvider.makeOfflineSession(id);
                              setState(() {
                                _isEnd = false;
                              });
                            },
                      child: _isEnd
                          ? CircularProgressIndicator()
                          : Text(session == 'online'
                              ? 'End Session!'
                              : 'Session ended!')),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // if (classData.attendance!.isNotEmpty) {
          //   LocalNotificationService().showNotificationAndroid(
          //       "Pdf downloaded successfully", "xyz.pdf");
          // } else {
          //   ScaffoldMessenger.of(context).clearSnackBars();
          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       duration: Duration(seconds: 2),
          //       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          //       content: Expanded(
          //           child: Row(
          //         children: [
          //           Text('No attendance taken'),
          //           Spacer(),
          //           TextButton(
          //               onPressed: () {
          //                 ScaffoldMessenger.of(context).clearSnackBars();
          //               },
          //               child: Text('Okay!!'))
          //         ],
          //       ))));
          // }
          final data = await generatePDF(context, id);
          await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => data);
        },
        tooltip: 'Download pdf',
        child: Icon(Icons.download),
      ),
    );
  }
}

Future<Uint8List> generatePDF(BuildContext context, String id) async {
  final pdf = pw.Document();
  final classProvider = Provider.of<ClassProvider>(context, listen: false);

  final classData = classProvider.getClassModelById(id);

  List<String> classAttendance = classData.attendance!.cast<String>();

  var enrollmentNo = 1;
  // Create the first page of the PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              text:
                  '${classData.semester} ${classData.branch}-${classData.divison} Attendance sheet',
              // style: pw.TextStyle(fontSize: 20),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Faculty Name: ${classData.facultyName}',
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.Text(
              'Subject Name: ${classData.subject}',
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              data: <List<String>>[
                <String>['No.', 'Enrollment No.'],
                ...classAttendance
                    .map((enrollment) => ['${enrollmentNo++}', enrollment])
                    .toList(),
              ],
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}
