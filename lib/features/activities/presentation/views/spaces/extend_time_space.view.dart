import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/extensions/locale.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../common/widgets/body.dart';
import '../../../../../common/widgets/button.dart';
import '../../../../../common/widgets/textfield.dart';
import '../../../../../core/constants/dimens.dart';
import '../../../../../infrastructure/services/res/navigator.dart';
import '../../../activities_bloc.dart';

class ExtendTimeSpaceView extends StatefulWidget {
  const ExtendTimeSpaceView({super.key, required this.spaceId});

  final String spaceId;

  @override
  State<ExtendTimeSpaceView> createState() => _ExtendTimeSpaceViewState();
}

class _ExtendTimeSpaceViewState extends State<ExtendTimeSpaceView> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          Dimens.space(3),
          TextInputField(
            label: 'Nuevo tiempo',
            placeHolder: "MM",
            controller: textController,
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

          PrimaryButton(
            text: context.l10n.continuee,
            isVerifyConecction: true,
            isDisabled:
                (int.tryParse((textController.text).toString()) ?? 0) > 0,
            onTap: () {
              int time = int.tryParse((textController.text).toString()) ?? 0;

              if (time > 0) {
                NavigatorHelper.pop();
                context.read<ActivitiesBloc>().add(
                  ExtendTimeEvent(spaceId: widget.spaceId, time: time),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return const StyledAppBar(
      title: 'Extender tiempo',
      onTap: NavigatorHelper.pop,
      icon: Iconsax.close_circle5,
    );
  }
}
