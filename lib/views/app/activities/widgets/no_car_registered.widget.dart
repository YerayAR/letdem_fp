import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';

class NoCarRegisteredWidget extends StatelessWidget {
  const NoCarRegisteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "No Car Registered",
                style: Typo.largeBody.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Dimens.space(2),
              Text(
                "Register your car with the car details\nfor safety and accessibility",
                style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
                textAlign: TextAlign.center,
              ),
              Dimens.space(2),
              InkWell(
                onTap: () {
                  NavigatorHelper.to(RegisterCarView());
                },
                child: Center(
                    child: Text(
                  "Tap to Register Car",
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.primary400,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                )),
              )
            ],
          ),
        ],
      ),
    );
  }
}

CarTagType fromJsonToTag(String tagType) {
  switch (tagType.toLowerCase()) {
    case 'zero':
      return CarTagType.zero;
    case 'eco':
      return CarTagType.eco;
    case 'c':
      return CarTagType.c;
    case 'b':
      return CarTagType.b;
    case 'none':
      return CarTagType.none;
    default:
      return CarTagType.zero;
  }
}

enum CarTagType {
  zero,
  eco,
  c,
  b,
  none,
}

String geTagTypeIcon(CarTagType type) {
  switch (type) {
    case CarTagType.zero:
      return AppAssets.carTagZero;
    case CarTagType.eco:
      return AppAssets.carTagEco;
    case CarTagType.c:
      return AppAssets.carTagC;
    case CarTagType.b:
      return AppAssets.carTagB;
    case CarTagType.none:
      return AppAssets.carTagNone;
  }
}

class RegisterCarView extends StatefulWidget {
  final Car? car;
  const RegisterCarView({super.key, this.car});

  @override
  State<RegisterCarView> createState() => _RegisterCarViewState();
}

class _RegisterCarViewState extends State<RegisterCarView> {
  CarTagType selectedType = CarTagType.zero;

  late TextEditingController _brandCTRL;
  late TextEditingController _plateNumberCTRL;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _brandCTRL = TextEditingController();
    _plateNumberCTRL = TextEditingController();

    if (widget.car != null) {
      _brandCTRL.text = widget.car!.brand;
      _plateNumberCTRL.text = widget.car!.registrationNumber;
      selectedType = (widget.car!.tagType);
    }
    super.initState();
  }

  @override
  void dispose() {
    _brandCTRL.dispose();
    _plateNumberCTRL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarBloc, CarState>(
      listener: (context, state) {
        if (state is CarLoaded) {
          NavigatorHelper.pop();
        }
        if (state is CarError) {
          Toast.showError(state.message);
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimens.defaultMargin),
              child: PrimaryButton(
                isLoading: state is CarLoading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<CarBloc>().add(
                          CreateCarEvent(
                            isUpdating: widget.car != null,
                            brand: _brandCTRL.text,
                            registrationNumber: _plateNumberCTRL.text,
                            tagType: selectedType,
                          ),
                        );
                  }
                },
                text: widget.car != null ? "Update" : "Register",
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(
              widget.car != null ? "Update Car Details" : "Register Car",
            ),
          ),
          body: Form(
            key: _formKey,
            child: StyledBody(
              children: [
                TextInputField(
                  controller: _brandCTRL,
                  label: "Brand",
                  placeHolder: 'Enter Car Brand',
                ),
                TextInputField(
                  controller: _plateNumberCTRL,
                  label: "Plate Number",
                  placeHolder: 'Enter plate number',
                ),
                Dimens.space(2),
                Text(
                  "Select Tag",
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                Dimens.space(1),
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: CarTagType.values
                      .map((e) => Flexible(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = e;
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: selectedType == e
                                        ? Border.all(
                                            color: AppColors.primary200,
                                            width: 2)
                                        : Border.all(
                                            color: AppColors.neutral50,
                                            width: 2),
                                  ),
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        geTagTypeIcon(e),
                                        width: 30,
                                        height: 30,
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
