import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';

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
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
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

                                  final method = (state as PayoutMethodSuccess)
                                      .methods[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child:
                                        _buildPayoutMethodCard(method, index),
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
    return Container(
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
                    setState(() {
                      selectedMethodIndex = index;
                      showOptionsBottomSheet = true;
                    });
                  },
                  child: Icon(
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
                    style: Typo.smallBody.copyWith(color: AppColors.neutral300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildOptionsBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showOptionsBottomSheet = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payout options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showOptionsBottomSheet = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildOptionItem(
                      icon: Icons.edit,
                      iconColor: Colors.purple,
                      title: 'Edit',
                      onTap: () {
                        setState(() {
                          showOptionsBottomSheet = false;
                        });
                        // Handle edit logic
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildOptionItem(
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      title: 'Delete',
                      onTap: () {
                        setState(() {
                          showOptionsBottomSheet = false;
                          showDeleteConfirmDialog = true;
                        });
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showDeleteConfirmDialog = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade400,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Confirm Delete Payout Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure you want to this payout method?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'No, Keep',
                    background: AppColors.primary500,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() {
                        showDeleteConfirmDialog = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (selectedMethodIndex != null) {}
                        showDeleteConfirmDialog = false;
                      });
                    },
                    child: Text(
                      'Yes, Delete',
                      style: TextStyle(
                        color: Colors.red.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            Toast.show('Payout method added successfully');
            context.read<PayoutMethodBloc>().add(FetchPayoutMethods());
            NavigatorHelper.pop();
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
              const TextInputField(
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
                  context.read<PayoutMethodBloc>().add(
                        AddPayoutMethod(
                          PayoutMethodDTO(
                            accountNumber: _accountNumberController.text,
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
