import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';


class LogScreen extends StatefulWidget {
  final Trip trip;
  final String userId;
  LogScreen(this.userId, this.trip);

  @override
  State<StatefulWidget> createState() => new _LogScreenState();
}

var database = FirebaseDatabase.instance.reference();
var logsReference = database.child('Trips');

class _LogScreenState extends State<LogScreen> {
  //Every textbox needs a "controller"
  TextEditingController _vehicleController;
  TextEditingController _notesController;
  TextEditingController _odometerReading;

  //When the "Activity Starts"
  @override
  void initState() {
    super.initState();

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    /*Create instances of the controller
    Remember to convert things to Strings if they are going into textboxes!
    This happens at start... what's written in the TextBoxes */
    _notesController = new TextEditingController(text: widget.trip.notes);
    _vehicleController = new TextEditingController(text: widget.trip.vehicle);
    _odometerReading = new TextEditingController(text: widget.trip.startOdometer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New trip')),
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
            Padding(padding: new EdgeInsets.all(5.0)),
            //The Vehicle Text Field
            TextField(
              controller: _vehicleController,
              decoration: InputDecoration(labelText: 'Vehicle'),
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
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
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.trip.tripID != null) ? Text('Update') : Text('Add'),
              color: Colors.green,
              onPressed: () {
                if (widget.trip.tripID != null) {
                  logsReference.child(widget.trip.tripID).set({
                    'notes': _notesController.text,
                    'vehicle': _vehicleController.text,
                    'startOdometer': _odometerReading.text,
                    'userID' : widget.userId
                  }).then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  logsReference.push().set({
                    'notes': _notesController.text,
                    'vehicle': _vehicleController.text,
                    'startOdometer':_odometerReading.text,
                    'userID' : widget.userId
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}