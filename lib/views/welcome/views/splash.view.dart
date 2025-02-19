import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/base.dart';
import 'package:letdem/views/welcome/views/welcome.view.dart';

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
            NavigatorHelper.replaceAll(const BaseView());
          }
          if (state is UserError) {
            if (state.apiError != null) {
              print(state.apiError!.status);
              if (state.apiError!.status == ErrorStatus.unauthorized) {
                // Toast.showError("The session has expired. Please login again.");
                NavigatorHelper.popAll();
                NavigatorHelper.to(const WelcomeView());
                return;
              }
            }
            Toast.showError(state.error);
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
              SizedBox(
                  child: state is UserError
                      ? Container(
                          margin: EdgeInsets.only(
                            top: Dimens.defaultMargin,
                            left: Dimens.defaultMargin,
                            right: Dimens.defaultMargin,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red500.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.defaultMargin / 2,
                            horizontal: Dimens.defaultMargin,
                          ),
                          child: Text(
                            'We were unable to process your request. Please try again later. The error is: ${state.apiError != null ? state.apiError!.message : state.error}',
                            style: TextStyle(
                              color: AppColors.red500,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : null),
            ],
          );
        },
      ),
    );
  }
}
