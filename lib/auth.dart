import 'dart:ffi';

import 'package:authenticationfile/automode.dart';
import 'package:authenticationfile/providermodel/ModelData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Auth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Auth();
  }
}

class _Auth extends State<Auth> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _obscureText = true;
  final Map<String, dynamic> _frompage = {
    'useremail': null,
    'password': null,
    'acceptTerms': true,
  };
  AutoMode _autoMode = AutoMode.LogIn;
  TextEditingController controllervalue = TextEditingController();
  _builtTextfile() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          focusColor: Colors.black,
          labelText: "Email Address",
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (value) {
        setState(() {
          _frompage['useremail'] = value;
        });
      },
    );
  }

  _builtPasswordFile() {
    return TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          suffix: GestureDetector(
            child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          labelText: "Password",
          filled: true,
          fillColor: Colors.white),
      controller: controllervalue,
      validator: (value) {
        if (value.isEmpty || value.length < 7) {
          return "Please enter a valid password";
        }
      },
      onSaved: (value) {
        setState(() {
          _frompage['password'] = value;
        });
      },
    );
  }

  _builtConfrimpasswordField() {
    return TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        labelText: " Confrim Password",
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (controllervalue.text != value) {
          return "donot match password";
        }
      },
      onSaved: (value) {
        setState(() {
          _frompage['password'] = value;
        });
      },
    );
  }

  void _submitfrom(Function authentication) async {
    if (!_formkey.currentState.validate()) {
      return;
    }
    _formkey.currentState.save();
    final Map<String, dynamic> successfulinformation = await authentication(
        _frompage['useremail'], _frompage['password'], _autoMode);

    if (successfulinformation['success']) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occourd'),
            content: Text(successfulinformation['message']),
            actions: [
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double doublewidth = MediaQuery.of(context).size.width;
    double targetwidth = doublewidth > 550 ? 500.0 : doublewidth * .95;

    return Scaffold(
        appBar: AppBar(
          title: Text("${_autoMode == AutoMode.LogIn ? 'SingIn' : 'SingUp'}"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.4), BlendMode.dstATop),
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover),
          ),
          padding: EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: targetwidth,
                child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        _builtTextfile(),
                        SizedBox(
                          height: 10,
                        ),
                        _builtPasswordFile(),
                        SizedBox(
                          height: 10,
                        ),
                        _autoMode == AutoMode.SingUp
                            ? _builtConfrimpasswordField()
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        FlatButton(
                          child: Text(
                              'Switch in ${_autoMode == AutoMode.LogIn ? 'Singup' : 'Login'}'),
                          onPressed: () {
                            setState(() {
                              _autoMode = _autoMode == AutoMode.LogIn
                                  ? AutoMode.SingUp
                                  : AutoMode.LogIn;
                            });
                          },
                        ),
                        Consumer<ModelData>(
                          builder: (context, model, child) {
                            return RaisedButton(
                              onPressed: () {
                                _submitfrom(model.authentication);
                              },
                              child: Text(
                                  '${_autoMode == AutoMode.LogIn ? 'Login' : 'SignUp'}'),
                            );
                          },
                        )
                      ],
                    )),
              ),
            ),
          ),
        ));
  }
}
