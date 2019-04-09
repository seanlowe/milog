import 'package:flutter/material.dart';
import 'package:milog/ui/root_page.dart';
import 'package:milog/services/authentication.dart';
import 'package:camera/camera.dart';
import 'dart:async';

List<CameraDescription> cameras;

Future<void> main() async {
  void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(new MyApp());
}

/*
void main() {
  runApp(new MyApp());
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        //This is the name of the application 
        title: 'MiLog',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
