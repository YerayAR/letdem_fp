import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _addressController.dispose();
    _postalController.dispose();
    _cityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    
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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.defaultMargin),
            child: ListView(
              controller: _scrollController,
              children: [
                Text(context.l10n.addressInformationTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(context.l10n.addressInformationDescription,
                    style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
                const SizedBox(height: 30),
                TextInputField(
                  label: context.l10n.address,
                  placeHolder: context.l10n.enterAddress,
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextInputField(
                  label: context.l10n.postalCode,
                  placeHolder: context.l10n.enterPostalCode,
                  controller: _postalController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextInputField(
                  label: context.l10n.city,
                  placeHolder: context.l10n.enterCity,
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    // Scroll to show the button
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 30),
                BlocBuilder<EarningsBloc, EarningsState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      isLoading: state is EarningsLoading,
                      onTap: state is EarningsLoading ? null : _submit,
                      text: context.l10n.next,
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}