import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthDataProvider extends ChangeNotifier {
  Future<void> tryAuthenticate(
      bool isSignup, String email, String password, String role) async {
    try {
      if (isSignup) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'role': role,
          'email': email,
        });
        // Provider.of<UserDataProvider>(context, listen: false)
        //     .setRoleEmail(_currRole, _email.text);
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseException catch (e) {
      print('Firebase error -------------------->');
      print(e.message);
      rethrow;
    } catch (e) {
      print('error--------------?');
      print(e.toString());
      rethrow;
    }
  }
}
