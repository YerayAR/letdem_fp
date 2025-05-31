import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/country_codes.model.dart';

class PersonalInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  const PersonalInfoPage({super.key, required this.onNext});

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
          padding: EdgeInsets.symmetric(horizontal: Dimens.defaultMargin),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
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
                                // maximumDate for age 18
                                maximumDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 18)),
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
              Dimens.space(3),
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
