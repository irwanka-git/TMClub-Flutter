import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/preview-image.dart';
import 'package:path/path.dart';
import 'package:tmcapp/widget/upload_image.dart';
import 'controller/AuthController.dart';
import 'controller/EventController.dart';
import 'model/media.dart';

class EventCreateScreen extends StatefulWidget {
  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final bottomTabControl = BottomTabController.to;
  final eventController = EventController.to;
  final authController = AuthController.to;
  final isLoading = true.obs;
  final base_url = ApiClient().base_url;

  TextEditingController titleController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  TextEditingController dateController =
      TextEditingController(text: DateTime.now().toString());
  TextEditingController venueController = TextEditingController();
  final imageController = Get.put(ImageController());
  final mainImageMedia = ImageMedia(pk: 0, display_name: "", image: "").obs;
  final is_free = true.obs;
  final is_registration_close = true.obs;
  final is_list_attendees = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    titleController.text = "";
    dateController.text = "";
    deskripsiController.text = "";
    venueController.text = "";
    deadlineController.text = "1";
    imageController.resetUploadResult();
    setState(() {
      is_free.value == true;
      is_registration_close.value == true;
      is_list_attendees.value == false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    Color appBarColor = AppController.to.appBarColor.value;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Create New Event"),
          backgroundColor: appBarColor,
          elevation: 1,
        ),
        backgroundColor: CupertinoColors.white,
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Form(
                    key: formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Please Fill in Event Information",
                            textAlign: TextAlign.center,
                          ),
                          const Divider(
                            color: CupertinoColors.separator,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                              controller: titleController,
                              style: const TextStyle(fontSize: 13, height: 2),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  labelText: "Title",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  border: OutlineInputBorder()),
                              autocorrect: false,
                              validator: (_val) {
                                if (_val == "") {
                                  return 'Required!';
                                }
                                return null;
                              }),
                          const SizedBox(
                            height: 15,
                          ),
                          DateTimePicker(
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 15),
                                labelText: "Date, Time",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                                border: OutlineInputBorder()),
                            type: DateTimePickerType.dateTime,
                            dateMask: 'd MMMM, yyyy hh:mm WIB',
                            controller: dateController,
                            //initialValue: _initialValue,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            //icon: Icon(Icons.event),
                            dateLabelText: 'Date, Time',
                            use24HourFormat: true,
                            locale: const Locale('id', 'ID'),
                            onChanged: (val) {
                              print(val);
                              print(DateTime.parse(val).toIso8601String());
                            },
                            validator: (val) {
                              if (val == "") {
                                return 'Required!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                              controller: venueController,
                              style: const TextStyle(fontSize: 13, height: 2),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  labelText: "Venue",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  border: OutlineInputBorder()),
                              autocorrect: false,
                              validator: (_val) {
                                if (_val == "") {
                                  return 'Required!';
                                }
                                return null;
                              }),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                              controller: deskripsiController,
                              maxLines: 10,
                              minLines: 2,
                              style: const TextStyle(fontSize: 13, height: 2),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  labelText: "Description",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  border: OutlineInputBorder()),
                              autocorrect: false,
                              validator: (_val) {
                                if (_val == "") {
                                  return 'Required!';
                                }
                                return null;
                              }),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Thumbnail:",
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Obx(() => Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  border: Border.all(
                                      width: 1,
                                      color: CupertinoColors.systemGrey4),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Stack(children: <Widget>[
                                  mainImageMedia.value.pk == 0
                                      ? Image.asset(
                                          "assets/images/image-placeholder.png",
                                          width: Get.width,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : InkWell(
                                          highlightColor: CupertinoColors
                                              .darkBackgroundGray,
                                          onLongPress: () {
                                            Get.defaultDialog(
                                                contentPadding:
                                                    const EdgeInsets.all(20),
                                                title: "Confirmation",
                                                titlePadding:
                                                    const EdgeInsets.only(
                                                        top: 10, bottom: 0),
                                                middleText:
                                                    "Are you sure you want to delete the image?",
                                                backgroundColor: CupertinoColors
                                                    .darkBackgroundGray,
                                                titleStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                middleTextStyle:
                                                    const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                textCancel: "Cancel",
                                                textConfirm: "Yes, Delete",
                                                cancelTextColor: Colors.white,
                                                confirmTextColor: Colors.white,
                                                buttonColor: CupertinoColors
                                                    .activeOrange,
                                                onConfirm: () {
                                                  mainImageMedia(ImageMedia(
                                                      pk: 0,
                                                      display_name: "",
                                                      image: ""));
                                                  Navigator.pop(context);
                                                },
                                                radius: 0);
                                          },
                                          onTap: () {
                                            showMaterialModalBottomSheet<
                                                String>(
                                              expand: false,
                                              context: context,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  PreviewImageScreen(
                                                      mainImageMedia
                                                          .value.image),
                                            );
                                          },
                                          child: Image.network(
                                            mainImageMedia.value.image,
                                            width: Get.width,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                ]),
                              )),
                          const SizedBox(
                            height: 6,
                          ),
                          GFButton(
                            onPressed: () {
                              getImage(ImageSource.gallery, "image_main");
                            },
                            color: GFColors.PRIMARY,
                            blockButton: true,
                            type: GFButtonType.outline,
                            icon: const Icon(
                              Icons.image,
                              size: 18,
                              color: GFColors.PRIMARY,
                            ),
                            text: "Upload Thumbnail",
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Obx(() => Container(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                            "This Event Opens Registration"),
                                        GFToggle(
                                          onChanged: (val) {
                                            val == true
                                                ? setState(() {
                                                    is_registration_close
                                                        .value = false;
                                                  })
                                                : setState(() {
                                                    is_registration_close
                                                        .value = true;
                                                  });
                                          },
                                          enabledTrackColor:
                                              CupertinoColors.activeOrange,
                                          value: is_registration_close.value
                                              ? false
                                              : true,
                                          type: GFToggleType.ios,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                            "This Event Has Received Attendance"),
                                        GFToggle(
                                          onChanged: (val) {
                                            val == false
                                                ? setState(() {
                                                    is_list_attendees.value =
                                                        false;
                                                  })
                                                : setState(() {
                                                    is_list_attendees.value =
                                                        true;
                                                  });
                                          },
                                          value: is_list_attendees.value
                                              ? true
                                              : false,
                                          enabledTrackColor:
                                              CupertinoColors.activeOrange,
                                          type: GFToggleType.ios,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("This Event is Paid"),
                                        GFToggle(
                                          onChanged: (val) {
                                            val == false
                                                ? setState(() {
                                                    is_free.value = true;
                                                  })
                                                : setState(() {
                                                    is_free.value = false;
                                                  });
                                          },
                                          value: is_free.value ? false : true,
                                          enabledTrackColor:
                                              CupertinoColors.activeOrange,
                                          type: GFToggleType.ios,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      child: is_free.value == false
                                          ? TextFormField(
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                  CurrencyTextInputFormatter(
                                                      locale: 'id',
                                                      symbol: 'Rp. ',
                                                      decimalDigits: 0)
                                                ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: priceController,
                                              style: const TextStyle(
                                                  fontSize: 13, height: 2),
                                              decoration: const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5,
                                                          horizontal: 15),
                                                  labelText:
                                                      "Cost (Rp.)/Participant",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14),
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                  border: OutlineInputBorder()),
                                              autocorrect: false,
                                              onChanged: (val) {
                                                // print(val);
                                                // print(priceController.text
                                                //     .replaceAll("Rp. ", "")
                                                //     .replaceAll(".", ""));
                                              },
                                              validator: (_val) {
                                                if (_val == "" &&
                                                    is_free.value == false) {
                                                  return 'Required!';
                                                }
                                                return null;
                                              })
                                          : Container(),
                                    ),

                                    //deadline payment (days)
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      child: is_free.value == false
                                          ? TextFormField(
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: deadlineController,
                                              style: const TextStyle(
                                                  fontSize: 13, height: 2),
                                              decoration: const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5,
                                                          horizontal: 15),
                                                  labelText:
                                                      "Billing Deadline Notification (days)",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14),
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                  border: OutlineInputBorder()),
                                              autocorrect: false,
                                              onChanged: (val) {
                                                // print(val);
                                                // print(priceController.text
                                                //     .replaceAll("Rp. ", "")
                                                //     .replaceAll(".", ""));
                                              },
                                              validator: (_val) {
                                                if (_val == "" &&
                                                    is_free.value == false) {
                                                  return 'Required!';
                                                }
                                                return null;
                                              })
                                          : Container(),
                                    )
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            color: CupertinoColors.separator,
                          ),
                          GFButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                GFToast.showToast(
                                    'Event Information Incomplete!', context,
                                    trailing: const Icon(
                                      Icons.error_outline,
                                      color: GFColors.WARNING,
                                    ),
                                    toastBorderRadius: 5.0);
                                return;
                              } else {
                                if (mainImageMedia.value.pk == 0) {
                                  GFToast.showToast(
                                      'Thumbnail Not Uploaded!', context,
                                      trailing: const Icon(
                                        Icons.error_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastBorderRadius: 5.0);
                                  return;
                                }

                                if (int.parse(deadlineController.text) == 0) {
                                  GFToast.showToast(
                                      'Billing Deadline Minimal 1 Day!', context,
                                      trailing: const Icon(
                                        Icons.error_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastBorderRadius: 5.0);
                                  return;
                                }

                                var eventUpload = {
                                  "title": titleController.text.trim(),
                                  "venue": venueController.text.trim(),
                                  "date": DateTime.parse(dateController.text)
                                      .toIso8601String(),
                                  "main_image": mainImageMedia.value.pk,
                                  "description":
                                      deskripsiController.text.trim(),
                                  "is_free": is_free.value,
                                  "is_registration_close":
                                      is_registration_close.value,
                                  "is_list_attendees": is_list_attendees.value,
                                  "price": is_free.value == true
                                      ? 0
                                      : priceController.text
                                          .replaceAll("Rp. ", "")
                                          .replaceAll(".", ""),
                                  "billing_deadline": is_free.value ==true ? null : int.parse(deadlineController.text)
                                };
                                print(eventUpload);
                                SmartDialog.showLoading(msg: "Create Event...");
                                eventController
                                    .postingEventBaru(eventUpload)
                                    .then((value) => {
                                          SmartDialog.dismiss(),
                                          if (value == true)
                                            {
                                              GFToast.showToast(
                                                  'Event Created Successfully',
                                                  context,
                                                  trailing: const Icon(
                                                    Icons.check_circle,
                                                    color: GFColors.SUCCESS,
                                                  ),
                                                  toastDuration: 3,
                                                  toastPosition:
                                                      GFToastPosition.BOTTOM,
                                                  toastBorderRadius: 5.0),
                                              eventController.getListMyEvent(),
                                              Navigator.pop(context),
                                            }
                                          else
                                            {
                                              GFToast.showToast(
                                                  'Failed Create Event',
                                                  context,
                                                  trailing: const Icon(
                                                    Icons.dangerous,
                                                    color: GFColors.DANGER,
                                                  ),
                                                  toastBorderRadius: 5.0),
                                            }
                                        });
                              }
                            },
                            text: "Save",
                            color: CupertinoColors.activeOrange,
                            blockButton: true,
                            icon: const Icon(
                              CupertinoIcons.paperplane,
                              color: GFColors.WHITE,
                              size: 18,
                            ),
                          ),
                        ])))));
  }

  getImage(ImageSource source, String destination) async {
    final ImagePicker _picker = ImagePicker();
    //File image = await  _picker.pickImage(source: source, );
    final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
        preferredCameraDevice: CameraDevice.rear);
    if (image != null) {
      //Navigator.pop(context);

      var _tempPath = image.path; //File(image!.path);
      print("PATH GAMBARNYA $_tempPath");
      List<int> imageBytes = File(_tempPath).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      var _extension =
          extension(_tempPath).replaceAll(".", "") == "png" ? "png" : "jpeg";
      String base64ImageRender = baseimage;
      String base64ImageUpload =
          "data:image/$_extension;base64,$base64ImageRender";
      //print(base64Image.length);
      Uint8List bytes = const Base64Codec().decode(base64ImageRender);
      imageController
          .setUploadResult(ImageMedia(pk: 0, display_name: "", image: ""));
      void _showModal() {
        Future<void> future = showMaterialModalBottomSheet(
          expand: false,
          context: this.context,
          backgroundColor: Colors.transparent,
          builder: (context) => SingleChildScrollView(
              child: Container(
            child: ImageUploaderBase64(
              key: UniqueKey(),
              base64ImageRender: base64ImageRender,
              base64ImageUpload: base64ImageUpload,
            ),
          )),
        );
        future.then((void value) => {
              if (destination == "image_main")
                {
                  if (imageController.uploadResult.value.pk > 0)
                    {
                      mainImageMedia(imageController.uploadResult.value),
                      imageController.resetUploadResult()
                    },
                },
              if (destination == "album_id")
                {
                  if (imageController.uploadResult.value.pk > 0)
                    {
                      imageController
                          .addItemNewAlbum(imageController.uploadResult.value),
                      imageController.resetUploadResult()
                    },
                }
            });
      }

      _showModal();
    }
  }
}
