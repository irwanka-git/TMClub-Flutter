import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/widget/button_style.dart';
import '../controller/ImageController.dart';

class ImageUploaderBase64 extends StatefulWidget {
  final String base64ImageUpload;
  final String base64ImageRender;
  @override
  // ignore: overridden_fields
  final Key key;

  const ImageUploaderBase64(
      {required this.key,
      required this.base64ImageUpload,
      required this.base64ImageRender,
      bool upload = false})
      : super(key: key);

  @override
  State<ImageUploaderBase64> createState() => _ImageUploaderBase64State();
}

class _ImageUploaderBase64State extends State<ImageUploaderBase64> {
  final imageController = ImageController.to;
  var statusUpload = "idle".obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return AnimatedPadding(
        duration: kThemeAnimationDuration,
        padding: mediaQueryData.viewInsets,
        child:
            Container(child: _buildSendImageComposer(mediaQueryData, context)));
  }

  Widget _buildSendImageComposer(
      MediaQueryData mediaQueryData, BuildContext _context) {
    Uint8List bytes = const Base64Codec().decode(widget.base64ImageRender);

    return statusUpload.value == "upload"
        ? Container()
        : Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.memory(
                        bytes,
                        width: Get.width,
                        fit: BoxFit.fitWidth,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    style: outlineButtonStyleSuccess,
                    onPressed: () {
                      setState(() {
                        statusUpload.value = "upload";
                      });
                      imageController.resetUploadResult();
                      var dataUpload = {
                        "display_name":
                            DateTime.now().toIso8601String().substring(0, 19),
                        "image_base64": widget.base64ImageUpload
                      };
                      SmartDialog.showLoading(
                          msg: "Upload Gambar...", backDismiss: false);
                      imageController
                          .uploadImageBase64(dataUpload)
                          .then((value) => {
                                SmartDialog.dismiss(),
                                if (value == true)
                                  {Navigator.pop(_context)}
                                else
                                  {
                                    GFToast.showToast(
                                        'An Image Failed to Upload Error Occurred!',
                                        _context,
                                        trailing: const Icon(
                                          Icons.error_outline,
                                          color: GFColors.WARNING,
                                        ),
                                        toastBorderRadius: 5.0),
                                  }
                              });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          CupertinoIcons.paperplane,
                          size: 18,
                          color: CupertinoColors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Image Upload',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
