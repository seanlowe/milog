/* 
This widget adds or updates vehicles. It's called using a navigator.
Since the same widget is used for updating and adding, a bool is
passed in to determine if we are adding or updating.
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final String userID;

  // are we updating a vehicle?
  final bool update;
  VehicleScreen(this.userID, this.vehicle, this.update);

  @override
  State<StatefulWidget> createState() => new _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  // every textbox needs a "controller"
  TextEditingController _nameController;
  TextEditingController _vehicleController;

  var vehicleDatabase;
  var vehicleReference;

  // various title Strings for VehicleScreen
  String strUpdateTitle = "Update Vehicle";
  String strNewVehicleTitle = "New Vehicle";
  String title;

  @override
  void initState() {
    super.initState();

    vehicleDatabase = FirebaseDatabase.instance.reference();
    vehicleReference = vehicleDatabase.child('Vehicles');

    title = widget.update ? strUpdateTitle : strNewVehicleTitle;

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
  
}