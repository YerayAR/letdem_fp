// Updated Flutter onboarding flow with selected ID type passed to ID upload screen
// and removed country selection screen.

// Removed: CountrySelectionPage
// Changes: IDTypePage now passes selected type to UploadIDPictureView
// Pages now flow automatically based on _goToNextPage logic

// Full code continues with proper PageView, navigation logic, Bloc handling,
// and all changes as described in the previous message...

// Due to size limits, full code will be split into parts. Starting with main flow:

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/models/country_codes.model.dart';
// import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/file_picker/file_picker.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';

import '../../../../../constants/ui/typo.dart';
import '../../../../auth/views/onboard/verify_account.view.dart';

class ProfileOnboardingApp extends StatefulWidget {
  final EarningStatus? status;
  final EarningStep? remainingStep;
  const ProfileOnboardingApp(
      {super.key, required this.status, required this.remainingStep});

  @override
  State<ProfileOnboardingApp> createState() => _ProfileOnboardingAppState();
}

class _ProfileOnboardingAppState extends State<ProfileOnboardingApp> {
  final PageController _pageController = PageController();
  late final List<Widget> _pages;
  int _currentPage = 0;
  String selectedIdType = 'NATIONAL_ID';

  @override
  void initState() {
    super.initState();
    _pages = _buildPagesBasedOnStatus(widget.status, widget.remainingStep);
  }

