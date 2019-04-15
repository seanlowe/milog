/*
This widget updates vehicles. It's called using a navigator.
  fields for updating vehicles: 
    - name
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleAction extends StatefulWidget {
  final String userID;
  final Vehicle vehicle;

  VehicleAction(this.userID, this.vehicle);

  @override
  State<StatefulWidget> createState() => new _VehicleActionState();
}

class _VehicleActionState extends State<VehicleAction> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */ 
  // ----------------------------------------

  TextEditingController _nameController;

  var vehicleDatabase;
  var vehicleReference;

  String title = "Update Vehicle";

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
            TextField(
              // name field
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              )
            ),
            _showUpdateNameButton(),
          ],
        )
      )
    );
  }

   Widget _showUpdateNameButton() {
    print("User Pressed Toll Charge Button!");
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60.0)),
            color: Colors.blue,
            child: Text('Update Vehicle',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              //widget.vehicle.setName = _nameController.text.toString();
              vehicleReference.child(widget.vehicle.vehicleID).child("name").set(_nameController.text.toString());
              Navigator.pop(context);
            },
          ),
        ));
  }

} // end of class _VehicleActionState