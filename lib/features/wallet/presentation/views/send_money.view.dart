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
import 'package:letdem/features/wallet/repository/transfer.repository.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class SendMoneyView extends StatefulWidget {
  /// Pantalla de envío. Puede comportarse como:
  /// - Vista combinada (selector interno de dinero/puntos)
  /// - Vista dedicada (solo dinero o solo puntos), según [initialType] y [showTypeSelector].
  const SendMoneyView({
    super.key,
    this.initialType = TransferType.money,
    this.showTypeSelector = true,
  });

  final TransferType initialType;
  final bool showTypeSelector;

  @override
  State<SendMoneyView> createState() => _SendMoneyViewState();
}

enum TransferType { money, points }

class _SendMoneyViewState extends State<SendMoneyView> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _amountController = TextEditingController();
  final _transferRepository = TransferRepository();
  late TransferType _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;

    final recipient = _aliasController.text.trim();
    final rawAmount = _amountController.text.replaceAll(',', '.').trim();

    setState(() => _isLoading = true);

    try {
      if (_selectedType == TransferType.money) {
        final amount = double.tryParse(rawAmount);
        if (amount == null || amount <= 0) {
          Toast.showError(context.l10n.enterValidAmount);
          return;
        }
        if (amount < 1.0) {
          Toast.showError('El mínimo a enviar es 1 €');
          return;
        }

        await _transferRepository.sendMoney(
          recipientUuid: recipient,
          amount: amount,
        );

        if (!mounted) return;

        AppPopup.showDialogSheet(
          context,
          SuccessDialog(
            title: context.l10n.moneySentSuccessfully,
            subtext: context.l10n.moneySentDescription(
              amount.toStringAsFixed(2),
              recipient,
            ),
            buttonText: context.l10n.goBack,
            onProceed: () {
              NavigatorHelper.pop();
              NavigatorHelper.pop();
            },
          ),
        );
      } else {
        // Envío de puntos
        final points = int.tryParse(rawAmount);
        if (points == null || points <= 0) {
          Toast.showError('Introduce un número entero de puntos válido');
          return;
        }
        if (points < 100) {
          Toast.showError('El mínimo a enviar es 100 puntos');
          return;
        }

        await _transferRepository.sendPoints(
          recipientUuid: recipient,
          points: points,
        );

        if (!mounted) return;

        AppPopup.showDialogSheet(
          context,
          SuccessDialog(
            title: 'Puntos enviados',
            subtext: 'Has enviado $points puntos a $recipient.',
            buttonText: context.l10n.goBack,
            onProceed: () {
              NavigatorHelper.pop();
              NavigatorHelper.pop();
            },
          ),
        );
      }
    } on ApiError catch (e) {
      if (!mounted) return;

      String message = e.message;
      if (e.status == ErrorStatus.badRequest &&
          message.toLowerCase().contains('insufficient')) {
        // Backend puede devolver "Insufficient balance" o "Insufficient points".
        message = context.l10n.insufficientBalance;
      }
      Toast.showError(message);
    } catch (_) {
      if (!mounted) return;
      Toast.showError(context.l10n.somethingWentWrongGeneric);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: StyledBody(
          children: [
            StyledAppBar(
              title: _selectedType == TransferType.money
                  ? context.l10n.sendMoney
                  : 'Enviar puntos',
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
                    if (widget.showTypeSelector) _buildTransferTypeSelector(),
                    if (widget.showTypeSelector) Dimens.space(3),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      label: context.l10n.recipientAlias,
                      controller: _aliasController,
                      placeHolder: context.l10n.enterRecipientAlias,
                    ),
                    Dimens.space(2),
                    TextInputField(
                      prefixIcon: Iconsax.money,
                      label: _selectedType == TransferType.money
                          ? context.l10n.amountToSend
                          : 'Puntos a enviar',
                      controller: _amountController,
                      placeHolder:
                          _selectedType == TransferType.money ? '0.00' : '0',
                      inputType: TextFieldType.number,
                      // Permitimos dígitos, coma y punto. Luego normalizamos a punto
                      // en _sendMoney() con replaceAll(',', '.').
                      inputFormatters: _selectedType == TransferType.money
                          ? [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ]
                          : null,
                    ),
                    Dimens.space(3),
                    _buildWarningCard(),
                    Dimens.space(4),
                    PrimaryButton(
                      onTap: _sendMoney,
                      text: 'Enviar',
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

  Widget _buildTransferTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('Dinero'),
              selected: _selectedType == TransferType.money,
              onSelected: (_) {
                setState(() {
                  _selectedType = TransferType.money;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text('Puntos'),
              selected: _selectedType == TransferType.points,
              onSelected: (_) {
                setState(() {
                  _selectedType = TransferType.points;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isMoney = _selectedType == TransferType.money;
    final locale = Localizations.localeOf(context).languageCode;

    final title = isMoney
        ? context.l10n.sendMoneyTitle
        : (locale == 'es' ? 'Enviar puntos' : 'Send points');

    final subtitle = isMoney
        ? context.l10n.sendMoneySubtitle
        : (locale == 'es'
            ? 'Envía puntos LetDem a otro usuario usando su alias.'
            : 'Send LetDem points to another user using their alias.');

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
                  title,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
    final isMoney = _selectedType == TransferType.money;
    final locale = Localizations.localeOf(context).languageCode;

    final warningText = isMoney
        ? context.l10n.sendMoneyWarning
        : (locale == 'es'
            ? 'Verifica el alias y la cantidad de puntos antes de enviar. No se pueden revertir.'
            : 'Verify alias and points amount before sending. Transfers cannot be reversed.');

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
              warningText,
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
