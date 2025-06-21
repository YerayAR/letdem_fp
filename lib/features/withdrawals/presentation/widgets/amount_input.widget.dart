import 'package:flutter/material.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';

class AmountInputCard extends StatefulWidget {
  final Function(String)? onChange;

  const AmountInputCard({super.key, this.onChange});

  @override
  _AmountInputCardState createState() => _AmountInputCardState();
}

class _AmountInputCardState extends State<AmountInputCard> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    final balance = context.userProfile!.earningAccount?.balance ?? 0;
    final entered = double.tryParse(value) ?? 0;

    if (entered > balance) {
      setState(() =>
          _errorText = context.l10n.amountCannotExceed(balance.toString()));
      widget.onChange?.call('0');
      return;
    } else {
      setState(() => _errorText = null);
    }

    // Call the onChange callback
    widget.onChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.userProfile!.earningAccount?.balance ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimens.defaultMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.amountToReceive,
            style: Typo.mediumBody.copyWith(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Dimens.space(1),
          Text(
            '${(context.userProfile!.earningAccount?.availableBalance ?? 0).toStringAsFixed(2)} €',
            style: Typo.heading3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 36,
            ),
          ),
          // TextField(
          //   controller: _controller,
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
          //   textAlign: TextAlign.center,
          //   style: Typo.heading3.copyWith(
          //     fontWeight: FontWeight.w800,
          //     fontSize: 36,
          //   ),
          //   decoration: InputDecoration(
          //     hintText: '0.00 €',
          //     hintStyle: Typo.heading3.copyWith(
          //       fontWeight: FontWeight.w800,
          //       fontSize: 36,
          //       color: AppColors.neutral200,
          //     ),
          //     prefixStyle: Typo.heading3.copyWith(
          //       fontWeight: FontWeight.w800,
          //       fontSize: 36,
          //     ),
          //     border: InputBorder.none,
          //     contentPadding: EdgeInsets.zero,
          //   ),
          //   textAlignVertical: TextAlignVertical.center,
          //   inputFormatters: [
          //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          //   ],
          //   onChanged: _validateAmount,
          // ),
          Dimens.space(1),
          Text(
            _errorText ??
                context.l10n.pendingToBeCleared(context
                    .userProfile!.earningAccount!.pendingBalance
                    .toStringAsFixed(2)),
            style: Typo.mediumBody.copyWith(
              fontSize: 13,
              color:
                  _errorText != null ? AppColors.red500 : AppColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }
}
