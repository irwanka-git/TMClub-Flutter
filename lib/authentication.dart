import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/widget/form_akun.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    // TODO: Add auto login logic
    return firebaseApp;
  }

  static Future<User?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //print(user);
      return user;
    }
    return null;
  }

  static Future<bool> cekIsAlreadyExistUserFirebase(String? email) async {
    bool existUser = false;
    if (email != "") {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          existUser = true;
        }
      });
    }
    return existUser;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    final AuthController auc = AuthController.to;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
        bool existUser = await cekIsAlreadyExistUserFirebase(user?.email);
        if (!existUser) {
          print("BELUM TERDAFTAR DI FIREBASE YA");
          bool konfirmRegistrasi = false;
          auc.setKonfirmRegistrasiAkun(false);
          await Get.dialog(
            FormAkunField(
              userTemp: user!,
              key: UniqueKey(),
              height: Get.height,
              width: Get.width,
            ),
            barrierDismissible: false,
          );
          if (auc.konfirmRegistrasiAkun.value == false) {
            print("BATAL REGISTRASI");
            await FirebaseAuth.instance.signOut();
            googleSignIn.signOut();
            return null;
          }
          return user;
        } else {
          //print("USER SUDAH ADA DI FIREBASE YA");
          return user;
        }
        // user
        //     ?.getIdTokenResult(false)
        //     .then((value) => print("Token: ${value.token}"));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'The account already exists with a different credential',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.',
          ),
        );
      }
    }
    return user;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await FirebaseAuth.instance.signOut();
      googleSignIn.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}
