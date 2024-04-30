import 'package:attend/constants.dart/enums.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/auth_screen.dart';
import 'package:attend/screens/faculty_screens/faculty_home_screen.dart';

import 'package:attend/screens/student_screens/screens/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (ctx, data, _) => StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return const AuthScreen();
            } else {
              return data.role == Roles.student
                  ? const StudentScreen()
                  : const FacultyHomeScreen();
            }
          }),
    );
  }
}
