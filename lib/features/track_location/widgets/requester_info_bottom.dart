import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/enums/PublishSpaceType.dart';

class RequesterInfoBottom extends StatefulWidget {
  const RequesterInfoBottom({
    super.key,
    required this.payload,
    required this.requesterLat,
    required this.requesterLng,
    required this.isConnected,
    this.onClose,
  });

  final ReservedSpacePayload payload;
  final double? requesterLat;
  final double? requesterLng;
  final bool isConnected;
  final VoidCallback? onClose;

  @override
  State<RequesterInfoBottom> createState() => _RequesterInfoBottomState();
}

class _RequesterInfoBottomState extends State<RequesterInfoBottom> {
  bool _isExpanded = false;

  bool get _isTracking =>
      widget.isConnected &&
      widget.requesterLat != null &&
      widget.requesterLng != null;

  String _getTimeRemainingText(BuildContext context) {
    final now = DateTime.now();
    final timeRemaining = widget.payload.expireAt.difference(now);
    final minutesRemaining = timeRemaining.inMinutes;

    if (timeRemaining.isNegative) {
      return context.l10n.expired;
    }

    if (minutesRemaining < 60) {
      return '$minutesRemaining ${context.l10n.minutes}';
    }

    final hours = (minutesRemaining / 60).floor();
    final mins = minutesRemaining % 60;
    return '${hours}h ${mins}m';
  }

  Color _getTimeColor() {
    final now = DateTime.now();
    final timeRemaining = widget.payload.expireAt.difference(now);
    final minutesRemaining = timeRemaining.inMinutes;

    if (timeRemaining.isNegative) return AppColors.red500;
    if (minutesRemaining < 15) return AppColors.secondary500;
    return AppColors.green500;
  }

  double _getProgress() {
    final now = DateTime.now();
    final total = widget.payload.expireAt.difference(widget.payload.canceledAt);
    final elapsed = now.difference(widget.payload.canceledAt);
    final progress = 1 - (elapsed.inMilliseconds / total.inMilliseconds);
    return progress.clamp(0.0, 1.0);
  }

  void _makePhoneCall() async {
    final phoneNumber = '+1234567890';
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getSpaceTypeColor() {
    // Hardcoded for BlueZone
    return const Color(0xFF2196F3);
  }

  String _getSpaceTypeName() {
    // Hardcoded for BlueZone
    return 'Blue Zone';
  }

  IconData _getSpaceTypeIcon() {
    // Hardcoded for BlueZone
    return Icons.local_parking;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: AppColors.neutral200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Avatar with Dicebear
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.neutral200, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=VehanHemsara&backgroundColor=b6e3f4',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: AppColors.neutral400,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Vehan Hemsara",
                            style: Typo.heading4.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  _isTracking
                                      ? AppColors.green500
                                      : AppColors.neutral400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.payload.space.location.streetName,
                        style: Typo.caption.copyWith(
                          color: AppColors.neutral500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Call Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.green500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _makePhoneCall,
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Remaining',
                      style: Typo.caption.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _getTimeRemainingText(context),
                      style: Typo.caption.copyWith(
                        color: _getTimeColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getProgress(),
                    backgroundColor: AppColors.neutral100,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimeColor()),
                    minHeight: 6,
                  ),
                ),
              ],
            ),

            // Expanded content
            if (_isExpanded) ...[
              const SizedBox(height: 16),

              // Parking Space Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _getSpaceTypeColor().withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSpaceTypeColor().withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      child: SvgPicture.asset(
                        getSpaceTypeIcon(PublishSpaceType.free),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSpaceTypeName(),
                            style: Typo.mediumBody.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Premium Parking Space',
                            style: Typo.caption.copyWith(
                              color: AppColors.neutral500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$12.50',
                        style: Typo.caption.copyWith(
                          color: AppColors.green500,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Requester Details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.directions_car_outlined,
                      label: 'Car Plate',
                      value: 'ABC-1234',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Code',
                      value: '#XY789',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: '+1 (234) 567-890',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral400),
        const SizedBox(width: 8),
        Text(
          label,
          style: Typo.caption.copyWith(
            color: AppColors.neutral500,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
