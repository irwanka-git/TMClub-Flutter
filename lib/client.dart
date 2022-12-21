// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiClient {
  var token = "";
  var base_url = 'http://137.184.58.131:8000';
  var base_url_api = 'http://137.184.58.131:1338';

  //var base_url = 'http://192.168.2.81/api';

  _getToken() async {
    token = '_';
    //inspect('response  ${token}');
  }

  delete(path, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 8000,
          receiveTimeout: 5000,
          headers: header,
          validateStatus: (_status) {
            if (_status! <= 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.delete(base_url + path);
      //print(response);
      if (response.statusCode == HttpStatus.ok) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.accepted) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.noContent) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.notFound) {
        return response.data;
      }
      return null;
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      print("MSG: ${ex.message}");
      return null;
    }
  }

  patch(path, data, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 8000,
          receiveTimeout: 5000,
          headers: header,
          validateStatus: (_status) {
            if (_status! <= 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    print(base_url + path);
    //final response = await dio.patch(base_url + path, data: data);
    //print("RESPONSE: ${response}");

    try {
      final response = await dio.patch(base_url + path, data: data);
      //print("RESPONSE: ${response}");
      if (response.statusCode == HttpStatus.ok) {
        //print(response.data);
        return response.data;
      }
      if (response.statusCode == HttpStatus.created) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.accepted) {
        return response.data;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      print(ex);
      return null;
    }
  }

  requestPost(path, data, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 3000,
          receiveTimeout: 5000,
          headers: header,
          validateStatus: (_status) {
            if (_status! <= 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.post(base_url + path, data: data);
      //print(response.realUri);
      print(response);
      if (response.statusCode == HttpStatus.created) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.ok) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.unprocessableEntity) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.noContent) {
        var data = {'status_code': 204};
        return data;
      }
      if (response.statusCode == HttpStatus.badRequest) {
        var data = {'status_code': 400};
        return data;
      }
      if (response.statusCode == HttpStatus.notFound) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.internalServerError) {
        var data = {'status_code': 500};
        return data;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      print(DioErrorType.response);
      return null;
    }
  }

  requestPostBlob(path, data, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 3000,
          receiveTimeout: 5000,
          headers: header,
           responseType: ResponseType.bytes,
          validateStatus: (_status) {
            if (_status! <= 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.post(base_url + path, data: data);

      if (response.statusCode == HttpStatus.created) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.ok) {
        var resp = {
         "header": response.headers,
         "content": response.data,
        };
        return resp;
      }
      if (response.statusCode == HttpStatus.unprocessableEntity) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.noContent) {
        var data = {'status_code': 204};
        return data;
      }
      if (response.statusCode == HttpStatus.badRequest) {
        var data = {'status_code': 400};
        return data;
      }
      if (response.statusCode == HttpStatus.notFound) {
        return response.data;
      }
      if (response.statusCode == HttpStatus.internalServerError) {
        var data = {'status_code': 500};
        return data;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      print(DioErrorType.response);
      return null;
    }
  }

  requestGet(path, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 8000,
          receiveTimeout: 5000,
          headers: header,
          validateStatus: (_status) {
            if (_status! < 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.get(base_url + path);
      //print(response);
      if (response.statusCode == HttpStatus.ok) {
        //print(response.data);
        //print("200");
        // print(response.data);
        return response.data;
      }
      if (response.statusCode == HttpStatus.created) {
        //print(response.data);
        return response.data;
      }
      if (response.statusCode == HttpStatus.unprocessableEntity) {
        return response.data;
      } else {
        return null;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      print(ex.error);
      return null;
    }
  }

  requestGetImage(path, header) async {
    final Dio dio = Dio(
      BaseOptions(
          baseUrl: base_url,
          connectTimeout: 8000,
          receiveTimeout: 15000,
          headers: header,
          responseType: ResponseType.bytes,
          validateStatus: (_status) {
            if (_status! < 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.get(base_url + path);
      if (response.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
      }
      //print(ex.error);
      return null;
    }
  }

  requestGetXURL(url, header) async {
    final Dio dio = Dio(
      BaseOptions(
          connectTimeout: 8000,
          receiveTimeout: 5000,
          headers: header,
          validateStatus: (_status) {
            if (_status! < 500) {
              return true;
            }
            return false;
          }
          // headers: {
          //   HttpHeaders.acceptHeader: "accept: application/json",
          //   HttpHeaders.authorizationHeader: 'Bearer ${token}'
          // }
          ),
    );
    //print(base_url + path);
    try {
      final response = await dio.get(url);
      print("GET ${url}");
      print("RESP: ${response}");
      if (response.statusCode == HttpStatus.ok) {
        //print(response.data);
        return response.data;
      }
      if (response.statusCode == HttpStatus.created) {
        //print(response.data);
        return response.data;
      }
      if (response.statusCode == HttpStatus.unprocessableEntity) {
        return response.data;
      } else {
        return null;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        Get.snackbar(
          'Connection Timeout!',
          "Periksa Koneksi Internet Anda",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 0,
          margin: const EdgeInsets.all(0),
        );
        return "TIMEOUT";
      }
      print(ex.error);
      return "ERROR";
    }
  }
}
