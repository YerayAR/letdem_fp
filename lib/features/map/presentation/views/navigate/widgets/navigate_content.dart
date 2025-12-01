// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as HERE;
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/time.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../common/popups/popup.dart';
import '../../../../../../common/widgets/button.dart';
import '../../../../../../core/constants/assets.dart';
import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/dimens.dart';
import '../../../../../../models/navigation/navigation_stop.model.dart';
import '../../../../../activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import '../../../../../activities/presentation/widgets/search/search_bottom_sheet.widget.dart';
import '../../../widgets/navigation/stops_list.widget.dart';
import 'navigate_bottom.dart';

enum _Direction { none, left, straight, right, uTurn }

class NavigateContent extends StatefulWidget {
  NavigateContent({
    super.key,
    required this.isCameraLocked,
    required this.speed,
    required this.isLoading,
    this.onMapCreated,
    this.mapPadding = 15,
    this.buttonRadius = 26,
    this.heightContainer = 100,
    required this.isLimit,
    required this.toggleCameraTracking,
    required this.isNavigating,
    this.borderRadius = 20,
    required this.onError,
    required this.errorMessage,
    required this.navigationInstruction,
    required this.isMuted,
    required this.onMuted,
    required this.normalManuevers,
    required this.distanceNotifier,
    required this.nextManuoverDistance,
    required this.isLocationReady,
    required this.isMapReady,
    required this.isRecalculatingRoute,
    required this.stopNavigation,
    required this.isOpenRoutes,
    required this.openRouter,
    required this.totalRouteTime,
    required this.distanceValue,
    required this.routesList,
    required this.startGuidance,
    required this.indexRoute,
    this.onAddStop,
    this.navigationStops,
    this.currentStopIndex,
  });

  final Function(HereMapController)? onMapCreated;
  final double mapPadding;
  final double buttonRadius;
  final bool isCameraLocked;
  final double heightContainer;
  final bool isLimit;
  final double speed;
  final bool isLoading;
  final VoidCallback toggleCameraTracking;
  final bool isNavigating;
  final double borderRadius;
  final VoidCallback onError;
  final String errorMessage;
  final String navigationInstruction;
  final bool isMuted;
  final VoidCallback onMuted;
  final String normalManuevers;
  final ValueNotifier<int> distanceNotifier;
  final int nextManuoverDistance;
  final bool isLocationReady;
  final bool isMapReady;
  final bool isRecalculatingRoute;
  final VoidCallback stopNavigation;
  final bool isOpenRoutes;
  final VoidCallback openRouter;
  final String totalRouteTime;
  final String distanceValue;
  final List<HERE.Route> routesList;
  final Function(int indexRoute) startGuidance;
  final int indexRoute;
  final Function(
    double? latitude,
    double? longitude,
    String streetName,
    String? pId,
  )?
  onAddStop;
  final List<NavigationStop>? navigationStops;
  final int? currentStopIndex;

  String get distance {
    return "${(totalRouteTime)} ($distanceValue)";
  }

  final Map<String, IconData> directionIcons = {
    'turn right': Icons.turn_right,
    'turn left': Icons.turn_left,
    'go straight': Icons.arrow_upward,
    'make a u-turn': Icons.u_turn_left,
  };

  @override
  State<NavigateContent> createState() => _NavigateContentState();
}

