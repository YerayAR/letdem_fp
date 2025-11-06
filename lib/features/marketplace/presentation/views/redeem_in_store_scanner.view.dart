import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'redeem_in_store_result.view.dart';

class RedeemInStoreScannerView extends StatefulWidget {
  const RedeemInStoreScannerView({super.key});

  @override
  State<RedeemInStoreScannerView> createState() =>
      _RedeemInStoreScannerViewState();
}

class _RedeemInStoreScannerViewState extends State<RedeemInStoreScannerView> {
  bool _isScanning = true;
  bool _flashOn = false;
  MobileScannerController? _scannerController;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
      });
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onQRScanned(String qrData) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    // Detener el escáner
    _scannerController?.stop();

    // Por ahora, cualquier QR es válido
    // TODO: Validar formato del QR y parsear datos del voucher de la tienda
    // TODO: Llamar al backend para validar y aplicar descuento
    
    // Simulación temporal - navegar a resultado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RedeemInStoreResultView(
          success: true,
          storeName: 'Tienda Demo',
          amount: 50.00,
          discount: 15.00, // 30% de descuento
          finalAmount: 35.00,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // TODO: Reemplazar con widget de cámara real
          // MobileScanner(onDetect: (capture) { ... })
          _buildCameraPlaceholder(),
          
          // Overlay con marco de escaneo
          _buildScannerOverlay(),
          
          // Header
          _buildHeader(context),
          
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    if (!_hasPermission) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.camera,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              Dimens.space(3),
              Text(
                'Permiso de cámara denegado',
                style: Typo.mediumBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Dimens.space(2),
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                ),
                child: Text(
                  'Abrir Configuración',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_scannerController == null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary500,
          ),
        ),
      );
    }

    return MobileScanner(
      controller: _scannerController!,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            _onQRScanned(barcode.rawValue!);
            break;
          }
        }
      },
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Marco de escaneo
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary500,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Esquinas del marco
                  _buildCorner(Alignment.topLeft, true, true),
                  _buildCorner(Alignment.topRight, true, false),
                  _buildCorner(Alignment.bottomLeft, false, true),
                  _buildCorner(Alignment.bottomRight, false, false),
                  
                  // Línea de escaneo animada
                  if (_isScanning) _buildScanLine(),
                ],
              ),
            ),
            Dimens.space(4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Coloca el código QR de la tienda dentro del marco',
                textAlign: TextAlign.center,
                style: Typo.mediumBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Dimens.space(1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'El cajero te mostrará el código en su terminal',
                textAlign: TextAlign.center,
                style: Typo.smallBody.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, bool top, bool left) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? BorderSide(color: AppColors.primary500, width: 4)
                : BorderSide.none,
            bottom: !top
                ? BorderSide(color: AppColors.primary500, width: 4)
                : BorderSide.none,
            left: left
                ? BorderSide(color: AppColors.primary500, width: 4)
                : BorderSide.none,
            right: !left
                ? BorderSide(color: AppColors.primary500, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildScanLine() {
    return _RepeatableTweenAnimation(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      repeat: true,
      builder: (context, value, child) {
        return Positioned(
          top: value * 260,
          left: 10,
          right: 10,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.primary500,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.arrow_left,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Escanear QR de Tienda',
                style: Typo.mediumBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  _flashOn = !_flashOn;
                });
                await _scannerController?.toggleTorch();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _flashOn
                      ? AppColors.primary500.withOpacity(0.8)
                      : Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _flashOn ? Iconsax.flash_15 : Iconsax.flash_slash,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Iconsax.document_text,
                    label: 'Ingresar código',
                    onTap: () {
                      _showManualInputDialog();
                    },
                  ),
                ],
              ),
              Dimens.space(2),
              Text(
                'Si no puedes escanear, ingresa el código manualmente',
                textAlign: TextAlign.center,
                style: Typo.smallBody.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary500.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Typo.smallBody.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Ingresar código',
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa el código del voucher de la tienda',
              style: Typo.smallBody.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            Dimens.space(2),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ej: STORE-12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary500,
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _onQRScanned(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirmar',
              style: Typo.mediumBody.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para animación repetida de la línea de escaneo
class _RepeatableTweenAnimation extends StatefulWidget {
  final Tween<double> tween;
  final Duration duration;
  final bool repeat;
  final Widget Function(BuildContext, double, Widget?) builder;

  const _RepeatableTweenAnimation({
    required this.tween,
    required this.duration,
    required this.repeat,
    required this.builder,
  });

  @override
  State<_RepeatableTweenAnimation> createState() =>
      _RepeatableTweenAnimationState();
}

class _RepeatableTweenAnimationState extends State<_RepeatableTweenAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = widget.tween.animate(_controller);

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(context, _animation.value, child),
    );
  }
}
