import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';

import '../../../../../constants/ui/typo.dart';

class ProfileOnboardingApp extends StatefulWidget {
  const ProfileOnboardingApp({Key? key}) : super(key: key);

  @override
  State<ProfileOnboardingApp> createState() => _ProfileOnboardingAppState();
}

class _ProfileOnboardingAppState extends State<ProfileOnboardingApp> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header with progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHeader(_currentPage),
            ),
            const SizedBox(height: 30),

            // Page content that changes
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swiping
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  CountrySelectionPage(onNext: _goToNextPage),
                  PersonalInfoPage(onNext: _goToNextPage),
                  AddressInfoPage(onNext: _goToNextPage),
                  IDTypePage(onNext: _goToNextPage),
                  UploadIDPictureView(onNext: _goToNextPage),
                  BankInfoView(onNext: _goToNextPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountrySelectionPage extends StatelessWidget {
  final VoidCallback onNext;

  const CountrySelectionPage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Country',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Select your country of residence to continue',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          Text(
            'Select Country',
            style: TextStyle(fontSize: 16, color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neutral100,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              leading: Icon(Iconsax.location),
              title: Text(
                'Spain',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              trailing: Icon(Icons.keyboard_arrow_down),
            ),
          ),
          const Spacer(),
          _buildNextButton(context, onNext),
        ],
      ),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  const PersonalInfoPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dto = EarningsAccountDTO(
        country: "ES", // Replace with real value from context/state
        userIp: "8.8.8.3", // Replace with real IP from backend or provider
        legalFirstName: _firstNameController.text.trim(),
        legalLastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthday: "1995-02-02", // Replace with datepicker field if needed
      );

      context.read<EarningsBloc>().add(SubmitEarningsAccount(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EarningsBloc, EarningsState>(
      listener: (context, state) {
        if (state is EarningsSuccess) {
          widget.onNext();
        } else if (state is EarningsFailure) {
          Toast.showError(state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your personal information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Input your personal details as it is on your ID Card',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 30),
              TextInputField(
                label: 'Enter first name',
                placeHolder: 'Eg. John',
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Enter last name',
                placeHolder: 'Eg. Doe',
                controller: _lastNameController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Enter phone number',
                placeHolder: 'Eg. +1234567890',
                controller: _phoneController,
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return PrimaryButton(
                    onTap: state is EarningsLoading ? null : _submitForm,
                    text: state is EarningsLoading ? "Submitting..." : "Next",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BankInfoView extends StatefulWidget {
  final VoidCallback onNext;
  const BankInfoView({Key? key, required this.onNext}) : super(key: key);

  @override
  State<BankInfoView> createState() => _BankInfoViewState();
}

class _BankInfoViewState extends State<BankInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dto =
          EarningsBankAccountDTO(accountNumber: _ibanController.text.trim());
      context.read<EarningsBloc>().add(SubmitEarningsBankAccount(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EarningsBloc, EarningsState>(
      listener: (context, state) {
        if (state is EarningsSuccess) {
          widget.onNext();
        } else if (state is EarningsFailure) {
          Toast.showError(state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Enter your IBAN to complete this step',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 30),
              TextInputField(
                label: 'Enter your IBAN',
                placeHolder: 'Eg. ES0700120345030000067890',
                controller: _ibanController,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.secondary600),
                    Dimens.space(1),
                    Flexible(
                      child: Text(
                        "Kindly note that this bank account is required to receive payout from our payment provider.",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.secondary600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return PrimaryButton(
                    onTap: state is EarningsLoading ? null : _submit,
                    text: state is EarningsLoading ? "Submitting..." : "Next",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  const AddressInfoPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<AddressInfoPage> createState() => _AddressInfoPageState();
}

class _AddressInfoPageState extends State<AddressInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postalController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _postalController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dto = EarningsAddressDTO(
        fullStreet: _addressController.text.trim(),
        postalCode: _postalController.text.trim(),
        city: _cityController.text.trim(),
        country: 'ES', // Get this dynamically if needed
      );
      context.read<EarningsBloc>().add(SubmitEarningsAddress(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EarningsBloc, EarningsState>(
      listener: (context, state) {
        if (state is EarningsSuccess) {
          widget.onNext();
        } else if (state is EarningsFailure) {
          Toast.showError(state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your address information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Input your full address and location of residence',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 30),
              TextInputField(
                label: 'Enter your address',
                placeHolder: 'Eg. Calle de Olivos 3, 46',
                controller: _addressController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Enter postal code',
                placeHolder: 'Eg. 28944',
                controller: _postalController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Enter city',
                placeHolder: 'Eg. Fuenlabrada',
                controller: _cityController,
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return PrimaryButton(
                    onTap: state is EarningsLoading ? null : _submit,
                    text: state is EarningsLoading ? "Submitting..." : "Next",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadIDPictureView extends StatefulWidget {
  final VoidCallback onNext;
  const UploadIDPictureView({super.key, required this.onNext});

  @override
  State<UploadIDPictureView> createState() => _UploadIDPictureViewState();
}

class _UploadIDPictureViewState extends State<UploadIDPictureView> {
  Widget _buildIDTypeOption({
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutral100,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.neutral100.withOpacity(0.4),
              child: Icon(
                Iconsax.gallery5,
                color: AppColors.neutral600,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: AppColors.neutral600.withOpacity(0.4),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  void inIDTypeSelected(bool isFront) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select upload type",
                style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Iconsax.close_circle5,
                  color: AppColors.neutral100,
                ),
              ),
            ],
          ),
          Dimens.space(3),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary50,
                child: Icon(
                  Iconsax.camera,
                  color: AppColors.primary500,
                  size: 14,
                ),
              ),
              Dimens.space(2),
              Text(
                'Open Camera',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Dimens.space(2),
          Divider(
            color: AppColors.neutral100.withOpacity(0.3),
            thickness: 1,
          ),
          Dimens.space(2),
          // Delete Notification
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.red50,
                child: Icon(
                  Iconsax.document,
                  color: AppColors.red500,
                  size: 14,
                ),
              ),
              Dimens.space(2),
              Text(
                'Upload',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Dimens.space(4),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload ID Card',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Upload your ID card both sides',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          _buildIDTypeOption(
            title: 'Tap to upload ID Card Front',
            subtitle: 'Only images supported Max: 2MB',
            value: true,
            onTap: () => inIDTypeSelected(true),
          ),
          const SizedBox(height: 16),
          _buildIDTypeOption(
            title: 'Tap to upload ID Card Back',
            subtitle: 'Only images supported Max: 2MB',
            value: false,
            onTap: () => inIDTypeSelected(false),
          ),

          // Add your upload ID picture widget here
          const Spacer(),
          _buildNextButton(
            context,
            widget.onNext,
          ),
        ],
      ),
    );
  }
}

class IDTypePage extends StatefulWidget {
  final VoidCallback onNext;

  const IDTypePage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  State<IDTypePage> createState() => _IDTypePageState();
}

class _IDTypePageState extends State<IDTypePage> {
  bool _isNationalIDSelected = true;

  void _onIDTypeSelected(bool isNationalID) {
    setState(() {
      _isNationalIDSelected = isNationalID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select ID Type',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Select your ID type and upload the front & Back of your Identity Card',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          // Usage inside build()
          _buildIDTypeOption(
            title: 'National ID Card',
            subtitle: 'Your government issued national identity card',
            value: true,
          ),

          const SizedBox(height: 16),
          _buildIDTypeOption(
            title: 'Resident Permit',
            subtitle: 'Your government issued national resident permit',
            value: false,
          ),
          const Spacer(),
          _buildNextButton(context, widget.onNext),
        ],
      ),
    );
  }

  Widget _buildIDTypeOption({
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return InkWell(
      onTap: () => _onIDTypeSelected(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isNationalIDSelected == value
                ? AppColors.primary500
                : AppColors.neutral100,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.card5,
              color: AppColors.neutral600,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: value,
              groupValue: _isNationalIDSelected,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  _onIDTypeSelected(newValue);
                }
              },
              activeColor: AppColors.primary500,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader(int pageIndex) {
  return Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigatorHelper.pop();
        },
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          children: List.generate(
            4, // Fixing to number of actual pages
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index <= pageIndex
                      ? Colors.amber
                      : Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildNextButton(BuildContext context, VoidCallback onNext) {
  return SizedBox(
    width: double.infinity,
    child: PrimaryButton(
      onTap: onNext,
      text: ('Next'),
    ),
  );
}

Widget _buildProfileIcon(Color color) {
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
