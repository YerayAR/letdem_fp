import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class EditBasicInfoView extends StatefulWidget {
  const EditBasicInfoView({super.key});

  @override
  State<EditBasicInfoView> createState() => _EditBasicInfoViewState();
}

class _EditBasicInfoViewState extends State<EditBasicInfoView> {
  late TextEditingController _firstNameCTRL;
  late TextEditingController _lastNameCTRL;
  late TextEditingController _aliasCTRL;

  @override
  void initState() {
    _firstNameCTRL = TextEditingController();
    _lastNameCTRL = TextEditingController();
    _aliasCTRL = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var user = context.userProfile;

      if (user != null) {
        _firstNameCTRL.text = user.firstName;
        _lastNameCTRL.text = user.lastName;
        // TODO: Cargar alias cuando el backend lo soporte
        // _aliasCTRL.text = user.alias ?? '';
      }

      // Cargar datos del vehículo
      context.read<CarBloc>().add(const GetCarEvent());
    });
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameCTRL.dispose();
    _lastNameCTRL.dispose();
    _aliasCTRL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              Toast.showError(state.error);
            }
            if (state is UserLoaded) {
              AppPopup.showDialogSheet(
                context,
                SuccessDialog(
                  title: context.l10n.accountInformationChanged,
                  onProceed: () {
                    NavigatorHelper.pop();
                  },
                  subtext: context.l10n.accountInformationChangedDescription,
                  buttonText: context.l10n.goBack,
                ),
              );
            }
            // TODO: implement listener
          },
          builder: (context, state) {
            return ListView(
              children: [
                Form(
                  key: _formKey,
                  child: StyledBody(
                    children: [
                      StyledAppBar(
                        title: context.l10n.personalInformation,
                        onTap: () {
                          NavigatorHelper.pop();
                        },
                        icon: Icons.close,
                      ),
                      // custom app bar

                      Dimens.space(3),
                      TextInputField(
                        prefixIcon: Iconsax.user,
                        label: context.l10n.firstName,
                        controller: _firstNameCTRL,
                        placeHolder: context.l10n.enterFirstName,
                      ),
                      Dimens.space(1),
                      TextInputField(
                        prefixIcon: Iconsax.user,
                        controller: _lastNameCTRL,
                        label: context.l10n.lastName,
                        placeHolder: context.l10n.enterLastName,
                      ),
                      Dimens.space(1),
                      TextInputField(
                        prefixIcon: Iconsax.tag,
                        controller: _aliasCTRL,
                        label: context.l10n.alias,
                        placeHolder: context.l10n.enterAlias,
                      ),

                      Dimens.space(2),

                      // Sección de datos del vehículo (solo lectura)
                      _buildVehicleSection(context),

                      Dimens.space(2),

                      PrimaryButton(
                        isLoading: state is UserLoading,
                        onTap: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          context.read<UserBloc>().add(
                                EditBasicInfoEvent(
                                  firstName: _firstNameCTRL.text,
                                  lastName: _lastNameCTRL.text,
                                ),
                              );
                        },
                        text: context.l10n.save,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleSection(BuildContext context) {
    return BlocBuilder<CarBloc, CarState>(
      builder: (context, carState) {
        if (carState is CarLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (carState is CarLoaded && carState.car != null) {
          final car = carState.car!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.vehicleInformation,
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                ),
              ),
              Dimens.space(1),
              _buildReadOnlyField(
                context: context,
                icon: Iconsax.car,
                label: context.l10n.brandModel,
                value: car.brand,
              ),
              Dimens.space(1),
              _buildReadOnlyField(
                context: context,
                icon: Iconsax.card,
                label: context.l10n.licensePlate,
                value: car.registrationNumber,
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Iconsax.car, color: AppColors.neutral400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.noVehicleRegistered,
                  style: Typo.smallBody.copyWith(color: AppColors.neutral500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neutral400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.lock, color: AppColors.neutral300, size: 16),
        ],
      ),
    );
  }
}
