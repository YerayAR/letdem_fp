import 'package:flutter/material.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/EarningStatus.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';
import 'package:letdem/features/users/presentation/modals/money_laundry.popup.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';

class EarningAccountService {
  static void handleEarningAccountTap({
    required BuildContext context,
    required EarningAccount? earningAccount,
    required VoidCallback onSuccess,
  }) {
    final status = earningAccount?.status;

    if (status == EarningStatus.pending) {
      _showPendingPopup(context);
      return;
    }

    if (status == EarningStatus.rejected) {
      _showRejectedPopup(context);
      return;
    }

    if (status == EarningStatus.accepted) {
      onSuccess();
      return;
    }

    // default fallback to connect account flow
    _showConnectFlow(context, earningAccount);
  }

  static void _showPendingPopup(BuildContext context) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 37,
              backgroundColor: AppColors.secondary50,
              child: Icon(
                Icons.info,
                color: AppColors.secondary500,
                size: 50,
              ),
            ),
            Dimens.space(3),
            Text(
              context.l10n.connectionPending,
              style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
            ),
            Dimens.space(1),
            Text(
              context.l10n.connectionPendingMessage,
              textAlign: TextAlign.center,
              style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
            ),
            Dimens.space(2),
            PrimaryButton(
              text: context.l10n.goBack,
              onTap: () => NavigatorHelper.pop(),
            ),
          ],
        ),
      ),
    );
  }

  static void _showRejectedPopup(BuildContext context) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info,
              color: AppColors.red500,
              size: 55,
            ),
            Dimens.space(3),
            Text(
              context.l10n.somethingWentWrong,
              style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
            ),
            Dimens.space(1),
            Text(
              context.l10n.contactSupportMessage,
              textAlign: TextAlign.center,
              style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
            ),
            Dimens.space(2),
            PrimaryButton(
              text: context.l10n.goBack,
              onTap: () => NavigatorHelper.pop(),
            ),
          ],
        ),
      ),
    );
  }

  static void _showConnectFlow(
    BuildContext context,
    EarningAccount? earningAccount,
  ) {
    // log remaining steps and status
    print('Remaining Steps: ${earningAccount?.step}');
    print('Status: ${earningAccount?.status}');
    AppPopup.showBottomSheet(
      context,
      MoneyLaundryPopup(
        onContinue: () {
          NavigatorHelper.to(
            ConnectAccountView(
              remainingStep: earningAccount?.step,
              status: earningAccount?.status,
            ),
          );
        },
      ),
    );
  }
}
