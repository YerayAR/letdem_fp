import 'dart:io';

import 'dart:ui' as ui;



import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';

import 'package:iconly/iconly.dart';

import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:letdem/common/widgets/appbar.dart';

import 'package:letdem/common/widgets/body.dart';

import 'package:letdem/common/widgets/button.dart';

import 'package:letdem/core/constants/colors.dart';

import 'package:letdem/core/constants/dimens.dart';

import 'package:letdem/core/constants/typo.dart';

import 'package:letdem/features/marketplace/models/voucher.model.dart';

import 'package:letdem/features/marketplace/repository/marketplace_repository.dart';

import 'package:letdem/features/users/user_bloc.dart';

import 'package:letdem/infrastructure/storage/storage/storage.service.dart';

import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';



enum RedeemMode { online, inStore }



class VirtualCardGeneratorView extends StatefulWidget {

  final int availablePoints;



  const VirtualCardGeneratorView({super.key, required this.availablePoints});



  @override

  State<VirtualCardGeneratorView> createState() =>

      _VirtualCardGeneratorViewState();

}



class _VirtualCardGeneratorViewState extends State<VirtualCardGeneratorView> {

  static const int kPointsRequired = 500;



  final MarketplaceRepository _repository = MarketplaceRepository();

  final GlobalKey _cardKey = GlobalKey();



  RedeemMode _redeemMode = RedeemMode.online;

  Voucher? _voucher;

  int _selectedAmount = 0;



  bool _isGenerating = false;

  bool _isSharing = false;

  String? _error;



  List<int> get _amountOptions {

    final steps = widget.availablePoints ~/ kPointsRequired;

    return List.generate(steps, (index) => kPointsRequired * (index + 1));

  }



  @override

  void initState() {

    super.initState();

    final options = _amountOptions;

    _selectedAmount = options.isNotEmpty ? options.first : 0;

  }



  Future<void> _generateCard() async {
    print('[CARD] generate START selectedAmount=$_selectedAmount available=${widget.availablePoints} mode=$_redeemMode');

    if (_selectedAmount < kPointsRequired ||


        _selectedAmount > widget.availablePoints) {


      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(


          content: Text(
            'Selecciona un monto válido en múltiplos de $kPointsRequired puntos.',


          ),


        ),


      );


      return;


    }





    final token = await SecureStorageHelper().read('access_token');


    if (token == null || token.isEmpty) {


      ScaffoldMessenger.of(context).showSnackBar(


        const SnackBar(


          content: Text('Necesitas iniciar sesión para generar la tarjeta.'),


        ),


      );


      return;


    }





    final cardsToCreate = ((_selectedAmount ~/ kPointsRequired).clamp(1, 10)).toInt();
    print('[CARD] will create $cardsToCreate vouchers');

    final redeemType =


        _redeemMode == RedeemMode.online ? 'ONLINE' : 'IN_STORE';





    setState(() {


      _isGenerating = true;


      _error = null;


    });





