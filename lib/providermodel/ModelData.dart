import 'dart:async';
import 'dart:convert';

import 'package:authenticationfile/automode.dart';
import 'package:authenticationfile/providermodel/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class ModelData with ChangeNotifier {
  User _authenticatedUser;

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get usersubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authentication(String email, String password,
      [AutoMode mode = AutoMode.LogIn]) async {
    final Map<String, dynamic> authdata = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    http.Response response;

    if (mode == AutoMode.LogIn) {
      response = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBGsnIVcdxRMPsojOiVCnERwt8jAZcSKsU',
          body: json.encode(authdata),
          headers: {'Content_type': 'application/json'});
    } else if (mode == AutoMode.SingUp) {
      response = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBGsnIVcdxRMPsojOiVCnERwt8jAZcSKsU',
          body: json.encode(authdata));
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something is Wrong';
    print('...........');
    print(responseData);
    _authenticatedUser = User(
        email: email,
        id: responseData['localId'],
        token: responseData['idToken']);

    setAuthTimeOut(int.parse(responseData['expiresIn']));

    final DateTime now = DateTime.now();
    final DateTime expiryTime =
        now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('token', responseData['idToken']);
    preferences.setString('userEmail', email);
    preferences.setString('userId', responseData['localId']);
    preferences.setString('expiryTime', expiryTime.toIso8601String());
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Login successfuly';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String token = preferences.getString('token');
    final String expiryTimeString = preferences.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = preferences.getString('userEmail');
      final String userId = preferences.getString('userId');
      final int tokenlifespan = parsedExpiryTime.difference(now).inSeconds;

      _authenticatedUser = User(email: userEmail, id: userId, token: token);
      _userSubject.add(true);
      setAuthTimeOut(tokenlifespan);
      notifyListeners();
    }
  }

  logout() async {
    _authenticatedUser = null;
    // _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  Timer _authTimer;

  setAuthTimeOut(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}
