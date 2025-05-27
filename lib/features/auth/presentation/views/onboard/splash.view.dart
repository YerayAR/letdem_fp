import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/base.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/features/auth/presentation/views/onboard/welcome.view.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    context.read<UserBloc>().add(FetchUserInfoEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            context.read<CarBloc>().add(const GetCarEvent());
            NavigatorHelper.replaceAll(const BaseView());
          }
          if (state is UserError) {
            if (state.apiError != null) {
              print(state.apiError!.status);
              if (state.apiError!.status == ErrorStatus.unauthorized) {
                // Toast.showError("The session has expired. Please login again.");
                NavigatorHelper.popAll();
                NavigatorHelper.replaceAll(const WelcomeView());
                return;
              }
            }
            AppPopup.showBottomSheet(
              context,
              Padding(
                padding: EdgeInsets.all(Dimens.defaultMargin),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.cloud_connection,
                      color: AppColors.red500,
                      size: 50,
                    ),
                    Dimens.space(2),
                    const Text("Something went wrong",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 23,
                        )),
                    Text(
                      'We were unable to process your request. Please try again later. The error is: ${state.apiError != null ? state.apiError!.message : state.error}',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Dimens.space(3),
                    PrimaryButton(
                      onTap: () {
                        context.read<UserBloc>().add(FetchUserInfoEvent());
                      },
                      text: "Retry",
                    )
                  ],
                ),
              ),
            );
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(AppAssets.logo),
                    // Positioned(
                    //     right: -15,
                    //     top: -15,
                    //     child: CupertinoActivityIndicator(
                    //         color: AppColors.primary500)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
