import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  int? selectedMethodIndex;
  bool showOptionsBottomSheet = false;
  bool showDeleteConfirmDialog = false;

  @override
  initState() {
    super.initState();
    // Fetch payout methods when the screen is initialized
    context.read<PayoutMethodBloc>().add(FetchPayoutMethods());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<PayoutMethodBloc, PayoutMethodState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return StyledBody(
                isBottomPadding: false,
                children: [
                  StyledAppBar(
                    title: 'Payout Methods',
                    onTap: () => Navigator.of(context).pop(),
                    icon: Icons.close,
                  ),
                  Dimens.space(2),
                  Expanded(
                    child: state is PayoutMethodLoading ||
                            state is PayoutMethodInitial
                        ? Center(
                            child: CupertinoActivityIndicator(),
                          )
                        : state is PayoutMethodFailure
                            ? Center(
                                child: Text(
                                  state.message,
                                  style: Typo.mediumBody.copyWith(
                                    color: AppColors.red500,
                                  ),
                                ),
                              )
                            :

                            //     empty state
                            state is PayoutMethodSuccess &&
                                    state.methods.isEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const EmptyPayoutMethodView(),
                                      Dimens.space(2),
                                      _buildAddPayoutMethodButton(),
                                    ],
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    itemCount: (state as PayoutMethodSuccess)
                                            .methods
                                            .length +
                                        1, // +1 for the add button
                                    itemBuilder: (context, index) {
                                      if (index == (state).methods.length) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: _buildAddPayoutMethodButton(),
                                        );
                                      }

                                      final method =
                                          (state as PayoutMethodSuccess)
                                              .methods[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: _buildPayoutMethodCard(
                                            method, index),
                                      );
                                    },
                                  ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethodCard(PayoutMethod method, int index) {
    return OptionItem(
      method: method,
      onTap: () {
        AppPopup.showBottomSheet(
            context,
            Container(
              padding: EdgeInsets.symmetric(horizontal: Dimens.defaultMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "Payout Method Options",
                        style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      Dimens.space(1),
                      const Spacer(),
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
                  Dimens.space(2),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.primary50,
                          child: Icon(
                            Iconsax.edit,
                            color: AppColors.primary600,
                            size: 17,
                          ),
                        ),
                        Dimens.space(1),
                        Text("Edit",
                            style: Typo.largeBody.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                  Dimens.space(2),
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    height: 1,
                  ),
                  Dimens.space(2),
                  GestureDetector(
                    onTap: () {
                      context.read<PayoutMethodBloc>().add(
                            DeletePayoutMethod(method.id),
                          );
                      NavigatorHelper.pop();
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.red50,
                          child: Icon(
                            Iconsax.trash,
                            color: AppColors.red500,
                            size: 17,
                          ),
                        ),
                        Dimens.space(1),
                        Text("Delete",
                            style: Typo.largeBody.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                  Dimens.space(2),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildAddPayoutMethodButton() {
    return PrimaryButton(
      text: 'Add Payout Method',
      background: AppColors.primary500,
      textColor: Colors.white,
      onTap: () {
        NavigatorHelper.to(AddPayoutMethodView());
        // Handle add payout method logic
      },
    );
  }
}

class AddPayoutMethodView extends StatefulWidget {
  const AddPayoutMethodView({super.key});

  @override
  State<AddPayoutMethodView> createState() => _AddPayoutMethodViewState();
}

class _AddPayoutMethodViewState extends State<AddPayoutMethodView> {
  late TextEditingController _accountNumberController;

  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    _accountNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PayoutMethodBloc, PayoutMethodState>(
        listener: (context, state) {
          if (state is PayoutMethodFailure) {
            Toast.showError(state.message);
          }
          if (state is PayoutMethodSuccess) {
            AppPopup.showDialogSheet(
                context,
                SuccessDialog(
                  title: "Payout Method Added",
                  subtext: "Your payout method has been added successfully.",
                  onProceed: () {
                    NavigatorHelper.pop();
                    NavigatorHelper.pop();
                  },
                ));
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            isBottomPadding: false,
            children: [
              StyledAppBar(
                title: 'Add Payout Method',
                onTap: () => Navigator.of(context).pop(),
                icon: Icons.close,
              ),
              Dimens.space(2),
              TextInputField(
                controller: _accountNumberController,
                label: 'Account Number',
                placeHolder: 'Eg. ES91 2100 0418 4502 0005 1332',
              ),
              Row(
                children: [
                  Text("Make as default payment method",
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral600,
                      )),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = !isDefault;
                        });
                        // Handle switch change
                      },
                      activeColor: AppColors.primary500,
                    ),
                  ),
                ],
              ),
              Dimens.space(5),
              PrimaryButton(
                text: 'Add Payout Method',
                background: AppColors.primary500,
                textColor: Colors.white,
                isLoading: state is PayoutMethodLoading,
                onTap: () {
                  if (_accountNumberController.text.trim().isEmpty) {
                    Toast.showError("Please enter account number");
                    return;
                  }
                  print(
                      "Account Number: ${_accountNumberController.text.trim()}");
                  context.read<PayoutMethodBloc>().add(
                        AddPayoutMethod(
                          PayoutMethodDTO(
                            accountNumber: _accountNumberController.text.trim(),
                            isDefault: isDefault,
                          ),
                        ),
                      );
                  // Handle add payout method logic
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final PayoutMethod method;
  final void Function()? onTap;

  final bool isSelectable;
  final bool? isSelected;

  const OptionItem({
    Key? key,
    required this.method,
    this.isSelectable = false,
    this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectable) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary50.withOpacity(0.5),
                    radius: 26,
                    child: Center(
                      child: Icon(
                        Iconsax.building,
                        color: AppColors.primary500,
                        size: 24,
                      ),
                    ),
                  ),
                  Spacer(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (onTap != null) {
                        onTap!();
                      }
                    },
                    child: isSelectable
                        ? CircleAvatar(
                            backgroundColor: isSelected == true
                                ? AppColors.primary500
                                : AppColors.neutral50,
                            radius: 12,
                            child: Icon(
                              Icons.check,
                              color: isSelected == true
                                  ? Colors.white
                                  : AppColors.neutral200,
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.more_horiz,
                            color: AppColors.neutral200,
                          ),
                  ),
                ],
              ),
              Dimens.space(2),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.accountNumber,
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (method.isDefault)
                          DecoratedChip(
                            text: 'Default',
                            textSize: 10,
                            color: AppColors.secondary600,
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${method.accountHolderName}',
                      style:
                          Typo.smallBody.copyWith(color: AppColors.neutral300),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyPayoutMethodView extends StatelessWidget {
  const EmptyPayoutMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Iconsax
                  .card5, // You can use Iconsax.wallet or Iconsax.bank as well
              size: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Payout Methods Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your added payout methods will appear\nhere once you set them up in your profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
