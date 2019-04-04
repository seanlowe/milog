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
  // every textbox needs a "controller"
  TextEditingController _nameController;
  TextEditingController _lastKnownOdoController;

  var vehicleDatabase;
  var vehicleReference;

  String title = "New Vehicle";

  @override
  void initState() {
    super.initState();

    vehicleDatabase = FirebaseDatabase.instance.reference();
    vehicleReference = vehicleDatabase.child('Vehicles');

    FirebaseDatabase.instance.setPersistenceEnabled(true);

    _nameController = new TextEditingController(text: widget.vehicle.name);
    _lastKnownOdoController = new TextEditingController(text: widget.vehicle.lastKnownOdometer.toString());
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
            ),
              TextField(
              // odometer field
              controller: _lastKnownOdoController,
              decoration: InputDecoration(labelText: 'Current Odometer Reading'),
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              ),
              keyboardType: TextInputType.number,
              )
          ],
        )
      )
    );
  }
  
} // end of class _VehicleScreenState