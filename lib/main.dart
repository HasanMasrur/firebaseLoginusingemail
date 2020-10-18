import 'package:authenticationfile/auth.dart';
import 'package:authenticationfile/homepage.dart';
import 'package:authenticationfile/providermodel/ModelData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ModelData modelData = ModelData();
  bool _isAuthenticated = false;
  @override
  void initState() {
    modelData.autoAuthenticate();
    modelData.usersubject.listen((value) {
      setState(() {
        _isAuthenticated = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModelData(),
      child: MaterialApp(
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? Auth() : Homepage(),
        },
      ),
    );
  }
}
