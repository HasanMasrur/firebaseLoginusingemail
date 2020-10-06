import 'dart:convert';

import 'package:authenticationfile/automode.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModelData with ChangeNotifier {
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
  }
}
