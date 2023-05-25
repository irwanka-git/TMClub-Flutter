// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/AboutController.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/model/resources.dart';
import 'package:tmcapp/preview-image.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:tmcapp/widget/upload_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/BlogController.dart';

class AboutEditScreen extends StatefulWidget {
  @override
  State<AboutEditScreen> createState() => _AboutEditScreenState();
}

class _AboutEditScreenState extends State<AboutEditScreen> {
  final blogController = Get.put(BlogController());
  TextEditingController titleController = TextEditingController();
  TextEditingController annualDirectoryController = TextEditingController();
  //var contentController;l
  final HtmlEditorController contentController = HtmlEditorController();

  final aboutController = AboutController.to;
  // final imageController = ImageController.to;
  final FocusScopeNode _nodeFocus = FocusScopeNode();
  final isLoading = true.obs;
  final listImage = <ImageMedia>[].obs;
  final listAnnual = <Resources>[].obs;

  @override
  void dispose() {
    _nodeFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    titleController.text = "";
    // imageController.resetUploadResult();
    // imageController.clearNewAlbum();
    // aboutController.clearItemAnnualDirectories();

    super.initState();
    setState(() {
      isLoading.value = true;
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //contentController = HtmlEditorController();
      //contentController.setText("");
      SmartDialog.showLoading(msg: "Loading..");
      await aboutController.getListAbout().then((value) {
        titleController.text = aboutController.currentAbout.value.md!;
        // contentController
        //     .setText(aboutController.currentAbout.value.description!);

        for (var item in aboutController.currentAbout.value.organizations!) {
          //annualDirectoryController
          listImage.add(ImageMedia(
              pk: 0,
              display_name: item['display_name'],
              image: item['image_url']));
        }

        for (var item
            in aboutController.currentAbout.value.annualDirectories!) {
          //annualDirectoryController
          //print(item);
          listAnnual.add(Resources(
              pk: 0, displayName: item['display_name'], url: item['url']));
        }

        SmartDialog.dismiss();
        isLoading.value = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = AppController.to.appBarColor.value;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit About TMClub",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: appBarColor,
          elevation: 1,
        ),
        backgroundColor: GFColors.WHITE,
        body: Obx(() => Padding(
            padding: const EdgeInsets.all(20),
            child: isLoading.value == false ? buildBody() : Container())));
  }

  Widget buildBody() {
    final formKey = GlobalKey<FormState>();
    var context = Get.context!;
    return SingleChildScrollView(
        child: Form(
      key: formKey,
      child: Column(
        children: [
          //title
          const Text("Silahkan Isi Form berikut!"),
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  labelText: "Title",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: OutlineInputBorder()),
              autocorrect: false,
              validator: (_val) {
                if (_val == "") {
                  return 'Required!';
                }
                return null;
              }),
          //summary
          const SizedBox(
            height: 15,
          ),
          HtmlEditor(
            callbacks: Callbacks(onInit: () {
              print("complte");
              contentController
                  .setText(aboutController.currentAbout.value.description!);
            }),
            controller: contentController, //required
            htmlToolbarOptions: const HtmlToolbarOptions(
                toolbarPosition: ToolbarPosition.belowEditor,
                defaultToolbarButtons: [
                  FontButtons(),
                  ParagraphButtons(
                      alignCenter: true,
                      alignLeft: true,
                      increaseIndent: false,
                      decreaseIndent: false,
                      lineHeight: false,
                      textDirection: false,
                      caseConverter: false),
                  ListButtons(listStyles: false),
                  InsertButtons(
                      picture: false, audio: false, video: false, hr: true),
                ]),
            htmlEditorOptions: HtmlEditorOptions(
              shouldEnsureVisible: false,
              hint: "Type Here..",
              //initalText: "text content initial, if any",
            ),
            otherOptions: OtherOptions(
              height: 400,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text("Annual  Directory:"),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: listAnnual.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GFListTile(
                          title: Text(listAnnual[index].displayName!,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subTitleText: "${listAnnual[index].url}",
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          margin: EdgeInsets.all(0),
                          avatar: Icon(
                            Icons.link_outlined,
                            size: 20,
                          ),
                          onLongPress: () {
                            Get.defaultDialog(
                                contentPadding: const EdgeInsets.all(20),
                                title: "Confirmation",
                                titlePadding:
                                    const EdgeInsets.only(top: 10, bottom: 0),
                                middleText:
                                    "Are you sure you want to delete the annual directories?",
                                backgroundColor:
                                    CupertinoColors.darkBackgroundGray,
                                titleStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                middleTextStyle: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                textCancel: "Cancel",
                                textConfirm: "Yes, Sure",
                                cancelTextColor: Colors.white,
                                confirmTextColor: Colors.white,
                                buttonColor: CupertinoColors.activeOrange,
                                onConfirm: () {
                                  // ignore: list_remove_unrelated_type
                                  listAnnual.removeAt(index);
                                  Navigator.pop(context);
                                },
                                radius: 0);
                          },
                        );
                      }),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: GFButton(
                    onPressed: () {
                      showModalAnnualDirectory();
                    },
                    color: GFColors.PRIMARY,
                    blockButton: true,
                    type: GFButtonType.outline,
                    icon: const Icon(
                      Icons.add_link_outlined,
                      size: 18,
                      color: GFColors.PRIMARY,
                    ),
                    text: "Add Annual Directory",
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text("Organizational structure:"),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                        width: 1, color: CupertinoColors.systemGrey4),
                    shape: BoxShape.rectangle,
                  ),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      aspectRatio: 2,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                    ),
                    items: listImage
                        .map((item) => Container(
                              child: InkWell(
                                highlightColor:
                                    CupertinoColors.darkBackgroundGray,
                                onLongPress: () {
                                  Get.defaultDialog(
                                      contentPadding: const EdgeInsets.all(20),
                                      title: "Confirmation",
                                      titlePadding: const EdgeInsets.only(
                                          top: 10, bottom: 0),
                                      middleText:
                                          "Are you sure you want to delete the image?",
                                      backgroundColor:
                                          CupertinoColors.darkBackgroundGray,
                                      titleStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      middleTextStyle: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                      textCancel: "Cancel",
                                      textConfirm: "Yes, Sure",
                                      cancelTextColor: Colors.white,
                                      confirmTextColor: Colors.white,
                                      buttonColor: CupertinoColors.activeOrange,
                                      onConfirm: () {
                                        int index = listAnnual.indexOf(item);
                                        listAnnual.remove(index);
                                        Navigator.pop(context);
                                      },
                                      radius: 0);
                                },
                                onTap: () {
                                  showMaterialModalBottomSheet<String>(
                                    expand: false,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) =>
                                        PreviewImageScreen(item.image),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(3.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Image.network(
                                          item.image,
                                          fit: BoxFit.cover,
                                          width: 1000,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress != null) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    color: GFColors.LIGHT),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor:
                                                        GFColors.LIGHT,
                                                    color: CupertinoColors
                                                        .inactiveGray,
                                                  ),
                                                ),
                                              );
                                            }
                                            return child;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Center(
                  child: GFButton(
                    onPressed: () {
                      showModalGambar();
                    },
                    color: GFColors.PRIMARY,
                    blockButton: true,
                    type: GFButtonType.outline,
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 18,
                      color: GFColors.PRIMARY,
                    ),
                    text: "Add Image",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: CupertinoColors.separator,
                ),
                GFButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      GFToast.showToast('Opps, Incomplete Form!', Get.context!,
                          trailing: const Icon(
                            Icons.error_outline,
                            color: GFColors.WARNING,
                          ),
                          toastPosition: GFToastPosition.BOTTOM,
                          toastBorderRadius: 5.0);
                      return;
                    }
                    var title = titleController.text;
                    var description = "";
                    await contentController.getText().then((value) {
                      description = value;
                    });
                    //  print(title);
                    //  print(description);
                    var organizations = [];
                    for (var item in listImage) {
                      var temp = {
                        'display_name': item.display_name,
                        'description': 'empty',
                        'image_url': item.image
                      };
                      organizations.add(temp);
                    }
                    print(organizations);

                    var annualdirectories = [];
                    for (var item in listAnnual) {
                      var temp = {
                        'display_name': item.displayName,
                        'description': 'empty',
                        'url': item.url
                      };
                      annualdirectories.add(temp);
                    }
                    print(annualdirectories);

                    var data = {
                      'md': title,
                      'organizations': organizations,
                      'annual_directories': annualdirectories,
                      'description': description,
                    };
                    SmartDialog.showLoading(msg: "Update About...");
                    var update = false;
                    await aboutController.updateAbout(data).then((value) {
                      update = value;
                    });

                    if (update == true) {
                      GFToast.showToast('Save data successfully!', Get.context!,
                          trailing: const Icon(
                            Icons.check_circle,
                            color: GFColors.SUCCESS,
                          ),
                          toastPosition: GFToastPosition.BOTTOM,
                          toastBorderRadius: 5.0);
                      await aboutController.getListAbout();
                      Get.offNamed('/about');
                    } else {
                      GFToast.showToast('Opps, Save data failed!', Get.context!,
                          trailing: const Icon(
                            Icons.error_outline,
                            color: GFColors.WARNING,
                          ),
                          toastPosition: GFToastPosition.BOTTOM,
                          toastBorderRadius: 5.0);
                    }
                    SmartDialog.dismiss();
                  },
                  text: "Save About",
                  color: CupertinoColors.activeGreen,
                  blockButton: true,
                  icon: const Icon(
                    CupertinoIcons.paperplane,
                    color: GFColors.WHITE,
                    size: 18,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  void showModalGambar() {
    final _textDisplayNameController = TextEditingController();
    final _textURLController = TextEditingController();
    final formKeyGambar = GlobalKey<FormState>();
    _textDisplayNameController.text = "";
    _textURLController.text = "";

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: Get.context!,
        isScrollControlled: true,
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 30),
              child: Container(
                child: Form(
                  key: formKeyGambar,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.0),
                      Text("Add Organizational Structure Image"),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _textURLController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.link),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Url / Link Image",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            bool _validURL = Uri.parse(_val!).isAbsolute;
                            if (_validURL == false) {
                              return 'URL / Link Invalid!';
                            }
                            return null;
                          }),
                      SizedBox(height: 30.0),
                      GFButton(
                        onPressed: () async {
                          if (!formKeyGambar.currentState!.validate()) {
                            GFToast.showToast(
                                'Opps, Image Link Incomplete!', Get.context!,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          Navigator.pop(Get.context!);
                          var item = ImageMedia(
                              pk: 0,
                              display_name:
                                  "image_organization${DateTime.now().millisecondsSinceEpoch}",
                              image: _textURLController.text);
                          listImage.add(item);
                        },
                        blockButton: true,
                        icon: Icon(
                          Icons.save,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Save Image",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
  }

  void showModalAnnualDirectory() {
    final _textDisplayNameController = TextEditingController();
    final _textURLController = TextEditingController();
    final formKeyAnnual = GlobalKey<FormState>();
    _textDisplayNameController.text = "";
    _textURLController.text = "";

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: Get.context!,
        isScrollControlled: true,
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 30),
              child: Container(
                child: Form(
                  key: formKeyAnnual,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.0),
                      Text("Add Annual Directories Link"),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _textDisplayNameController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.doc),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Directory Name",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            return null;
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _textURLController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.link),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Url / Link",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            bool _validURL = Uri.parse(_val!).isAbsolute;
                            if (_validURL == false) {
                              return 'URL / Link Invalid!';
                            }
                            return null;
                          }),
                      SizedBox(height: 20.0),
                      GFButton(
                        onPressed: () async {
                          if (!formKeyAnnual.currentState!.validate()) {
                            GFToast.showToast(
                                'Opps, Form Incomplete!', Get.context!,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          Navigator.pop(Get.context!);
                          var item = Resources(
                              pk: 0,
                              displayName: _textDisplayNameController.text,
                              url: _textURLController.text);
                          listAnnual.add(item);
                        },
                        blockButton: true,
                        icon: Icon(
                          Icons.save,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Save Directories",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
  }
}
