// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:flutter/material.dart';
import 'package:telehealth_app/ui/features/homepage/homepage_views/homepage.dart';
import 'package:telehealth_app/ui/features/profile_view/profile_view.dart';
import 'package:telehealth_app/ui/features/schedule/schedule_view/schedule_view.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key, required this.color});
  final Color color;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int screenIndex = 0;
  String senderName = "";
  List tabScreenList = [
    HomepageView(),
    const ScheduleView(),
    const ProfilePageView()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indexNumber) {
          setState(() {
            screenIndex = indexNumber;
          });
        },
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade600,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.file_copy_outlined,
              size: 30,
            ),
            label: "Record",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.notifications,
          //     size: 30,
          //   ),
          //   label: "",
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: tabScreenList[screenIndex],
    );
  }
}
