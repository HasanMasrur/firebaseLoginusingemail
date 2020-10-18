import 'package:authenticationfile/auth.dart';
import 'package:authenticationfile/providermodel/ModelData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Homepage();
  }
}

class _Homepage extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('HomePage'),
        ),
        body: Consumer<ModelData>(builder: (context, model, child) {
          return Center(
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  model.logout();
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return Auth();
                }));
              },
              child: Text('LogOUt'),
            ),
          );
        }));
  }
}
