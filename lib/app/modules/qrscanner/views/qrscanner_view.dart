import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/qrscanner_controller.dart';

class QrscannerView extends StatefulWidget {
  const QrscannerView({super.key});

  @override
  State<QrscannerView> createState() => _QrscannerViewState();
}

class _QrscannerViewState extends State<QrscannerView>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.put(QrscannerController());
  bool _hasPermission = false;
  MobileScannerController? _cameraController;
  bool _isCameraActive = false;
  bool _hasScanned = false; // New flag to prevent multiple scans

  @override
  bool get wantKeepAlive => false; // Don't keep alive when not visible

  @override
  void initState() {
    super.initState();
    _hasScanned = false; // Reset flag on init
    _checkPermission();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    setState(() {
      _hasPermission = status.isGranted;
    });

    if (status.isPermanentlyDenied) {
      // If permanently denied, prompt user to open settings
      Get.snackbar(
        'Permission Required',
        'Camera permission is permanently denied. Please enable it in app settings.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _startCamera() {
    if (_hasPermission && !_isCameraActive) {
      _cameraController = MobileScannerController();
      setState(() {
        _isCameraActive = true;
      });
    }
  }

  void _stopCamera() {
    if (_isCameraActive) {
      _cameraController?.dispose();
      setState(() {
        _isCameraActive = false;
        _cameraController = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return _buildScanner();
  }

  Widget _buildPermissionRequest() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Camera permission is required to scan QR codes.",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Grant Permission",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text(
                "Open App Settings",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraActive)
            MobileScanner(
              controller: _cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && !_hasScanned) {
                  // Check flag to prevent multiples
                  _hasScanned = true; // Set flag
                  final first = barcodes.first;
                  if (first.rawValue != null) {
                    controller.setScannedCode(first.rawValue!);
                    Get.snackbar(
                      'Scanned Successfully',
                      first.rawValue!,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                    _stopCamera(); // Stop camera immediately after scan
                    // Navigate after a brief delay to show snackbar/value
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      Get.toNamed(
                          '/create-complaint'); // Adjust route name if different
                    });
                  }
                }
              },
            ),
          _ScannerOverlay(),
          const _AnimatedLaserLine(),
          const Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Text(
              "Align the QR code within the frame to scan",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Obx(() => controller.scannedCode.isNotEmpty
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      controller.scannedCode.value,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route?.isCurrent ?? false) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }

  @override
  void didUpdateWidget(QrscannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final route = ModalRoute.of(context);
    if (route?.isCurrent ?? false) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double frameSize = constraints.maxWidth * 0.75;
      return Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: frameSize,
                    height: frameSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _AnimatedLaserLine extends StatefulWidget {
  const _AnimatedLaserLine();

  @override
  State<_AnimatedLaserLine> createState() => _AnimatedLaserLineState();
}

class _AnimatedLaserLineState extends State<_AnimatedLaserLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    double frameSize = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value * (frameSize / 2 - 10)),
            child: Container(
              width: frameSize - 10,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
