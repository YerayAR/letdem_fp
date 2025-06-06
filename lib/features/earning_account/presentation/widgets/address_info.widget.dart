import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class AddressInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  const AddressInfoPage({super.key, required this.onNext});

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
              Text(context.l10n.addressInformationTitle,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(context.l10n.addressInformationDescription,
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 30),
              TextInputField(
                label: context.l10n.enterAddress,
                placeHolder: context.l10n.addressExample,
                controller: _addressController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: context.l10n.enterPostalCode,
                placeHolder: context.l10n.postalCodeExample,
                controller: _postalController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: context.l10n.enterCity,
                placeHolder: context.l10n.cityExample,
                controller: _cityController,
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is EarningsLoading,
                    onTap: state is EarningsLoading ? null : _submit,
                    text: context.l10n.next,
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
