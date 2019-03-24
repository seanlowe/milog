/*
This widget adds or updates logs. It's called using a navigator.
Since the same widget is used for updating and adding, a bool is
passed in to determine if we are adding or updating
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';

class LogScreen extends StatefulWidget {
  final Trip trip;
  final String userId;

  //Are we updating a trip?
  final bool update;
  LogScreen(this.userId, this.trip, this.update);

  @override
  State<StatefulWidget> createState() => new _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  //Every textbox needs a "controller"
  TextEditingController _vehicleController;
  TextEditingController _notesController;
  TextEditingController _odometerReading;

  var tripDatabase;
  var tripsReference;

  //String set titles for LogScreen (this class)
  String strUpdateTitle = "Update Trip";
  String strNewTripTitle = "New Trip";
  String title;

  //When the "Activity Starts"
  @override
  void initState() {
    super.initState();

    tripDatabase = FirebaseDatabase.instance.reference();
    tripsReference = tripDatabase.child('Trips');

    //Sets the appropriate title
    title = widget.update ? strUpdateTitle : strNewTripTitle;

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    /*Create instances of the controller => A controller for an editable text field.
    Remember to convert things to Strings if they are going into textboxes!
    This happens at start... what's written in the TextBoxes */
    _notesController = new TextEditingController(text: widget.trip.notes);
    _vehicleController = new TextEditingController(text: widget.trip.vehicle);
    _odometerReading =
        new TextEditingController(text: widget.trip.startOdometer.toString());
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(35.0)),
            color: Colors.green,
            child: (widget.update)
                ? Text('Update Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : Text('Add Trip',
                    style: new TextStyle(fontSize: 25.0, color: Colors.white)),
            onPressed: () {
              //We are updaing trip
              if (widget.trip.tripID != null) {
                tripsReference.child(widget.trip.tripID).set({
                  'notes': _notesController.text,
                  'vehicle': _vehicleController.text,
                  'startOdometer': _odometerReading.text,
                  'userID': widget.userId,
                }).then((_) {
                  Navigator.pop(context);
                });
                //We are creating a new trip
              } else {
                //TODO: use push class/object instead
                tripsReference.push().set({
                  'notes': _notesController.text,
                  'vehicle': _vehicleController.text,
                  'startOdometer': int.parse(_odometerReading.text),
                  'startTime': ServerValue.timestamp,
                  'endOdometer': 0,
                  'milesTraveled': 0,
                  'userID': widget.userId,
                  'inProgress': true,
                  'paused': false
                }).then((_) {
                  Navigator.pop(context);
                });
              }
            },
          ),
        ));
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
            //The Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            //Padding(padding: new EdgeInsets.all(5.0)),
            //The Vehicle Text Field
            TextField(
              controller: _vehicleController,
              decoration: InputDecoration(labelText: 'Vehicle'),
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            //Padding(padding: new EdgeInsets.all(5.0)),
            //The Odometer Text Field
            TextField(
              controller: _odometerReading,
              decoration: InputDecoration(labelText: "Odometer Reading"),
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
              keyboardType: TextInputType.number,
            ),
            //Padding(padding: new EdgeInsets.all(5.0)),
            _showPrimaryButton()
          ],
        ),
      ),
    );
  }
}