    try {


      Voucher? lastVoucher;


      for (var i = 0; i < cardsToCreate; i++) {
        print('[CARD] createVirtualCard attempt ${i + 1}/$cardsToCreate');

        final voucher = await _repository.createVirtualCard(


          productId: '',


          redeemType: redeemType,


          authToken: token,


        );


        lastVoucher = voucher;


      }





      if (lastVoucher == null) {


        throw Exception('No se generó ninguna tarjeta');


      }





      context.read<UserBloc>().add(const FetchUserInfoEvent(isSilent: true));





      setState(() {
        _voucher = lastVoucher;
      });

      print('[CARD] generate DONE id=${lastVoucher.id} code=${lastVoucher.code} type=${lastVoucher.redeemType}');





      final message =


          cardsToCreate > 1


              ? 'Generamos  tarjetas de  pts. Revisa tus pendientes.'


              : 'Tarjeta lista para usar o compartir. Expira ';





      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(content: Text(message)),


      );


    } catch (e) {
      print('[CARD] ERROR: '+e.toString());

      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        _error = errorMessage;


      });


      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(content: Text('No pudimos generar la tarjeta: ')),


      );


    } finally {


      setState(() {


        _isGenerating = false;


      });


    }


  }










  Future<void> _shareCard() async {

    final voucher = _voucher;

    if (voucher == null || _isSharing) return;



    try {

      setState(() => _isSharing = true);

      await Future.delayed(const Duration(milliseconds: 120));



      final boundary =

          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {

        throw Exception('No pudimos preparar la tarjeta.');

      }



      final deviceRatio = MediaQuery.of(context).devicePixelRatio;

      final image = await boundary.toImage(

        pixelRatio: deviceRatio < 2 ? 2 : deviceRatio,

      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {

        throw Exception('No pudimos exportar la tarjeta.');

      }



      final directory = await getTemporaryDirectory();

      final file =

          await File(

            '${directory.path}/letdem_card_${voucher.code}.png',

          ).create();

      await file.writeAsBytes(byteData.buffer.asUint8List());



      final validity = DateFormat('dd MMM, HH:mm').format(voucher.expiresAt);

      await Share.shareXFiles(

        [XFile(file.path)],

        subject: 'Tarjeta virtual Letdem',

        text:
            'Código: ${voucher.code}\nVigencia hasta: $validity\nMuéstrala en tienda para completar tu compra.',

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('No pudimos compartir la tarjeta: $e')),

      );

    } finally {

      setState(() => _isSharing = false);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F5F5),

      body: StyledBody(

        children: [

          StyledAppBar(

            title: 'Tarjeta de canje',

            icon: IconlyLight.close_square,

            onTap: () => Navigator.pop(context),

          ),

          Expanded(child: _buildContent()),
        ],

      ),

    );

  }



  Widget _buildContent() {

    return ListView(

      padding: const EdgeInsets.all(16),

      children: [

        _buildHeroCard(),
        if (_error != null) ...[Dimens.space(1), _buildErrorBanner(_error!)],

        Dimens.space(2),

        _buildRedeemTypeSelector(),

        Dimens.space(2),

        _buildAmountSelector(),

        Dimens.space(2),

        _buildPointsSummary(),

        Dimens.space(3),

        PrimaryButton(

          text: _isGenerating ? 'Generando...' : 'Generar tarjeta virtual',

          onTap: _generateCard,

          isLoading: _isGenerating,

          isDisabled:

              _isGenerating ||

              _selectedAmount < kPointsRequired,

          icon: IconlyBold.ticket,

          color: AppColors.primary500,

        ),

        Dimens.space(2),

        _buildCardPreview(),

        Dimens.space(1.5),

        PrimaryButton(

          text: 'Descargar o compartir',

          onTap: (_voucher == null || _isSharing) ? null : _shareCard,

          isDisabled: _voucher == null,

          isLoading: _isSharing,

          icon: IconlyBold.download,

          color: Colors.white,

          textColor: AppColors.primary500,

          outline: true,

          borderColor: AppColors.primary500,

        ),

      ],

    );

  }



  Widget _buildHeroCard() {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [Color(0xFF7B00CC), Color(0xFF4B0082)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF7B00CC).withOpacity(0.3),

            blurRadius: 25,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'Convierte tus puntos en tarjetas virtuales',

            style: Typo.mediumBody.copyWith(

              color: Colors.white.withOpacity(0.8),

            ),

          ),

          Dimens.space(1),

          Text(

            '${widget.availablePoints} pts',

            style: Typo.largeBody.copyWith(

              color: Colors.white,

              fontSize: 46,

              fontWeight: FontWeight.w700,

            ),

          ),

          Dimens.space(1),

          Text(

            _selectedAmount >= kPointsRequired

                ? 'Usaremos $_selectedAmount puntos para generar una tarjeta digital descargable.'

                : 'Necesitas al menos $kPointsRequired puntos para generar una tarjeta digital.',

            style: Typo.smallBody.copyWith(

              color: Colors.white.withOpacity(0.85),

            ),

          ),

        ],

      ),

    );

  }



