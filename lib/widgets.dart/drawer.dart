// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/profile_details_screen.dart';
import 'package:attend/widgets.dart/profile_image.dart';
import 'package:attend/widgets.dart/side_drawer_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideDrawer extends StatelessWidget {
  SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.pink.shade400,
            height: 30,
          ),
          Container(
            color: Colors.pink.shade400,
            height: 150,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProfileImage(
                  selectedGender: userData.gender,
                ),
                Text(
                  userData.facultyName.toString(),
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),

          //
          SideDrawerButton(
            title: 'Edit Profile',
            func: () {
              Navigator.of(context).pushNamed(ProfileDetailScreen.routeName);
            },
            icon: Icons.edit,
          ),
          SideDrawerButton(
            title: 'Logout',
            func: () => FirebaseAuth.instance.signOut(),
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }
}
