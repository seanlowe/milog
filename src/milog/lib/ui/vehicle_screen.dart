/* 
This widget adds vehicles. It's called using a navigator.
  fields for new vehicles:
    - name
    - current odometer reading
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleScreen extends StatefulWidget {
  final String userID;
  final Vehicle vehicle;

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
  TextEditingController _lastKnownOdoController;

  var vehicleDatabase;
  var vehicleReference;

  String title = "New Vehicle";

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override
  void initState() {
    super.initState();

    vehicleDatabase = FirebaseDatabase.instance.reference();
    vehicleReference = vehicleDatabase.child('Vehicles');

    FirebaseDatabase.instance.setPersistenceEnabled(true);

    _nameController = new TextEditingController(text: widget.vehicle.name);
    _lastKnownOdoController = new TextEditingController();
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
                _showOdometerTextBox(),
                _showAddVehicleButton(),
              ],
            )));
  }

  // ----------------------------------------
  /*              INPUT FIELDS             */
  // ----------------------------------------

  Widget _showNameTextBox() {
    return TextField(
        // name field
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Name'),
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

  Widget _showAddVehicleButton() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
            height: 40,
            child: RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0)),
              color: Colors.blue,
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
