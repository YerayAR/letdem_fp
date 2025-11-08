import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/button.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../common/widgets/body.dart';
import '../../../../../common/widgets/textfield.dart';
import '../../../../../core/constants/dimens.dart';

class ExtendTimeSpaceView extends StatelessWidget {
  const ExtendTimeSpaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StyledAppBar(title: 'Expandir tiempo', icon: Icons.abc),

          Expanded(
            child: StyledBody(
              children: [
                TextInputField(
                  label: 'Nuevo tiempo',
                  placeHolder: "MM",
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
                  ],
                  onChanged: (value) {
                    // setState(() {
                    //   waitingTime = value;
                    // });
                  },
                  inputType: TextFieldType.number,
                  prefixIcon: Iconsax.clock5,
                  // child: Padding(
                  //   padding: const EdgeInsets.only(right: 25),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       AppPopup.showDialogSheet(
                  //         context,
                  //         Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Text(context.l10n.waitingTime, style: Typo.heading4),
                  //             Dimens.space(2),
                  //             Text(
                  //               context.l10n.waitingTimeTooltip(
                  //                 context
                  //                     .userProfile!
                  //                     .constantsSettings
                  //                     .spaceTimeToWait
                  //                     .minimum,
                  //                 context
                  //                     .userProfile!
                  //                     .constantsSettings
                  //                     .spaceTimeToWait
                  //                     .maximum,
                  //               ),
                  //               style: Typo.mediumBody,
                  //               textAlign: TextAlign.center,
                  //             ),
                  //             Dimens.space(2),
                  //             PrimaryButton(
                  //               onTap: () {
                  //                 NavigatorHelper.pop();
                  //               },
                  //               text: context.l10n.gotIt,
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //     child: SizedBox(
                  //       width: MediaQuery.of(context).size.width / 2,
                  //       child: Align(
                  //         alignment: Alignment.centerRight,
                  //         child: Text(
                  //           context.l10n.whatIsThisWaitingTime,
                  //           style: Typo.smallBody.copyWith(
                  //             color: AppColors.secondary600,
                  //             fontSize: 12,
                  //             decorationColor: AppColors.secondary600,
                  //             decoration: TextDecoration.underline,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ),

                Dimens.space(2),

                PrimaryButton(text: 'text', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
