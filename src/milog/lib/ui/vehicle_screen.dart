/* 
This widget adds vehicles. It's called using a navigator.
  fields for new vehicles:
    - name
    - current odometer reading
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:milog/model/Integer.dart';
import 'package:milog/ui/camera_screen.dart';
import 'package:flutter/services.dart';

class VehicleScreen extends StatefulWidget {
  final String userID;
  final Vehicle vehicle;
  Integer odometerFromPicture;

  VehicleScreen(this.userID, this.vehicle);

  @override
  State<StatefulWidget> createState() => new _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */
  // ----------------------------------------
  // every textbox needs a "controller"
  TextEditingController _nameController;
  MaskedTextController _lastKnownOdoController;

  var vehicleDatabase;
  var vehicleReference;

  String title = "New Vehicle";

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override
  void initState() {
    super.initState();
    widget.odometerFromPicture = Integer(0);

    vehicleDatabase = FirebaseDatabase.instance.reference();
    vehicleReference = vehicleDatabase.child('Vehicles');

    FirebaseDatabase.instance.setPersistenceEnabled(true);

    _nameController = new TextEditingController(text: widget.vehicle.name);
    _lastKnownOdoController = new MaskedTextController(mask: '000000');
    _lastKnownOdoController.updateText("0");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Container(
            margin: EdgeInsets.all(15.0),
            alignment: Alignment.center,
            child: ListView(
              children: <Widget>[
                _showNameTextBox(),
               _showOdoAndCamera(),
                _showAddVehicleButton(),
              ],
            )));
  }

  // ----------------------------------------
  /*              INPUT FIELDS             */
  // ----------------------------------------

  Widget _showNameTextBox() {
    return TextField(
        //Limit string length to 26 characters
        inputFormatters: [
          LengthLimitingTextInputFormatter(26),
        ],
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Vehicle Name'),
        style: TextStyle(
          fontSize: 22.0,
          color: Colors.black,
        ));
  }

  Widget _showOdometerTextBox() {
    return TextField(
      // odometer field
      controller: _lastKnownOdoController,
      decoration: InputDecoration(labelText: 'Current Odometer Reading'),
      style: TextStyle(
        fontSize: 22.0,
        color: Colors.black,
      ),
      keyboardType: TextInputType.number,
    );
  }

   Widget _showOdoAndCamera() {
    return ListTile(
        title: _showOdometerTextBox(),
        trailing: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.blue),
          color: Colors.blue,
           splashColor: Colors.red,
          onPressed: () {
            //Navigate to camera
            _navigateToCamera(context);
          },
        ));
  }

  void _navigateToCamera(BuildContext contect) async {
    //print("Before Camera Screen: " + widget.odometerFromPicture.value.toString());
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraScreen(widget.odometerFromPicture)),
    );
    //print("After Camera Screen: " + widget.odometerFromPicture.value.toString());
    _showDialogCheckOdometer();
  }

  void _showDialogCheckOdometer() async {
    TextEditingController _odometerFieldDialog = TextEditingController();
    //Setting textField in this Dialog to the one from picture
    _odometerFieldDialog.text = widget.odometerFromPicture.value.toString();

    //Local helper function
    Widget _showTextField() {
      return TextField(
        controller: _odometerFieldDialog,
        keyboardType: TextInputType.number,
      );
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("We think your Odometer is:",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content: _showTextField(),
          actions: <Widget>[
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(fontSize: 18.0, color: Colors.green),
              ),
              onPressed: () {
                //Copy what's in the TextField in Dialog to TextField in LogScreen.
                if (int.parse(_odometerFieldDialog.text.toString()) > 0) {
                  if (int.parse(_odometerFieldDialog.text.toString()) >
                      int.parse(_lastKnownOdoController.text.toString())) {
                    _lastKnownOdoController.text =
                        _odometerFieldDialog.text.toString();
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showAddVehicleButton() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
            height: 40,
            child: RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0)),
              color: Colors.green,
              child: Text('Add vehicle',
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {
                vehicleReference.push().set({
                  'name': _nameController.text,
                  'lastKnownOdometer':
                      int.parse(_lastKnownOdoController.text.toString()),
                  'inUse': false,
                  'userID': widget.userID,
                }).then((_) {
                  Navigator.pop(context);
                });
              },
            )));
  }
} // end of class _VehicleScreenState