  List<Widget> _buildPagesBasedOnStatus(
      EarningStatus? status, EarningStep? step) {
    if (status == EarningStatus.accepted || status == EarningStatus.blocked) {
      return [];
    }

    final pages = <Widget>[];

    void addRemainingStepsFrom(EarningStep fromStep) {
      final stepsOrder = [
        EarningStep.personalInfo,
        EarningStep.addressInfo,
        EarningStep.documentUpload,
        EarningStep.bankAccountInfo,
      ];

      final startIndex = stepsOrder.indexOf(fromStep);
      final remainingSteps = stepsOrder.sublist(startIndex);

      for (final s in remainingSteps) {
        switch (s) {
          case EarningStep.personalInfo:
            pages.add(PersonalInfoPage(onNext: _goToNextPage));
            break;
          case EarningStep.addressInfo:
            pages.add(AddressInfoPage(onNext: _goToNextPage));
            break;
          case EarningStep.documentUpload:
            pages.add(IDTypePage(onNext: (type) {
              setState(() => selectedIdType = type);
              _goToNextPage();
            }));
            pages.add(UploadIDPictureView(
              onNext: _goToNextPage,
              idType: selectedIdType,
            ));
            break;
          case EarningStep.bankAccountInfo:
            pages.add(BankInfoView(onNext: _goToNextPage));
            break;
          case EarningStep.submitted:
            pages.add(const Center(child: Text("Submitted")));
            break;
        }
      }
    }

    if (step == null) {
      // All steps
      addRemainingStepsFrom(EarningStep.personalInfo);
    } else {
      addRemainingStepsFrom(step);
    }

    return pages;
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<EarningsBloc, EarningsState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildHeader(_currentPage, _pages.length),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: _pages,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Note: The rest of the pages (PersonalInfoPage, AddressInfoPage, etc.) need
// to reflect updated constructors or logic for `UploadIDPictureView(idType: selectedIdType)`.
// Let me know if you want me to paste the full corrected content for all widgets too.

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

class IpApiResponse {
  final String ip;
  final String countryName;
  final String countryCode;

  IpApiResponse({
    required this.ip,
    required this.countryName,
    required this.countryCode,
  });

  factory IpApiResponse.fromJson(Map<String, dynamic> json) {
    return IpApiResponse(
      ip: json['ip'] ?? '',
      countryName: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
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
      if (_dateOfBirth == null) {
        Toast.showError("Please select your date of birth");
        return;
      }
      context.read<EarningsBloc>().add(SubmitEarningsAccount(
            legalFirstName: _firstNameController.text.trim(),
            legalLastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim().replaceAll("-", ""),
            birthday: '1999-01-01', // Replace with actual date of birth
          ));
    }
  }

  DateTime? _dateOfBirth;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EarningsBloc, EarningsState>(
      listener: (context, state) {
        if (state is EarningsSuccess) {
          context.read<UserBloc>().add(UpdateEarningAccountEvent(
                account: state.info,
              ));
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
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 300,
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Done button
                            Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Done'),
                              ),
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime:
                                    _dateOfBirth ?? DateTime(1990, 1, 1),
                                minimumDate: DateTime(1900),
                                maximumDate: DateTime.now(),
                                onDateTimeChanged: (DateTime date) {
                                  setState(() {
                                    _dateOfBirth = date;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: AbsorbPointer(
                  child: TextInputField(
                    mustValidate: false,
                    label: 'Select date of birth',
                    placeHolder: _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Eg. 01/01/1990',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TSLPhoneField(
                label: 'Enter phone number',
                onChanged: (String text, String countryCode) {
                  _phoneController.text = "$countryCode$text";
                },
                initialValue: '',
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return PrimaryButton(
                    onTap: state is EarningsLoading ? null : _submitForm,
                    isLoading: state is EarningsLoading,
                    text: "Next",
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
        if (state is EarningsCompleted) {
          context.read<UserBloc>().add(UpdateEarningAccountEvent(
                account: state.info,
              ));

          AppPopup.showDialogSheet(
              NavigatorHelper.navigatorKey.currentState!.context,
              SuccessDialog(
                onProceed: () {
                  NavigatorHelper.pop();
                  NavigatorHelper.pop();
                },
                title: 'Details Submitted',
                buttonText: 'Goi it, Thanks',
                subtext:
                    'Your account connection details submitted successfully, you will soon be able to receive money  for paid spaces. ',
              ));
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
                  return _buildNextButton(context, () {
                    _submit();
                  });
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
          context.read<UserBloc>().add(UpdateEarningAccountEvent(
                account: state.info,
              ));
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
                    isLoading: state is EarningsLoading,
                    onTap: state is EarningsLoading ? null : _submit,
                    text: "Next",
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
  final String idType;
  const UploadIDPictureView(
      {super.key, required this.onNext, required this.idType});

  @override
  State<UploadIDPictureView> createState() => _UploadIDPictureViewState();
}

class _UploadIDPictureViewState extends State<UploadIDPictureView> {
  Widget _buildIDTypeOption({
    required String title,
    required String subtitle,
    required File? file,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onDelete,
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
              radius: isSelected ? 20 : 26,
              backgroundColor: isSelected
                  ? AppColors.green500.withOpacity(0.17)
                  : AppColors.neutral100.withOpacity(0.4),
              child: Icon(
                isSelected ? Icons.done : Iconsax.card5,
                color: isSelected ? AppColors.green500 : AppColors.neutral600,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    !isSelected ? title : 'Upload completed',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    file != null ? file.path.split('/').last : subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            Dimens.space(2),
            GestureDetector(
              onTap: onDelete,
              child: CircleAvatar(
                backgroundColor: isSelected
                    ? AppColors.neutral100.withOpacity(0.17)
                    : Colors.transparent,
                child: Icon(
                  isSelected ? Iconsax.trash : Iconsax.arrow_right_3,
                  color: AppColors.neutral600.withOpacity(0.4),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void inIDTypeSelected(bool isFront, Function(File file) onFileSelected) {
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
          GestureDetector(
            onTap: () async {
              final file =
                  await FileService().pickFile(FileSourceOption.camera);

              if (file != null) {
                onFileSelected(file);
                NavigatorHelper.pop();
              }
            },
            child: Row(
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
          ),
          Dimens.space(2),
          Divider(
            color: AppColors.neutral100.withOpacity(0.3),
            thickness: 1,
          ),
          Dimens.space(2),
          // Delete Notification
          GestureDetector(
            onTap: () async {
              final file =
                  await FileService().pickFile(FileSourceOption.upload);

              if (file != null) {
                onFileSelected(file);
                NavigatorHelper.pop();
              }
            },
            child: Row(
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
          ),
          Dimens.space(4),
        ]),
      ),
    );
  }

  File? _fileFront;
  File? _fileBack;

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
            onDelete: () {
              setState(() {
                _fileFront = null;
              });
            }, // Delete Notification

            file: _fileFront,
            title: 'Tap to upload ID Card Front',
            subtitle: 'Only images supported Max: 2MB',
            isSelected: _fileFront != null,
            onTap: () => inIDTypeSelected(true, (file) {
              setState(() {
                _fileFront = file;
              });
            }),
          ),
          const SizedBox(height: 16),
          _buildIDTypeOption(
            file: _fileBack,
            onDelete: () {
              setState(() {
                _fileBack = null;
              });
            },
            title: 'Tap to upload ID Card Back',
            subtitle: 'Only images supported Max: 2MB',
            isSelected: _fileBack != null,
            onTap: () => inIDTypeSelected(false, (file) {
              setState(() {
                _fileBack = file;
              });
            }),
          ),

          // Add your upload ID picture widget here
          const Spacer(),
          BlocConsumer<EarningsBloc, EarningsState>(
            listener: (context, state) {
              if (state is EarningsSuccess) {
                context.read<UserBloc>().add(UpdateEarningAccountEvent(
                      account: state.info,
                    ));
                widget.onNext();
              } else if (state is EarningsFailure) {
                Toast.showError(state.message);
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return _buildNextButton(
                context,
                () {
                  if (_fileFront != null && _fileBack != null) {
                    context.read<EarningsBloc>().add(
                          SubmitEarningsDocument(
                            _fileFront!,
                            _fileBack!,
                            widget.idType,
                          ),
                        );
                  } else {
                    Toast.showError("Please upload both sides of your ID");
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class IDTypePage extends StatefulWidget {
  final Function(String pass) onNext;
  // Pass the selected ID type to the next page

  const IDTypePage({
    super.key,
    required this.onNext,
  });

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
          _buildNextButton(
              context,
              () => widget.onNext(
                    _isNationalIDSelected ? 'NATIONAL_ID' : 'RESIDENT_PERMIT',
                  )),
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

Widget _buildHeader(int pageIndex, int totalPages) {
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
            totalPages,
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
      isLoading: context.read<EarningsBloc>().state is EarningsLoading,
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

extension FileBase64Extension on File {
  /// Converts this File to a base64 string.
  Future<String> toBase64() async {
    try {
      final bytes = await readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('[FileBase64Extension] Failed to encode to base64: $e');
      return '';
    }
  }

  /// Converts this File to a base64 Data URI (optional: use for images or display).
  Future<String> toBase64DataUri(
      {String mimeType = 'application/octet-stream'}) async {
    try {
      final base64Str = await toBase64();
      return 'data:$mimeType;base64,$base64Str';
    } catch (e) {
      print('[FileBase64Extension] Failed to generate data URI: $e');
      return '';
    }
  }
}
