import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/presentation/views/activities.view.dart';
import 'package:letdem/features/users/presentation/views/profile.view.dart';

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
    switch (index) {
      case 0:
        break;
      case 1:
        context.read<ActivitiesBloc>().add(GetActivitiesEvent());
      case 2:
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                label: context.l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1
                    ? IconlyBold.activity
                    : IconlyLight.activity),
                label: context.l10n.activities,
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 2
                    ? IconlyBold.profile
                    : IconlyLight.profile),
                label: context.l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
