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
