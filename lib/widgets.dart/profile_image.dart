import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.selectedGender,
  });

  final String selectedGender;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage(selectedGender == 'Male'
                ? 'assets/images/male_profile_image.png'
                : selectedGender == 'Female'
                    ? 'assets/images/female_profile_image.png'
                    : 'assets/images/profile_image.png'), // Change this to your profile picture
          ),
        ),
      ],
    );
  }
}
