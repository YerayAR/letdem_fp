import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/CarTagType.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/users/presentation/widgets/settings_container.widget.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/car/car.model.dart';

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
                  NavigatorHelper.to(const RegisterCarView());
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
                Row(
                  children: [
                    Text(
                      "Select Tag",
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        AppPopup.showDialogSheet(
                          context,
                          const EmissionsTagScreen(),
                        );
                      },
                      child: Text(
                        "What’s this?",
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.secondary600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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

class EmissionsTagScreen extends StatelessWidget {
  const EmissionsTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              child: Text(
                'What Tag Means',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A4556),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySection(
                    title: 'Eco Label',
                    items: const [
                      'Plug-in hybrids with an electric range of less than 40 km.',
                      'Non-plug-in hybrids (HEV).',
                      'Gas-powered vehicles (LPG, CNG, or LNG).',
                    ],
                  ),
                  _buildCategorySection(
                    title: 'Zero Emmission Label',
                    items: const [
                      '100% electric vehicles (BEV).',
                      'Plug-in hybrids (PHEV) with an electric range of more than 40 km.',
                      'Hydrogen-powered vehicles.',
                    ],
                  ),
                  _buildCategorySection(
                    title: 'B Label Yellow',
                    items: const [
                      'Petrol cars and vans registered from January 2001 onwards.',
                      'Diesel cars and vans registered from January 2006 onwards.',
                      'Industrial vehicles and buses registered from 2005 onwards.',
                    ],
                  ),
                  _buildCategorySection(
                    title: 'C Label Green',
                    items: const [
                      'Petrol cars and vans registered from January 2006 onwards.',
                      'Diesel cars and vans registered from September 2015 onwards.',
                      'Industrial vehicles and buses registered from 2014 onwards.',
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No Label',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Dimens.space(2),
            PrimaryButton(
              text: 'Got it',
              onTap: () {
                NavigatorHelper.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      {required String title, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ...items.map((item) => _buildBulletPoint(item)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Color(0xFF8494AB),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8494AB),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
