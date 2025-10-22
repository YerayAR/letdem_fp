// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:here_sdk/mapview.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/time.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../common/popups/popup.dart';
import '../../../../../../core/constants/assets.dart';
import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/dimens.dart';
import '../../../../../activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'navigate_bottom.dart';

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
    required this.distance,
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
  final String distance;
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

  final Map<String, IconData> directionIcons = {
    'turn right': Icons.turn_right,
    'turn left': Icons.turn_left,
    'go straight': Icons.arrow_upward,
    'make a u-turn': Icons.u_turn_left,
  };

  @override
  State<NavigateContent> createState() => _NavigateContentState();
}

class _NavigateContentState extends State<NavigateContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HereMap(onMapCreated: widget.onMapCreated),
        NavigateBottom(
          mapPadding: widget.mapPadding,
          radius: widget.buttonRadius,
          speed: widget.speed,
          isLimit: widget.isLimit,
          height: widget.heightContainer,
        ),
        // if (kDebugMode) _buildWebSocketStatusIndicator(),
        if (widget.isLoading) _buildLoadingIndicator(),
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

              // CircleAvatar(
              //   radius: widget.buttonRadius,
              //   backgroundColor: Colors.white,
              //   child: IconButton(
              //     icon: SvgPicture.asset(
              //       AppAssets.circlePoint,
              //       width: 20,
              //       height: 20,
              //     ),
              //     onPressed: () {},
              //   ),
              // ),

              // CircleAvatar(
              //   radius: widget.buttonRadius * 1.2,
              //   backgroundColor: AppColors.primary500,
              //   child: IconButton(
              //     icon: SvgPicture.asset(
              //       AppAssets.addAlert,
              //       width: 25,
              //       height: 25,
              //     ),
              //     onPressed: () {
              //       AppPopup.showBottomSheet(
              //         context,
              //         const AddEventBottomSheet(),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
        if (widget.errorMessage.isNotEmpty) _buildErrorMessage(),
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 0,
          right: 0,
          child: _buildNavigationInstructionCard(),
        ),
        if (widget.isNavigating)
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
          // ),}
          CircleAvatar(
            radius: widget.buttonRadius,
            backgroundColor: const Color(0xFFF4F4F4),
            child: IconButton(
              icon: SvgPicture.asset(
                AppAssets.addAlert,
                width: 25,
                height: 25,
                color: const Color(0xFF445D6F),
              ),
              onPressed: () {
                AppPopup.showBottomSheet(context, const AddEventBottomSheet());
              },
            ),
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
              tooltip: 'Cambiar ruta',
              onPressed: () {},
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height:
              widget.isNavigating &&
                      widget.navigationInstruction.isNotEmpty &&
                      widget.distanceNotifier.value > 0
                  ? 100
                  : 70,
          padding: EdgeInsets.symmetric(
            horizontal: widget.mapPadding,
            vertical: widget.mapPadding + 5,
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
                        backgroundColor: AppColors.neutral500.withOpacity(0.5),
                        child: IconButton(
                          icon: Icon(
                            widget.isMuted ? Icons.volume_off : Icons.volume_up,
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
}
