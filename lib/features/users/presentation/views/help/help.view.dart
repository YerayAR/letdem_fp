import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';


class HelpScreenView extends StatefulWidget {
  const HelpScreenView({super.key});

  @override
  State<HelpScreenView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpScreenView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(children: [
        StyledAppBar(
          onTap: () {
            NavigatorHelper.pop();
          },
          title: context.l10n.helpAndSupport,
          icon: Icons.close,
        ),
        Dimens.space(3),
        Expanded(
          child: ListView(
            children: [
              // FAQ Sections
              HelpSectionItem(
                title: context.l10n.howToPublishPaidSpaceTitle,
                content: _buildPublishPaidSpaceContent(context),
                icon: Icons.add_business_outlined,
              ),
              Dimens.space(2),
              HelpSectionItem(
                title: context.l10n.howToEarnMoneyTitle,
                content: _buildEarnMoneyContent(context),
                icon: Icons.attach_money_outlined,
              ),
              Dimens.space(2),
              HelpSectionItem(
                title: context.l10n.howToWithdrawFundsTitle,
                content: _buildWithdrawFundsContent(context),
                icon: Icons.account_balance_wallet_outlined,
              ),
              Dimens.space(2),
              // New sections
              HelpSectionItem(
                title: context.l10n.howToEarnPointsTitle,
                content: _buildEarnPointsContent(context),
                icon: Icons.stars_outlined,
              ),
              Dimens.space(2),
              HelpSectionItem(
                title: context.l10n.howToCreateScheduledNotificationsTitle,
                content: _buildScheduledNotificationsContent(context),
                icon: Icons.schedule_outlined,
              ),
              Dimens.space(3),
              Dimens.space(4),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPublishPaidSpaceContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.howToPublishPaidSpaceDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Dimens.space(2),
        _buildRequirementItem(
          context,
          "1. ",
          context.l10n.publishPaidSpaceRequirement1,
          Icons.directions_car_outlined,
        ),
        Dimens.space(1),
        _buildRequirementItem(
          context,
          "2. ",
          context.l10n.publishPaidSpaceRequirement2,
          Icons.account_balance_outlined,
        ),
      ],
    );
  }

  Widget _buildEarnMoneyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.howToEarnMoneyDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Dimens.space(2),
        Text(
          context.l10n.earningsTransferDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Dimens.space(2),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              Dimens.space(1),
              Expanded(
                child: Text(
                  context.l10n.earningsLocationDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawFundsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.howToWithdrawFundsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEarnPointsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.howToEarnPointsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Dimens.space(2),

        // Point earning methods
        _buildPointEarningItem(
          context,
          "1",
          context.l10n.reservePaidSpaceTitle,
          context.l10n.reservePaidSpaceDescription,
          Icons.local_parking_outlined,
        ),
        Dimens.space(1),

        _buildPointEarningItem(
          context,
          "2",
          context.l10n.publishFreeSpaceTitle,
          context.l10n.publishFreeSpaceDescription,
          Icons.local_parking_outlined,
        ),
        Dimens.space(1),

        _buildPointEarningItem(
          context,
          "3",
          context.l10n.publishAlertTitle,
          context.l10n.publishAlertDescription,
          Icons.warning_outlined,
        ),
        Dimens.space(2),

        // Additional notes
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Dimens.space(1),
                  Text(
                    context.l10n.additionalNotes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Dimens.space(1),
              Text(
                context.l10n.pointsNote1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Dimens.space(1),
              Text(
                context.l10n.pointsNote2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledNotificationsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.howToCreateScheduledNotificationsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Dimens.space(2),

        // Steps
        _buildStepItem(
          context,
          "1",
          context.l10n.searchDestinationTitle,
          context.l10n.searchDestinationDescription,
          Icons.search_outlined,
        ),
        Dimens.space(1),

        _buildStepItem(
          context,
          "2",
          context.l10n.selectAddressTitle,
          context.l10n.selectAddressDescription,
          Icons.place_outlined,
        ),
        Dimens.space(1),

        _buildStepItem(
          context,
          "3",
          context.l10n.configureAlertTitle,
          context.l10n.configureAlertDescription,
          Icons.tune_outlined,
        ),
        Dimens.space(2),

        // Additional info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.scheduledNotificationsManagement,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Dimens.space(1),
              Text(
                context.l10n.scheduledNotificationsAlert,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointEarningItem(
    BuildContext context,
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Dimens.space(1),
          // Icon(
          //   icon,
          //   size: 20,
          //   color: Colors.green,
          // ),
          // Dimens.space(1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "+1 ${context.l10n.point}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        Dimens.space(1),
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        Dimens.space(1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String number,
    String text,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.replaceAll('. ', ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        Dimens.space(1),
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        Dimens.space(1),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// Keep all existing classes (HelpSectionItem, HelpInfoCard, HelpStepItem) unchanged
class HelpSectionItem extends StatefulWidget {
  final String title;
  final Widget content;
  final IconData icon;
  final bool isExpanded;

  const HelpSectionItem({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isExpanded = false,
  });

  @override
  State<HelpSectionItem> createState() => _HelpSectionItemState();
}

class _HelpSectionItemState extends State<HelpSectionItem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (_isExpanded) {
      _animationController.forward();
    }

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_expandAnimation, _glowAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.neutral100.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          title: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff2A2A2A),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary500,
                                size: 24,
                              ),
                            ),
                          ),
                          onTap: _toggleExpanded,
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.8),
                                AppColors.primary50.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: widget.content,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HelpInfoCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const HelpInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  State<HelpInfoCard> createState() => _HelpInfoCardState();
}

class _HelpInfoCardState extends State<HelpInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary50,
                    Colors.white,
                    AppColors.green50.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary500
                        .withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 25 : 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color:
                        AppColors.green500.withOpacity(_isHovered ? 0.1 : 0.05),
                    blurRadius: _isHovered ? 35 : 20,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary500.withOpacity(0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondary500,
                                    AppColors.secondary600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.secondary500.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff2A2A2A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HelpStepItem extends StatefulWidget {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  const HelpStepItem({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });

  @override
  State<HelpStepItem> createState() => _HelpStepItemState();
}

class _HelpStepItemState extends State<HelpStepItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.green500,
                            AppColors.green600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green500.withOpacity(
                                0.3 + (_pulseAnimation.value * 0.2)),
                            blurRadius: 15 + (_pulseAnimation.value * 10),
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: AppColors.green500.withOpacity(
                                0.1 + (_pulseAnimation.value * 0.1)),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              widget.stepNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isLast)
                      Expanded(
                        child: Container(
                          width: 3,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.green500.withOpacity(0.6),
                                AppColors.green500.withOpacity(0.2),
                                AppColors.green500.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.green50,
                          Colors.white,
                          AppColors.tetiary5000.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green500.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.green500.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff2A2A2A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral500,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
