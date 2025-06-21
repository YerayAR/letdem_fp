import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/enums/EarningStatus.dart';
import 'package:letdem/core/enums/EarningStep.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/presentation/widgets/address_info.widget.dart';
import 'package:letdem/features/earning_account/presentation/widgets/bank_info.widget.dart';
import 'package:letdem/features/earning_account/presentation/widgets/id_selector.widget.dart';
import 'package:letdem/features/earning_account/presentation/widgets/id_type_selector.widget.dart';
import 'package:letdem/features/earning_account/presentation/widgets/personal_info.widget.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class ConnectAccountView extends StatefulWidget {
  final EarningStatus? status;
  final EarningStep? remainingStep;
  const ConnectAccountView(
      {super.key, required this.status, required this.remainingStep});

  @override
  State<ConnectAccountView> createState() => _ConnectAccountViewState();
}

class _ConnectAccountViewState extends State<ConnectAccountView> {
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
            pages.add(Center(child: Text(context.l10n.submitted)));
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

Widget buildNextButton(BuildContext context, VoidCallback onNext) {
  return SizedBox(
    width: double.infinity,
    child: PrimaryButton(
      isLoading: context.read<EarningsBloc>().state is EarningsLoading,
      onTap: onNext,
      text: context.l10n.next,
    ),
  );
}

Widget buildProfileIcon(Color color) {
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
