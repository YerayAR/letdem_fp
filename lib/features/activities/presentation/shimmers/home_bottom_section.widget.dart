import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'package:letdem/features/activities/presentation/utils/publish_space_handler.dart';
import 'package:letdem/features/activities/presentation/widgets/search/search_bottom_sheet.widget.dart';

import '../../../../infrastructure/services/mapbox_search/models/service.dart';

class HomeMapBottomSection extends StatefulWidget {
  final VoidCallback onRefreshTriggered;
  final VoidCallback onFindNearestCharger;

  const HomeMapBottomSection({
    super.key,
    required this.onRefreshTriggered,
    required this.onFindNearestCharger,
  });

  @override
  State<HomeMapBottomSection> createState() => _HomeMapBottomSectionState();
}

class _HomeMapBottomSectionState extends State<HomeMapBottomSection> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.defaultMargin * 0.6,
              vertical: Dimens.defaultMargin,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary500.withOpacity(0.14),
                  AppColors.primary500.withOpacity(0.01),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Dimens.space(2),
                GestureDetector(
                  onTap: () async {
                    AppPopup.showBottomSheet(
                      context,
                      const MapSearchBottomSheet(),
                    );
                  },
                  child: AbsorbPointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: TextInputField(
                        label: null,
                        onChanged: (value) async {
                          HereSearchApiService()
                              .getLocationResults(value, context)
                              .then((value) {
                            for (var element in value) {
                              print(element.toJson());
                            }
                          });
                        },
                        prefixIcon: IconlyLight.search,
                        placeHolder: context.l10n.enterDestination,
                      ),
                    ),
                  ),
                ),
                Dimens.space(2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.isSpanish
                            ? '¿Qué quieres ver?'
                            : context.l10n.whatDoYouWantToDo,
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen;
                        });
                      },
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _isMenuOpen ? 0.5 : 0.0,
                        child: Icon(
                          Icons.keyboard_return,
                          size: 22,
                          color: AppColors.green500,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _isMenuOpen
                      ? Column(
                          key: const ValueKey('open-menu'),
                          children: [
                            Dimens.space(1.5),
                            _buildStepRow(
                              context: context,
                              stepWidth: 64,
                              icon: Icons.battery_charging_full,
                              label: context.isSpanish
                                  ? 'Cargador cercano'
                                  : 'Nearest charger',
                              onTap: widget.onFindNearestCharger,
                              accentColor: AppColors.green500,
                            ),
                            const SizedBox(height: 10),
                            _buildStepRow(
                              context: context,
                              stepWidth: 88,
                              icon: IconlyBold.location,
                              label: context.isSpanish
                                  ? 'Publicar aparcamiento'
                                  : context.l10n.publishSpace,
                              onTap: () async {
                                PublishSpaceHandler.showSpaceOptions(context, () {
                                  widget.onRefreshTriggered();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildStepRow(
                              context: context,
                              stepWidth: 112,
                              icon: IconlyBold.star,
                              label: context.isSpanish
                                  ? 'Publicar alerta'
                                  : context.l10n.publishEvent,
                              onTap: () {
                                AppPopup.showBottomSheet(
                                  context,
                                  const AddEventBottomSheet(),
                                );
                              },
                            ),
                            Dimens.space(1.5),
                          ],
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('closed-menu'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required BuildContext context,
    required double stepWidth,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final Color baseColor = accentColor ?? AppColors.primary500;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: stepWidth,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withOpacity(0.95),
                  baseColor.withOpacity(0.7),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
