import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/presentation/views/activities.view.dart';
import 'package:letdem/features/users/presentation/views/profile.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/map/presentation/views/home.view.dart';
import 'package:letdem/infrastructure/ws/web_socket.service.dart';

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  int _selectedIndex = 0;
  late UserWebSocketService _userWebSocketService;

  final List<Widget> _pages = [
    const HomeView(),
    const ActivitiesView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserWebSocket();
  }

  void _initializeUserWebSocket() {
    _userWebSocketService = UserWebSocketService();
    _userWebSocketService.connect(
      onEvent: (event) {
        if (kDebugMode) {
          Toast.show('UserWebSocket Event: $event');
        }
        // Handle user data update event
        _handleUserDataUpdate(event);
      },
      onError: (error) {
        if (kDebugMode) {
          Toast.showError('UserWebSocket Error: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          Toast.show('UserWebSocket connection closed');
        }
        debugPrint('UserWebSocket connection closed');
      },
    );
  }

  void _handleUserDataUpdate(Map<String, dynamic> event) {
    if (mounted) {
      context.read<UserBloc>().add(const FetchUserInfoEvent(isSilent: true));
      context.read<CarBloc>().add(const GetCarEvent());
      context.read<ActivitiesBloc>().add(GetActivitiesEvent());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        context.read<CarBloc>().add(const GetCarEvent());
        context.read<ActivitiesBloc>().add(GetActivitiesEvent());
        context.read<UserBloc>().add(const FetchUserInfoEvent(isSilent: true));
        break;
      case 2:
        break;
      default:
    }
  }

  @override
  void dispose() {
    _userWebSocketService.disconnect();
    super.dispose();
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
        body: IndexedStack(index: _selectedIndex, children: _pages),
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
                  _selectedIndex == 0 ? IconlyBold.home : IconlyLight.home,
                ),
                label: context.l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 1
                      ? IconlyBold.activity
                      : IconlyLight.activity,
                ),
                label: context.l10n.activities,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 2
                      ? IconlyBold.profile
                      : IconlyLight.profile,
                ),
                label: context.l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
