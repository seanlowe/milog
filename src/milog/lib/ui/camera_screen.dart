import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:milog/ui/log_screen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:milog/main.dart';

enum Detector { text }

class CameraScreen extends StatefulWidget {
  Integer bestGuess;

  CameraScreen(this.bestGuess);
  @override
  _CameraScreenState createState() {
    return _CameraScreenState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  String _imagePath; //Path of the image that was taken
  File _imageFile; //Image file from the imagePath
  Size _imageSize; //The size of the image
  VisionText _scanResults; //Results from scan
  Detector _currentDetector = Detector.text; //Enum

  List<String> listOfResults;
  bool working = false;

  //Recognized text/numbers in an image
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    listOfResults = [];

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> _getAndScanImage() async{
    print("_getAndScanImage invoked");
    setState(() {});

    //Reference to a file
     File imageFile = new File(_imagePath);

    if (imageFile != null) {
      await _getImageSize(imageFile);
      await _scanImage(imageFile);
    }
    
    setState(() {
      _imageFile = imageFile;
      findBestOdometerCandidate();
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    print("_getImageSize invoked");
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }


  //Generates a FirebaseVisionImage from image
  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    print("_scanImage is invoked");

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    
    print("visionImage right after getting it .fromFile is" + visionImage.toString());


    dynamic results;
    switch (_currentDetector) {
      case Detector.text:
        final TextRecognizer recognizer =
            FirebaseVision.instance.textRecognizer();
        results = await recognizer.processImage(visionImage);
        print("results in _scanImage = " + results.toString());
        break;
      default:
        return;
    }

    setState(() {
      _scanResults = results;
    });
  }

  void findBestOdometerCandidate() {
    //Recognized text/numbers in an image
    final VisionText visionText = _scanResults;
    print("in findBestOdometerCandidate, _scanResults = " + _scanResults.toString());

    String strDect = "";
    print("Finding text/numbers in image...");
    if (visionText != null) {
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            strDect = element.text.toString();    
            listOfResults.add(strDect);
          }
        }
      }
    }else{
      print("visionTest is NULL!");
    }

    
    print("before bestGuess: " + widget.bestGuess.value.toString());
    widget.bestGuess.setValue = filterResult();
    print("after bestGuess: " + widget.bestGuess.value.toString());
  
    //Go back to log screen, expect to see a dialog that pops up
    Navigator.pop(context);
  }

  int filterResult(){
    int max = 0;
    int temp = -1;
    int intCode = 0;
    List <int> phase1 = [];
    String strResult = "";
  
    for (String element in listOfResults){
      //Check to see if they are all digits
      strResult = "";
      for (int i = 0; i < element.length; i++) {
        intCode = element.codeUnitAt(i);
        if (intCode >= 48 && intCode <= 57) {
          strResult += String.fromCharCode(intCode);
        }else {
          break;
          // if(element.codeUnitAt(i) == 46 || element.codeUnitAt(i) == 58){
          //   //listOfResults.remove(element);
          //   break;
          // }        
        }
      }
      if(strResult.length > 3){
        temp = int.parse(strResult);
        if (temp > 1000){
          if (temp > max) max = temp;
          print("Max: " + max.toString());
        }
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Take a picture of your odometer'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: (!working) ? _cameraPreviewWidget() : _showCircularProgress(working),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // _cameraTogglesRowWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.red,
          onPressed: takePictureAndProcess,
        ),
      ],
    );
  }

  Widget _showCircularProgress(isWorking){
    if (isWorking) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);
  }


  void takePictureAndProcess() {
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isRecordingVideo) {
      onTakePictureButtonPressed();
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          _imagePath = filePath;
          print("in onTakePictureButtonPressed, imagePath = " +
              _imagePath.toString());
          //Gets the image file from the filePath of the image
          //_imageFile = new File(filePath);
          //print("This is the file form the filePath: " + _imageFile.toString());
        });
        if (filePath != null) {
          //showInSnackBar('Picture saved to $filePath');
          _getAndScanImage();
        } else {
          showInSnackBar("I don't have the image!");
        }
      }
    });
  }

  Future<String> takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }
   
    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

//List<CameraDescription> cameras;

/*
Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp());
}
*/
