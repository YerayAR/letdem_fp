import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/file_picker/file_picker.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

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
    required String successText,
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
                    !isSelected ? subtitle : successText,
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
            successText: 'front-side.png',
            onDelete: () {
              setState(() {
                _fileFront = null;
              });
            }, // Delete Notification

            file: _fileFront,
            title: 'Tap to upload ID Card Front',
            subtitle: 'Only images supported Max: 6MB',
            isSelected: _fileFront != null,
            onTap: () => inIDTypeSelected(true, (file) {
              setState(() {
                _fileFront = file;
              });
            }),
          ),
          const SizedBox(height: 16),
          _buildIDTypeOption(
            successText: 'back-side.png',
            file: _fileBack,
            onDelete: () {
              setState(() {
                _fileBack = null;
              });
            },
            title: 'Tap to upload ID Card Back',
            subtitle: 'Only images supported Max: 6MB',
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
              return buildNextButton(
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
