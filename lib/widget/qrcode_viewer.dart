import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tmcapp/controller/EventController.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final EventController eventController = EventController.to;
  final flashStatus = false.obs;
  final frontCamera = false.obs;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Container(child: _buildQrView(context)),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(color: GFColors.DARK),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Flash",
                          style: TextStyle(color: Colors.white)),
                      Obx(() => GFToggle(
                            onChanged: (val) async {
                              await controller?.toggleFlash();
                              val == true
                                  ? setState(() {
                                      flashStatus.value = false;
                                    })
                                  : setState(() {
                                      flashStatus.value = true;
                                    });
                            },
                            enabledTrackColor: CupertinoColors.activeOrange,
                            value: flashStatus.value == false ? false : true,
                            type: GFToggleType.ios,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Front Camera",
                        style: TextStyle(color: Colors.white),
                      ),
                      GFToggle(
                        onChanged: (val) async {
                          await controller?.flipCamera();
                          val == false
                              ? setState(() {
                                  frontCamera.value = false;
                                })
                              : setState(() {
                                  frontCamera.value = true;
                                });
                        },
                        value: frontCamera.value == true ? true : false,
                        enabledTrackColor: CupertinoColors.activeOrange,
                        type: GFToggleType.ios,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: CupertinoColors.systemOrange,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    var flashStatusCek = await controller.getFlashStatus();
    var kameraInfoCek = describeEnum(await controller.getCameraInfo());

    setState(() {
      this.controller = controller;
      if (flashStatusCek == false) {
        flashStatus.value == false;
      } else {
        flashStatus.value == false;
      }
      if (kameraInfoCek.toUpperCase() == "BACK") {
        frontCamera.value == false;
      } else {
        frontCamera.value == false;
      }
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        eventController.setQrCodeScanResult(result!.code);
        controller.stopCamera();
        controller.dispose();
        Navigator.of(Get.context!).pop();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
