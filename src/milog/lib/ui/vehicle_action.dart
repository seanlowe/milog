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
        child: Column(
          children: <Widget>[
            TextField(
              // name field
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              )
            )
          ],
        )
      )
    );
  }

} // end of class _VehicleActionState