Widget _buildRedeemTypeSelector() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 12,

            offset: const Offset(0, 6),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            '¿Dónde usarás la tarjeta?',

            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),

          ),

          Dimens.space(1),

          Row(

            children: [

              _buildModeChip(

                label: 'Online (48h)',

                selected: _redeemMode == RedeemMode.online,

                onTap: () => setState(() => _redeemMode = RedeemMode.online),

              ),

              Dimens.space(1),

              _buildModeChip(

                label: 'En tienda (5 min)',

                selected: _redeemMode == RedeemMode.inStore,

                onTap: () => setState(() => _redeemMode = RedeemMode.inStore),

              ),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildAmountSelector() {

    final options = _amountOptions;



    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 12,

            offset: const Offset(0, 6),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            '¿Cuántos puntos quieres convertir?',

            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),

          ),

          Dimens.space(1),

          Text(
            'Cada tarjeta utiliza $kPointsRequired puntos. Generaremos una por cada múltiplo seleccionado.',
            style: Typo.smallBody.copyWith(color: AppColors.neutral600),
          ),

          Dimens.space(1),

          if (options.isEmpty)

            Text(

              'Necesitas al menos $kPointsRequired puntos para generar una tarjeta.',

              style: Typo.smallBody.copyWith(color: AppColors.neutral600),

            )

          else

            Wrap(

              spacing: 8,

              runSpacing: 8,

              children:

                  options

                      .map((amount) => _buildAmountChip(amount))

                      .toList(),

            ),

        ],

      ),

    );

  }



  Widget _buildAmountChip(int amount) {

    final isSelected = amount == _selectedAmount;



    return GestureDetector(

      onTap: () => setState(() => _selectedAmount = amount),

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(12),

          color: isSelected ? AppColors.primary50 : Colors.white,

          border: Border.all(

            color: isSelected ? AppColors.primary500 : AppColors.neutral200,

          ),

        ),

        child: Text(

          '$amount pts',

          style: Typo.mediumBody.copyWith(

            color: isSelected ? AppColors.primary500 : AppColors.neutral700,

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

    );

  }



  Widget _buildPointsSummary() {

    final validityText =
        _redeemMode == RedeemMode.online
            ? '48 horas de vigencia desde la generación.'
            : '5 minutos de vigencia. Úsala apenas llegues a tienda.';



    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 12,

            offset: const Offset(0, 6),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'Resumen',

            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),

          ),

          Dimens.space(1),

          Row(

            children: [

              _buildSummaryItem(

                title: 'Puntos usados',

                value:

                    _selectedAmount >= kPointsRequired

                        ? '$_selectedAmount pts'

                        : '-',

              ),

              Dimens.space(2),

              _buildSummaryItem(

                title: 'Vigencia',

                value: _redeemMode == RedeemMode.online ? '48 h' : '5 min',

              ),

            ],

          ),

          Dimens.space(1),

          Text(

            validityText,

            style: Typo.smallBody.copyWith(color: AppColors.neutral600),

          ),

        ],

      ),

    );

  }



  Widget _buildSummaryItem({required String title, required String value}) {

    return Expanded(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: Typo.smallBody.copyWith(color: AppColors.neutral600),

          ),

          Dimens.space(0.5),

          Text(

            value,

            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),

          ),

        ],

      ),

    );

  }



  Widget _buildModeChip({

    required String label,

    required bool selected,

    required VoidCallback onTap,

  }) {

    return Expanded(

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Container(

          padding: const EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12),

            color: selected ? AppColors.primary50 : Colors.white,

            border: Border.all(

              color: selected ? AppColors.primary500 : AppColors.neutral200,

            ),

          ),

          child: Center(

            child: Text(

              label,

              style: Typo.mediumBody.copyWith(

                color: selected ? AppColors.primary500 : AppColors.neutral700,

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

        ),

      ),

    );

  }



  Widget _buildCardPreview() {

    final voucher = _voucher;

    final productName =
        (voucher?.productName?.isNotEmpty ?? false)
            ? voucher!.productName
            : 'Tarjeta virtual Letdem';

    final storeName =
        (voucher?.storeName?.isNotEmpty ?? false)
            ? voucher!.storeName
            : 'Letdem Marketplace';

    final code = voucher?.code ?? 'LETDEM-00000';

    final validity =

        voucher != null

            ? DateFormat('dd MMM  HH:mm').format(voucher.expiresAt)

            : (_redeemMode == RedeemMode.online ? '48h' : '5 min');



    return RepaintBoundary(

      key: _cardKey,

      child: Container(

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(

          gradient: const LinearGradient(

            colors: [Color(0xFF4B0082), Color(0xFF9D00FF)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

          borderRadius: BorderRadius.circular(28),

          boxShadow: [

            BoxShadow(

              color: const Color(0xFF4B0082).withOpacity(0.3),

              blurRadius: 24,

              offset: const Offset(0, 12),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Letdem Rewards',

                      style: Typo.largeBody.copyWith(

                        color: Colors.white,

                        fontSize: 22,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    Text(

                      _redeemMode == RedeemMode.online

                          ? 'Uso online'

                          : 'Uso en tienda',

                      style: Typo.smallBody.copyWith(

                        color: Colors.white.withOpacity(0.8),

                      ),

                    ),

                  ],

                ),

                Flexible(

                  child: Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 12,

                      vertical: 6,

                    ),

                    decoration: BoxDecoration(

                      color: Colors.white.withOpacity(0.2),

                      borderRadius: BorderRadius.circular(100),

                    ),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        const Icon(Icons.timer, color: Colors.white, size: 18),

                        Dimens.space(1),

                        Flexible(

                          child: Text(

                            validity,

                            overflow: TextOverflow.ellipsis,

                            style: Typo.smallBody.copyWith(

                              color: Colors.white,

                              fontWeight: FontWeight.w600,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

              ],

            ),

            Dimens.space(3),

            Text(

              _formatCode(code),

              style: Typo.largeBody.copyWith(

                color: Colors.white,

                fontSize: 28,

                letterSpacing: 2,

              ),

            ),

            Dimens.space(2),

            Row(
              children: [
                Expanded(
                  child: _buildCardInfo(
                    title: 'Producto',
                    value: productName.isEmpty ? '' : productName,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildCardInfo(
                    title: 'Tienda',
                    value: storeName.isEmpty ? '' : storeName,
                  ),
                ),
              ],
            ),

          ],

        ),

      ),

    );

  }



  Widget _buildCardInfo({required String title, required String value}) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: Typo.smallBody.copyWith(color: Colors.white.withOpacity(0.7)),

        ),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Typo.mediumBody.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

      ],

    );

  }



  Widget _buildErrorBanner(String message) {

    return Container(

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: AppColors.red50,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppColors.red200),

      ),

      child: Row(

        children: [

          Icon(Icons.error_outline, color: AppColors.red500),

          Dimens.space(1),

          Expanded(

            child: Text(

              message,

              style: Typo.smallBody.copyWith(color: AppColors.red700),

            ),

          ),

        ],

      ),

    );

  }



  String _formatCode(String code) {

    final alphanumeric = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

    final buffer = StringBuffer();

    for (int i = 0; i < alphanumeric.length; i++) {

      if (i > 0 && i % 4 == 0) buffer.write(' ');

      buffer.write(alphanumeric[i].toUpperCase());

    }

    return buffer.toString();

  }



  String _validityLabel(String redeemType) {

    switch (redeemType) {

      case 'IN_STORE':

        return 'en 5 minutos';

      case 'ONLINE':

      default:

        return 'en 48 horas';

    }

  }

}
