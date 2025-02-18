import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/views/app/activities/screens/activities.view.dart';
import 'package:letdem/views/app/profile/profile.view.dart';

import 'home/home.view.dart';

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeView(),
    const ActivitiesView(),
    const ProfileView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // body: _pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary400,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 0 ? IconlyBold.home : IconlyLight.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? IconlyBold.activity
                  : IconlyLight.activity),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2
                  ? IconlyBold.profile
                  : IconlyLight.profile),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
