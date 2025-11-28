import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class SendMoneyView extends StatefulWidget {
  const SendMoneyView({super.key});

  @override
  State<SendMoneyView> createState() => _SendMoneyViewState();
}

class _SendMoneyViewState extends State<SendMoneyView> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _aliasController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simular envío (mockeado)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;

    AppPopup.showDialogSheet(
      context,
      SuccessDialog(
        title: context.l10n.moneySentSuccessfully,
        subtext: context.l10n.moneySentDescription(
          _amountController.text,
          _aliasController.text,
        ),
        buttonText: context.l10n.goBack,
        onProceed: () {
          NavigatorHelper.pop();
          NavigatorHelper.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: StyledBody(
          children: [
            StyledAppBar(
              title: context.l10n.sendMoney,
              icon: Icons.close,
              onTap: () => NavigatorHelper.pop(),
            ),
            Dimens.space(3),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInfoCard(),
                    Dimens.space(3),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      label: context.l10n.recipientAlias,
                      controller: _aliasController,
                      placeHolder: context.l10n.enterRecipientAlias,
                    ),
                    Dimens.space(2),
                    TextInputField(
                      prefixIcon: Iconsax.money,
                      label: context.l10n.amountToSend,
                      controller: _amountController,
                      placeHolder: '0.00',
                      inputType: TextFieldType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                    Dimens.space(3),
                    _buildWarningCard(),
                    Dimens.space(4),
                    PrimaryButton(
                      onTap: _sendMoney,
                      text: context.l10n.sendMoney,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.send_2,
              color: AppColors.primary500,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.sendMoneyTitle,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.sendMoneySubtitle,
                  style: Typo.smallBody.copyWith(
                    color: AppColors.primary500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.warning_2,
            color: AppColors.secondary600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.sendMoneyWarning,
              style: Typo.smallBody.copyWith(
                color: AppColors.secondary600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
