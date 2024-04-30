// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:attend/constants.dart/enums.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Roles _currRole = Roles.student;
  bool _isLoading = false;
  bool _isSignup = false;

  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPass = TextEditingController();

  trySubmit() async {
    bool isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // Provider.of<AuthDataProvider>(context, listen: false).tryAuthenticate(
      //     _isSignup, _email.text, _password.text, _currRole.name);
      print(_isSignup);

      if (_isSignup) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.text, password: _password.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'role': _currRole.name,
          'email': _email.text,
        });
        Provider.of<UserDataProvider>(context, listen: false)
            .setRoleEmail(_currRole, _email.text);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.text, password: _password.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('firebase errror------------------here');
      print(e.code);
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Error Occured'),
                content: Text(e.message.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Okay'))
                ],
              ));
    } catch (e) {
      print('errror------------------here');
      setState(() {
        _isLoading = false;
      });
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Something went wrong'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Okay'))
                ],
              ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  //! title logo
                  Container(
                    alignment: Alignment.center,
                    height: 90,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.orange.shade400,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Attend',
                          style: GoogleFonts.aBeeZee(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Smart Attendance App',
                          style: GoogleFonts.aBeeZee(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //! authentication form
                  Consumer<UserDataProvider>(
                    builder: (ctx, data, _) => SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Card(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              data.isSignup
                                  //! show for which role you have to signup
                                  ? Text(
                                      _currRole.name == 'faculty'
                                          ? 'Faculty Signup Screen'
                                          : 'Student Signup Screen',
                                      style: const TextStyle(fontSize: 30),
                                    )
                                  : Container(),

                              //! textfields
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      //! email
                                      TextFormField(
                                        decoration: const InputDecoration(
                                            label: Text('Email Address')),
                                        controller: _email,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter email';
                                          } else if (!value.contains('@')) {
                                            return 'Please enter valid email';
                                          }
                                          return null;
                                        },
                                      ),

                                      //! password
                                      TextFormField(
                                        decoration: const InputDecoration(
                                            label: Text('Password')),
                                        obscureText: true,
                                        controller: _password,
                                        textInputAction: data.isSignup
                                            ? TextInputAction.next
                                            : TextInputAction.done,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter password';
                                          } else if (value.length < 7) {
                                            return 'Password length at least 7';
                                          }
                                          return null;
                                        },
                                      ),

                                      //! confirm password
                                      data.isSignup
                                          ? TextFormField(
                                              decoration: const InputDecoration(
                                                  label:
                                                      Text('Confirm Password')),
                                              obscureText: true,
                                              controller: _confirmPass,
                                              textInputAction: data.isSignup
                                                  ? TextInputAction.done
                                                  : null,
                                              validator: (value) {
                                                if (value != _password.text) {
                                                  return 'Password isn\'t same';
                                                }
                                                return null;
                                              },
                                            )
                                          : Container(),
                                      const SizedBox(height: 20),

                                      //! signup signin button
                                      data.isSignup
                                          ? ElevatedButton(
                                              onPressed: () {
                                                trySubmit();
                                              },
                                              child: const Text('Sign Up'))
                                          : ElevatedButton(
                                              onPressed: () {
                                                trySubmit();
                                              },
                                              child: const Text('Sign In')),

                                      //! switch btw signup and signin
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              data.changePage();
                                              _isSignup = !_isSignup;
                                              print(_isSignup);
                                            });
                                          },
                                          child: data.isSignup
                                              ? const Text(
                                                  'Already have an account?')
                                              : const Text(
                                                  'Create a new account')),

                                      //! swithc btw student & faculty
                                      data.isSignup
                                          ? TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (_currRole ==
                                                      Roles.student) {
                                                    _currRole = Roles.faculty;
                                                    data.setRole(_currRole);
                                                  } else {
                                                    _currRole = Roles.student;
                                                    data.setRole(_currRole);
                                                  }
                                                });
                                              },
                                              child: _currRole == Roles.student
                                                  ? const Text(
                                                      'Credential Screen for Faculty')
                                                  : const Text(
                                                      'Credential Screen for Student'))
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
