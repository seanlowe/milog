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
  String strUpdateTitle = "View & Edit Trip";
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
        new TextEditingController(text: widget.trip.endOdometer.toString());
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0)),
            color: Colors.green,
            child: (widget.update)
                ? Text('Update Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : Text('Add Trip',
                    style: new TextStyle(fontSize: 25.0, color: Colors.white)),
            onPressed: () {
              if (widget.trip.tripID != null) {
                updateTrip();
              } else {
                //TODO: use push class/object instead
                tripsReference.push().set({
                  'notes': _notesController.text,
                  'vehicle': _vehicleController.text,
                  'startOdometer': int.parse(_odometerReading.text),
                  'startTime': ServerValue.timestamp,
                  'endTime': 0,
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

  void updateTrip() {
    tripsReference
        .child(widget.trip.tripID)
        .child('notes')
        .set(_notesController.text);
    tripsReference.child(widget.trip.tripID).child('vehicle').set(
          _vehicleController.text,
        );
    tripsReference
        .child(widget.trip.tripID)
        .child('endOdometer')
        .set(int.parse(_odometerReading.text));
    Navigator.pop(context);
  }

  Widget _showNotesTextBox() {
    return TextField(
        controller: _notesController,
        decoration: InputDecoration(labelText: 'Notes'),
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
        ));
  }

  //TODO: Make this a drop down box!
  Widget _showVehicleTextBox() {
    return TextField(
        controller: _vehicleController,
        decoration: InputDecoration(labelText: 'Vehicle'),
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
        ));
  }

  /*Determines whcih widget to show, if updating or viewing
  the Trip information will be displayed on top. If we are
  adding a new trip, we don't have trip info so it will
  return a text with instructions.
  */
  Widget _selectTopWidget() {
    if (widget.trip.startOdometer == 0) {
      return _showAddIns();
    } else {
      return _showSelectedTrip();
    }
  }

  //A little message when adding a trip
  Widget _showAddIns() {
    return Center(
      child: Text('Almost ready to go!',
          style: new TextStyle(fontSize: 24.0, color: Colors.black)),
    );
  }

  Widget _showOdometerTextBox() {
    return TextField(
      controller: _odometerReading,
      decoration: InputDecoration(labelText: "Odometer Reading"),
      style: TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      keyboardType: TextInputType.number,
    );
  }

  //Displays the information of the selected trip
  Widget _showSelectedTrip() {
    return Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.yellow[100],
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(children: <Widget>[
          Text("Notes: " + widget.trip.notes, textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Vehicle: " + widget.trip.vehicle, textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text(widget.trip.startOdometer.toString(), textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.topCenter,
        child: new ListView(
          //shrinkWrap makes it scrollable
          shrinkWrap: true,
          children: <Widget>[
            _selectTopWidget(),
            _showNotesTextBox(),
            _showVehicleTextBox(),
            _showOdometerTextBox(),
            _showPrimaryButton()
          ],
        ),
      ),
    );
  }
}
