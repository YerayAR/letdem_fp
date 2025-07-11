import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        children: [
          StyledAppBar(
            title: context.l10n.help,
            onTap: () {
              NavigatorHelper.pop();
            },
            icon: Icons.arrow_back,
          ),
          Dimens.space(3),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: Dimens.defaultMargin),
              children: [
                _buildFAQSection(context),
                Dimens.space(3),
                _buildLetDemPointsSection(context),
                Dimens.space(3),
                _buildScheduledNotificationsSection(context),
                Dimens.space(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.faqTitle,
          style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
        ),
        Dimens.space(2),

        // FAQ Item 1
        _FAQItem(
          question: context.l10n.faqPublishPaidSpaceQuestion,
          answer: context.l10n.faqPublishPaidSpaceAnswer,
        ),

        // FAQ Item 2
        _FAQItem(
          question: context.l10n.faqEarnMoneyQuestion,
          answer: context.l10n.faqEarnMoneyAnswer,
        ),

        // FAQ Item 3
        _FAQItem(
          question: context.l10n.faqWithdrawFundsQuestion,
          answer: context.l10n.faqWithdrawFundsAnswer,
        ),
      ],
    );
  }

  Widget _buildLetDemPointsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.helpLetDemPointsTitle,
          style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
        ),
        Dimens.space(2),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPointsItem(
                title: context.l10n.helpLetDemPointsReserveTitle,
                description: context.l10n.helpLetDemPointsReserveDescription,
              ),
              Dimens.space(2),
              _buildPointsItem(
                title: context.l10n.helpLetDemPointsPublishTitle,
                description: context.l10n.helpLetDemPointsPublishDescription,
              ),
              Dimens.space(2),
              _buildPointsItem(
                title: context.l10n.helpLetDemPointsAlertTitle,
                description: context.l10n.helpLetDemPointsAlertDescription,
              ),
              Dimens.space(2),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.helpLetDemPointsAdditionalNotesTitle,
                      style:
                          Typo.mediumBody.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Dimens.space(1),
                    Text(
                      context.l10n.helpLetDemPointsAdditionalNote1,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                    Dimens.space(0.5),
                    Text(
                      context.l10n.helpLetDemPointsAdditionalNote2,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.helpScheduledNotificationsTitle,
          style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
        ),
        Dimens.space(2),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.helpScheduledNotificationsIntro,
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w600),
              ),
              Dimens.space(2),
              _buildStepItem(
                step: "1",
                description: context.l10n.helpScheduledNotificationsStep1,
              ),
              Dimens.space(1.5),
              _buildStepItem(
                step: "2",
                description: context.l10n.helpScheduledNotificationsStep2,
              ),
              Dimens.space(1.5),
              _buildStepItem(
                step: "3",
                description: context.l10n.helpScheduledNotificationsStep3,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.helpScheduledNotificationsStep3Detail1,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                    Dimens.space(0.5),
                    Text(
                      context.l10n.helpScheduledNotificationsStep3Detail2,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              Dimens.space(2),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.helpScheduledNotificationsInfo1,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                    Dimens.space(1),
                    Text(
                      context.l10n.helpScheduledNotificationsInfo2,
                      style: Typo.smallBody.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointsItem(
      {required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
        ),
        Dimens.space(1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w600),
              ),
              Dimens.space(0.5),
              Text(
                description,
                style: Typo.smallBody.copyWith(
                  height: 1.5,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String step, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              step,
              style: Typo.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Dimens.space(1),
        Expanded(
          child: Text(
            description,
            style: Typo.smallBody.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary500,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  Dimens.space(1),
                  Text(
                    widget.answer,
                    style: Typo.smallBody.copyWith(
                      height: 1.5,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
