import 'package:authenticationfile/auth.dart';
import 'package:authenticationfile/providermodel/ModelData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModelData(),
      child: MaterialApp(
        home: Auth(),
      ),
    );
  }
}
