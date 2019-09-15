import 'dart:async';
import 'package:attendance/backend/user.dart';
import 'package:attendance/loginPage/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// view-model of login page
abstract class LoginPageViewModel extends State<LoginPage> {
  /// constructor
  LoginPageViewModel() {
    _auth.currentUser().then((FirebaseUser user) {
      if (user != null) {
        handleUser(user);
      }
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount _googleAccount;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// call signIn routine
  Future<void> signInUser() async {
    _googleAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await _googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print('signInWithGoogle succeeded: $user');
  }

  /// handle signed in user
  void handleUser(FirebaseUser user) {
    if (user == null) {
      print('No User');
      Fluttertoast.showToast(
          msg: 'Failed to login',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1);
    } else {
      print('Found User');
      User()
        ..nameMe(user.displayName)
        ..assignEmail(user.email)
        ..changePicture(user.photoUrl)
        ..loadInfo()
        ..save();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