class _NavigateContentState extends State<NavigateContent>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        HereMap(onMapCreated: widget.onMapCreated),

        if (widget.isOpenRoutes)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: MediaQuery.of(context).padding.top + widget.mapPadding,
            bottom: 0,
            left: widget.mapPadding,
            right: widget.mapPadding,
            child: Column(
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.all(widget.mapPadding * .5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    dividerColor: Colors.transparent,
                    unselectedLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    tabs: const [Tab(text: 'Mapa'), Tab(text: 'Lista')],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [_tabMap(), _tabListRoutes()],
                  ),
                ),
              ],
            ),
          ),

        if (!widget.isOpenRoutes)
          NavigateBottom(
            mapPadding: widget.mapPadding,
            radius: widget.buttonRadius,
            speed: widget.speed,
            isLimit: widget.isLimit,
            height: widget.heightContainer,
          ),
        // if (kDebugMode) _buildWebSocketStatusIndicator(),
        if (widget.isLoading) _buildLoadingIndicator(),

        if (!widget.isOpenRoutes)
          Positioned(
            // top: MediaQuery.of(context).padding.top + 200,
            right: widget.mapPadding,
            bottom: widget.heightContainer + 15,
            child: Column(
              spacing: 15,
              children: [
                CircleAvatar(
                  radius: widget.buttonRadius,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      widget.isCameraLocked
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color:
                          widget.isCameraLocked
                              ? AppColors.primary500
                              : Colors.grey,
                    ),
                    onPressed: widget.toggleCameraTracking,
                    tooltip:
                        widget.isCameraLocked
                            ? context.l10n.freeCameraMode
                            : context.l10n.lockPositionMode,
                  ),
                ),

                CircleAvatar(
                  radius: widget.buttonRadius,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.circlePoint,
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () {},
                  ),
                ),

                CircleAvatar(
                  radius: widget.buttonRadius * 1.2,
                  backgroundColor: AppColors.primary500,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.addAlert,
                      width: 25,
                      height: 25,
                    ),
                    onPressed: () {
                      AppPopup.showBottomSheet(
                        context,
                        const AddEventBottomSheet(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        if (widget.errorMessage.isNotEmpty) _buildErrorMessage(),

        if (!widget.isOpenRoutes)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildNavigationInstructionCard(),
          ),
        if (widget.isNavigating && !widget.isOpenRoutes)
          Positioned(
            // bottom: 30,
            bottom: 0,
            left: widget.mapPadding,
            right: widget.mapPadding,
            child: _buildNavigationControls(),
          ),
      ],
    );
  }

  void _showStopsList(BuildContext context) {
    AppPopup.showBottomSheet(
      context,
      StopsListWidget(
        stops: widget.navigationStops!,
        currentStopIndex: widget.currentStopIndex ?? -1,
        onDismiss: () => Navigator.pop(context),
        onAddStop: () {
          Navigator.pop(context);
          _showAddStopSheet(context);
        },
      ),
    );
  }

  void _showAddStopSheet(BuildContext context) {
    AppPopup.showBottomSheet(
      context,
      MapSearchBottomSheet(
        title: context.l10n.addStop,
        hintText: context.l10n.searchStop,
        onLocationSelected: (latitude, longitude, step, pId) {
          if (widget.onAddStop != null) {
            widget.onAddStop!(latitude, longitude, step, pId);
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(context.l10n.preparingNavigation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: widget.mapPadding,
        vertical: widget.mapPadding + 5,
      ),
      height: widget.heightContainer,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: widget.buttonRadius,
          //   backgroundColor: const Color(0xFFF4F4F4),
          //   child: IconButton(
          //     icon: SvgPicture.asset(AppAssets.pointAdd, width: 16, height: 20),
          //     onPressed: () {
          //       AppPopup.showBottomSheet(context, const AddEventBottomSheet());
          //     },
          //   ),
          // ),
          // CircleAvatar(
          //   radius: widget.buttonRadius,
          //   backgroundColor: const Color(0xFFF4F4F4),
          //   child: IconButton(
          //     icon: const Icon(Icons.close, size: 20),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //   ),
          // ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: widget.buttonRadius,
                backgroundColor: const Color(0xFFF4F4F4),
                child: IconButton(
                  icon: SvgPicture.asset(
                    AppAssets.pointAdd,
                    width: 25,
                    height: 25,
                    color: const Color(0xFF445D6F),
                  ),
                  onPressed: () {
                    // If there are stops, show the stops list first
                    if (widget.navigationStops != null &&
                        widget.navigationStops!.isNotEmpty) {
                      _showStopsList(context);
                    } else {
                      // Otherwise, show search to add first stop
                      _showAddStopSheet(context);
                    }
                  },
                ),
              ),
              // Red badge indicator showing stop count
              if (widget.navigationStops != null &&
                  widget.navigationStops!.isNotEmpty)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.navigationStops!.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Lugar destino',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                widget.distance,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: widget.buttonRadius,
            backgroundColor: const Color(0xFFF4F4F4),
            child: IconButton(
              icon: SvgPicture.asset(
                AppAssets.altRoute,
                width: 16,
                height: 20,
                color: const Color(0xFF445D6F),
              ),
              tooltip: context.l10n.changeRoute,
              onPressed: widget.openRouter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(widget.errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onError.call,
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getManeuverIcon(int index) {
    // Map your route maneuver actions to icons
    // You'll need to access the actual maneuver data from your HERE SDK route
    // This is a placeholder - adjust based on your actual data structure
    final defaultIcons = [
      Icons.turn_slight_left,
      Icons.turn_slight_left,
      Icons.arrow_upward,
      Icons.turn_slight_right,
      Icons.turn_slight_right,
    ];

    return defaultIcons[index % defaultIcons.length];
  }

  Widget _buildNavigationInstructionCard() {
    IconData directionIcon = Icons.navigation;

    for (final entry in widget.directionIcons.entries) {
      if (widget.normalManuevers.toLowerCase().contains(entry.key)) {
        directionIcon = entry.value;
        break;
      }
    }

    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height:
                  widget.isNavigating &&
                          widget.navigationInstruction.isNotEmpty &&
                          widget.distanceNotifier.value > 0
                      ? 100
                      : 70,
              padding: EdgeInsets.only(
                top: widget.mapPadding,
                left: widget.mapPadding,
                right: widget.mapPadding,

                bottom: widget.mapPadding + 5,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                // borderRadius: BorderRadius.circular(_borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child:
                  widget.isNavigating &&
                          widget.navigationInstruction.isNotEmpty &&
                          widget.distanceNotifier.value > 0
                      ? Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.amber,
                            ),
                            child: Icon(
                              directionIcon,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          ValueListenableBuilder<int>(
                            valueListenable: widget.distanceNotifier,
                            builder: (context, state, _) {
                              return Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${widget.nextManuoverDistance.toFormattedDistance()} ${context.l10n.ahead}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      widget.navigationInstruction,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Dimens.space(1),
                          CircleAvatar(
                            backgroundColor: AppColors.neutral500.withOpacity(
                              0.5,
                            ),
                            child: IconButton(
                              icon: Icon(
                                widget.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: widget.onMuted.call,
                            ),
                          ),
                        ],
                      )
                      : Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.white.withOpacity(0.5),
                          highlightColor: Colors.grey[100]!,
                          child: Text(
                            _getCurrentLoadingMessage(context),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
            ),
            Builder(
              builder: (context) {
                final direction = _getActiveDirection(widget.normalManuevers);
                return Container(
                  height: 60,
                  decoration: BoxDecoration(color: AppColors.primary500),
                  child: Row(
                    children: [
                      _buildDirectionArrow(
                        icon: Icons.turn_left,
                        isActive: direction == _Direction.left,
                      ),
                      _buildSoftDivider(),
                      _buildDirectionArrow(
                        icon: Icons.arrow_upward,
                        isActive: direction == _Direction.straight,
                      ),
                      _buildSoftDivider(),
                      _buildDirectionArrow(
                        icon: Icons.turn_right,
                        isActive: direction == _Direction.right,
                      ),
                      _buildSoftDivider(),
                      _buildDirectionArrow(
                        icon: Icons.u_turn_left,
                        isActive: direction == _Direction.uTurn,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.mapPadding),
          child: CircleAvatar(
            radius: widget.buttonRadius,
            backgroundColor: const Color(0xFFF4F4F4),
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionArrow({
    required IconData icon,
    required bool isActive,
  }) {
    return Expanded(
      child: Center(
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          size: isActive ? 28 : 24,
        ),
      ),
    );
  }

  Widget _buildSoftDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.2),
    );
  }

  /// Determines the single active direction based on maneuver text
  /// Only ONE direction can be active at a time
  _Direction _getActiveDirection(String maneuver) {
    if (maneuver.isEmpty) return _Direction.none;

    final text = maneuver.toLowerCase();

    // Check U-turn first (highest priority)
    if (text.contains('u-turn') || text.contains('make a u')) {
      return _Direction.uTurn;
    }

    // Check for left turns
    if (text.contains('turn left') ||
        text.contains('sharp left') ||
        text.contains('slight left') ||
        text.contains('bear left') ||
        text.contains('keep left')) {
      return _Direction.left;
    }

    // Check for right turns
    if (text.contains('turn right') ||
        text.contains('sharp right') ||
        text.contains('slight right') ||
        text.contains('bear right') ||
        text.contains('keep right')) {
      return _Direction.right;
    }

    // Default to straight for continue, head, go straight, etc.
    if (text.contains('straight') ||
        text.contains('continue') ||
        text.contains('head') ||
        text.contains('follow') ||
        text.contains('stay')) {
      return _Direction.straight;
    }

    // If we have a maneuver but couldn't classify, default to straight
    return _Direction.straight;
  }

  String _getCurrentLoadingMessage(BuildContext context) {
    if (widget.errorMessage.isNotEmpty) {
      return widget.errorMessage;
    }
    if (!widget.isLocationReady) {
      return "Getting your location...";
    }
    if (!widget.isMapReady) {
      return "Initializing map services...";
    }
    if (widget.isLoading && !widget.isNavigating) {
      return "Calculating best route...";
    }
    if (widget.isRecalculatingRoute) {
      return "Recalculating route...";
    }
    return "Starting navigation...";
  }

  Widget _tabMap() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: widget.mapPadding,
          vertical: widget.mapPadding + 5,
        ),
        height: widget.heightContainer,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _tabItemInformation(
          distance: widget.distanceValue,
          time: widget.totalRouteTime,
          name: 'Via - lorem Ipsun',
        ),
      ),
    );
  }

  Widget _tabListRoutes() {
    return ListView.separated(
      itemCount: widget.routesList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      padding: const EdgeInsets.only(top: 30),
      itemBuilder: (_, index) {
        final item = widget.routesList[index];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: widget.mapPadding,
            vertical: widget.mapPadding,
          ),
          height: widget.heightContainer,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _tabItemInformation(
            distance: item.lengthInMeters.toFormattedDistance(),
            time: item.duration.inSeconds.toFormattedTime(),
            name: '',
            isSelected: widget.indexRoute == index,
            indexRoute: index,
          ),
        );
      },
    );
  }

  Widget _tabItemInformation({
    bool isSelected = true,
    int? indexRoute,
    required String distance,
    required String time,
    required String name,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.distanceValue,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              // Text(
              //   name,
              //   style: const TextStyle(color: Color(0xFF445D6F), fontSize: 15),
              // ),
            ],
          ),
        ),
        if (isSelected)
          SizedBox(
            width: 120,
            child: PrimaryButton(
              onTap: widget.openRouter,
              color: AppColors.primary500,
              widgetImage: SvgPicture.asset(AppAssets.mapRoutes),
              textColor: Colors.white,
              text: 'Reanudar',
            ),
          ),
        if (!isSelected)
          SizedBox(
            width: 80,
            child: PrimaryButton(
              color: AppColors.primary500,
              widgetImage: SvgPicture.asset(AppAssets.mapRoutes),
              textColor: Colors.white,
              text: 'Ir',
              onTap: () {
                if (indexRoute != null) {
                  widget.openRouter.call();
                  widget.startGuidance.call(indexRoute);
                }
              },
            ),
          ),
      ],
    );
  }
}
