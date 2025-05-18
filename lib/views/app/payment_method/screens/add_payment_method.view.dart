import 'package:flutter/material.dart';

class AddPaymentMethod extends StatefulWidget {
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  // final controller = CardEditController();
  final _nameController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    // controller.addListener(update);
    super.initState();
  }

  void update() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    // controller.removeListener(update);
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: SafeArea(
        //   child: SingleChildScrollView(
        //     child: SizedBox(
        //       child: StyledBody(
        //         children: [
        //           StyledAppBar(
        //             onTap: () => NavigatorHelper.pop(),
        //             title: 'Add Payment Method',
        //             icon: Icons.close,
        //           ),
        //           Dimens.space(2),
        //           TextInputField(
        //             label: 'Cardholder Name',
        //             controller: _nameController,
        //             placeHolder: 'Enter your name',
        //           ),
        //           Dimens.space(3),
        //           Divider(height: 1, color: Colors.grey.shade300),
        //           Dimens.space(2),
        //           Container(
        //             padding: EdgeInsets.all(16),
        //             child: Column(
        //               children: [
        //                 // CardField(
        //                 //   controller: controller,
        //                 //   decoration: InputDecoration(
        //                 //     border: InputBorder.none,
        //                 //     hintText: 'Card number',
        //                 //     hintStyle: TextStyle(color: Colors.grey.shade400),
        //                 //   ),
        //                 // ),
        //                 SizedBox(height: 8),
        //                 Row(
        //                   children: [
        //                     Icon(
        //                       controller.complete
        //                           ? Icons.check_circle
        //                           : Icons.info_outline,
        //                       color: controller.complete
        //                           ? Colors.green
        //                           : Colors.grey,
        //                       size: 16,
        //                     ),
        //                     SizedBox(width: 8),
        //                     Text(
        //                       controller.complete
        //                           ? 'Valid card'
        //                           : 'Enter card details',
        //                       style: TextStyle(
        //                         color: controller.complete
        //                             ? Colors.green
        //                             : Colors.grey,
        //                         fontSize: 12,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Dimens.space(3),
        //           SizedBox(
        //             width: double.infinity,
        //             child: PrimaryButton(
        //               onTap: controller.complete && !_isLoading
        //                   ? _handlePayPress
        //                   : null,
        //               text: 'Next',
        //               isLoading: _isLoading,
        //             ),
        //           ),
        //           SizedBox(height: 24),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        );
  }

  Future<void> _handlePayPress() async {
    // if (!controller.complete) return;

    // setState(() => _isLoading = true);
    //
    // try {
    //   // Billing details (replace email with user's actual email if needed)
    //   final billingDetails = BillingDetails(
    //     email: 'email@stripe.com',
    //     name: _nameController.text.trim(),
    //   );
    //
    //   // Create Stripe payment method
    //   final paymentMethod = await Stripe.instance.createPaymentMethod(
    //     params: PaymentMethodParams.card(
    //       paymentMethodData: PaymentMethodData(
    //         billingDetails: billingDetails,
    //       ),
    //     ),
    //   );
    //
    //   // Dispatch Bloc event
    //   context.read<PaymentMethodBloc>().add(
    //         RegisterPaymentMethod(
    //           AddPaymentMethodDTO(
    //             paymentMethodId: paymentMethod.id,
    //             holderName: billingDetails.name ?? 'Unknown',
    //             last4: paymentMethod.card?.last4 ?? '****',
    //             brand: paymentMethod.card?.brand ?? 'unknown',
    //             isDefault: true,
    //           ),
    //         ),
    //       );
    //
    //   Navigator.of(context).pop();
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error: ${e.toString()}')),
    //   );
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }
}
