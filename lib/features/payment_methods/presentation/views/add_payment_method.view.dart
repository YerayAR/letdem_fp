import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

import '../../../../common/widgets/button.dart';

class AddPaymentMethod extends StatefulWidget {
  const AddPaymentMethod({super.key});

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
            if (state is PaymentMethodLoaded) {
              AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: 'Payment Method Added',
                    subtext: 'Your payment method has been successfully added.',
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
                      title: 'Add Payment Method',
                      icon: Icons.close,
                    ),
                    Dimens.space(2),
                    TextInputField(
                      label: 'Cardholder Name',
                      controller: _nameController,
                      placeHolder: 'Enter your name',
                    ),
                    Dimens.space(3),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Dimens.space(2),
                    Container(
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        children: [
                          CardField(
                            controller: controller,
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400.withOpacity(0.6),
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              hintText: 'Card number',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                controller.complete
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: controller.complete
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.complete
                                    ? 'Valid card'
                                    : 'Enter card details',
                                style: TextStyle(
                                  color: controller.complete
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
                        onTap: controller.complete && !_isLoading
                            ? _handlePayPress
                            : () {
                                Toast.showError(
                                  'Please complete the card details',
                                );
                              },
                        text: 'Create',
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
    if (!controller.complete) return;

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
      Toast.showError('Failed to add payment method. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
