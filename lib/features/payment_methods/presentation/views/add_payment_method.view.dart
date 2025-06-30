import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/payment/payment.model.dart';

import '../../../../common/widgets/button.dart';

class AddPaymentMethod extends StatefulWidget {
  final Function(PaymentMethodModel m)? onPaymentMethodAdded;

  const AddPaymentMethod({super.key, this.onPaymentMethodAdded});

  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final controller = CardEditController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    controller.addListener(update);
    super.initState();
  }

  void update() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
          listener: (context, state) {
            print('PaymentMethodBloc state: $state');
            if (state is PaymentMethodAdded) {
              // Call the callback if provided
              widget.onPaymentMethodAdded?.call(state.paymentMethod);
              context.read<PaymentMethodBloc>().add(
                    const FetchPaymentMethods(),
                  );
              context.read<UserBloc>().add(FetchUserInfoEvent());
              AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: context.l10n.paymentMethodAddedTitle,
                    subtext: context.l10n.paymentMethodAddedSubtext,
                    onProceed: () {
                      NavigatorHelper.pop();
                      NavigatorHelper.pop();
                    },
                  ));
            } else if (state is PaymentMethodError) {
              // Show error message
              Toast.showError(state.message);
            }
            // TODO: implement listener
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: SizedBox(
                child: StyledBody(
                  children: [
                    StyledAppBar(
                      onTap: () => NavigatorHelper.pop(),
                      title: context.l10n.addPaymentMethodTitle,
                      icon: Icons.close,
                    ),
                    Dimens.space(2),
                    // Custom styled name input to match Stripe CardField
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cardholderName,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: context.l10n.enterYourName,
                              hintStyle: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      Colors.blueGrey.shade300.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueGrey,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      Colors.blueGrey.shade300.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cardDetails,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme:
                                  ThemeData.light().colorScheme.copyWith(
                                        primary: Colors.blueGrey,
                                      ),
                            ),
                            child: CardField(
                              decoration: InputDecoration(
                                hintText: context.l10n.enterTheNumber,
                                hintStyle: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.shade300
                                        .withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.blueGrey,
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.shade300
                                        .withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                              ),
                              controller: controller,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                controller.details.complete
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: controller.details.complete
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.details.complete
                                    ? context.l10n.validCard
                                    : context.l10n.enterCardDetails,
                                style: TextStyle(
                                  color: controller.details.complete
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Dimens.space(3),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        isLoading: context.read<PaymentMethodBloc>().state
                                is PaymentMethodLoading ||
                            _isLoading,
                        onTap: (controller.details.complete && !_isLoading)
                            ? _handlePayPress
                            : () {
                                Toast.showError(
                                  context.l10n.pleaseCompleteCardDetails,
                                );
                              },
                        text: context.l10n.create,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePayPress() async {
    if (!controller.details.complete) return;
    if (_nameController.text.trim().isEmpty) {
      Toast.showError(context.l10n.pleaseEnterYourName);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Billing details (replace email with user's actual email if needed)
      final billingDetails = BillingDetails(
        email: context.userProfile!.email,
        name: _nameController.text.trim(),
      );

      // Create Stripe payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // Dispatch Bloc event
      context.read<PaymentMethodBloc>().add(
            RegisterPaymentMethod(
              AddPaymentMethodDTO(
                paymentMethodId: paymentMethod.id,
                holderName: billingDetails.name ?? 'Unknown',
                last4: paymentMethod.card.last4 ?? '****',
                expirationDate:
                    '${paymentMethod.card.expYear}/${paymentMethod.card.expMonth.toString().padLeft(2, '0')}',
                brand: paymentMethod.card.brand ?? 'unknown',
                isDefault: true,
              ),
            ),
          );
    } catch (e) {
      // Handle errors
      print('Error creating payment method: $e');
      Toast.showError(context.l10n.failedToAddPaymentMethod);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
