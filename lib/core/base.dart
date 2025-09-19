import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:iconly/iconly.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/presentation/views/activities.view.dart';
import 'package:letdem/features/users/presentation/views/profile.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

import '../features/map/presentation/views/home.view.dart';
import '../infrastructure/ws/web_socket.service.dart';

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
      onDone: () {},
    );
  }

  void _handleUserDataUpdate(Map<String, dynamic> event) {
    if (mounted) {
      context.read<UserBloc>().add(const FetchUserInfoEvent(isSilent: true));

      if (_selectedIndex == 1) {
        context.read<ActivitiesBloc>().add(GetActivitiesEvent());
      }
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
// Debug Stats Component for NavigationView
// Add this as a separate widget file or inline in your NavigationView

class NavigationDebugStats extends StatelessWidget {
  final bool isLocationReady;
  final bool isMapReady;
  final bool isNavigating;
  final bool isLoading;
  final HERE.GeoCoordinates? currentLocation;
  final double currentSpeed;
  final int distanceRemaining;
  final int totalRouteTime;
  final String navigationInstruction;
  final HERE.SpeedLimit? roadSpeedLimit;
  final bool isOverSpeedLimit;
  final bool isMuted;
  final bool isCameraLocked;
  final bool isUserPanning;
  final bool isRecalculatingRoute;
  final String errorMessage;
  final int distanceTraveled;
  final bool hasShownArrivalNotification;
  final bool hasShownParkingRating;
  final bool isWebSocketConnected;
  final int nextManeuverDistance;

  const NavigationDebugStats({
    Key? key,
    required this.isLocationReady,
    required this.isMapReady,
    required this.isNavigating,
    required this.isLoading,
    this.currentLocation,
    required this.currentSpeed,
    required this.distanceRemaining,
    required this.totalRouteTime,
    required this.navigationInstruction,
    this.roadSpeedLimit,
    required this.isOverSpeedLimit,
    required this.isMuted,
    required this.isCameraLocked,
    required this.isUserPanning,
    required this.isRecalculatingRoute,
    required this.errorMessage,
    required this.distanceTraveled,
    required this.hasShownArrivalNotification,
    required this.hasShownParkingRating,
    required this.isWebSocketConnected,
    required this.nextManeuverDistance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade400, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.green.shade400, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'DEBUG STATS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // System Status
            _buildSection('SYSTEM STATUS', [
              _buildStatusRow('Location Ready', isLocationReady),
              _buildStatusRow('Map Ready', isMapReady),
              _buildStatusRow('Navigation Active', isNavigating),
              _buildStatusRow('Loading', isLoading),
              _buildStatusRow('WebSocket', isWebSocketConnected),
            ]),

            // Location Info
            if (currentLocation != null)
              _buildSection('LOCATION', [
                _buildInfoRow(
                  'Latitude',
                  '${currentLocation?.latitude.toStringAsFixed(6)}',
                ),
                _buildInfoRow(
                  'Longitude',
                  '${currentLocation?.longitude.toStringAsFixed(6)}',
                ),
                _buildInfoRow(
                  'Speed',
                  '${(currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                ),
                _buildInfoRow('Distance Traveled', '${distanceTraveled}m'),
              ]),

            // Navigation Info
            if (isNavigating)
              _buildSection('NAVIGATION', [
                _buildInfoRow(
                  'Distance Remaining',
                  '${(distanceRemaining / 1000).toStringAsFixed(2)} km',
                ),
                _buildInfoRow(
                  'Time Remaining',
                  '${(totalRouteTime / 60).toStringAsFixed(0)} min',
                ),
                _buildInfoRow('Next Maneuver', '${nextManeuverDistance}m'),
                if (navigationInstruction.isNotEmpty)
                  _buildInfoRow(
                    'Instruction',
                    navigationInstruction,
                    maxLines: 2,
                  ),
              ]),

            // Speed Limit Info
            if (roadSpeedLimit != null)
              _buildSection('SPEED LIMIT', [
                _buildInfoRow(
                  'Limit',
                  '${(roadSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).toStringAsFixed(0)} km/h',
                ),
                _buildStatusRow('Over Limit', isOverSpeedLimit),
              ]),

            // UI State
            _buildSection('UI STATE', [
              _buildStatusRow('Audio Muted', isMuted),
              _buildStatusRow('Camera Locked', isCameraLocked),
              _buildStatusRow('User Panning', isUserPanning),
              _buildStatusRow('Recalculating', isRecalculatingRoute),
              _buildStatusRow('Arrival Shown', hasShownArrivalNotification),
              _buildStatusRow('Rating Shown', hasShownParkingRating),
            ]),

            // Error Info
            if (errorMessage.isNotEmpty)
              _buildSection('ERROR', [
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.green.shade400,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white60, fontSize: 9),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontFamily: 'monospace',
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
