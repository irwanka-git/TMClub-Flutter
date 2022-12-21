import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/model/media.dart';
import 'package:http/http.dart' as http;

class ImageController extends GetxController {
  static ImageController get to => Get.find<ImageController>();
  final resultDownload = "".obs;
  final onUpload = false.obs;
  final onCompelete = false.obs;
  final chatID = "".obs;
  final uploadResult = ImageMedia(pk: 0, display_name: "", image: "").obs;
  final newAlbum = <ImageMedia>[].obs;
  final uploadDataBase64 =
      Base64UploadMedia(display_name: "", image_base64: "").obs;

  setUploadResult(ImageMedia im) {
    uploadResult(im);
  }

  resetUploadResult() {
    uploadResult(ImageMedia(pk: 0, display_name: "", image: ""));
  }

  ImageMedia getUploadResult() {
    return uploadResult.value;
  }

  clearNewAlbum() {
    if (newAlbum.length > 0) newAlbum.clear();
  }

  removeItemNewAlbumOnIndex(int index) {
    newAlbum.removeAt(index);
  }

  addItemNewAlbum(ImageMedia item) {
    newAlbum.add(item);
  }

  setchatID(String val) {
    chatID(val);
  }

  Future<String> uploadToFirebaseStorage(String path) async {
    //final byteData = await rootBundle.load(img);
    print("UPLOAD FIREBASE.....");
    onUpload(true);
    resultDownload("");
    onCompelete(false);
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    var file = File(path);
    var filename = basename(path);
    Reference ref =
        FirebaseStorage.instance.ref("upload_image_chat").child(filename);
    try {
      await ref.putFile(file);
      //print(await ref.getDownloadURL());
      onUpload(false);
      onCompelete(true);
      String _result = await ref.getDownloadURL();
      resultDownload(_result);
      return _result;
    } on FirebaseException {
      // ...
      onUpload(false);
      onCompelete(true);
      resultDownload("error");
      return "error";
    }
  }

  Future<bool> uploadImageBase64(Map<String, dynamic> dataUpload) async {
    var response =
        await ApiClient().requestPost('/common/upload-file/', dataUpload, null);
    //print(response['status_code']);
    print(dataUpload);
    if (response['status_code'] == 201) {
      var data = response['data'];
      ImageMedia resultMedia = ImageMedia(
          pk: data['pk'],
          display_name: data['display_name'],
          image: ApiClient().base_url + data['image']);
      setUploadResult(resultMedia);
      return true;
    }
    return false;
  }

  Future<String> getBase64ImageUrl(url) async {
    http.Response response = await http.get(Uri.parse(url));
    var _base64 = base64Encode(response.bodyBytes);
    return _base64;
  }
}

class Base64UploadMedia {
  var display_name = "";
  var image_base64 = "";
  Base64UploadMedia({required this.display_name, required this.image_base64});
}
