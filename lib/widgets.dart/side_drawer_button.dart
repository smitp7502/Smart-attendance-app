// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SideDrawerButton extends StatelessWidget {
  const SideDrawerButton(
      {required this.title, required this.func, required this.icon, super.key});
  final Function() func;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          trailing: Icon(
            icon,
            size: 25,
          ),
          splashColor: Colors.pink.shade50,
          onTap: () async {
            func();
          },
        ),
        Divider(
          thickness: 0.5,
          color: Colors.black,
        ),
      ],
    );
  }
}
