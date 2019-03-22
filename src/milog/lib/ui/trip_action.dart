import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';

//This class handles pausing, resuming and ending trips

class TripAction extends StatefulWidget {
  final Trip trip;
  final String userId;

  TripAction(this.userId, this.trip);

  @override
  State<StatefulWidget> createState() => new _TripScreenActionState();
}

class _TripScreenActionState extends State<TripAction> {
  var tripDatabase;
  var tripsReference;
  //TextEditing for the odometer input
  TextEditingController _odometerReadingDiag;

  //When the "Activity Starts"
  @override
  void initState() {
    print("Entered TripAction (via navigator");
    super.initState();

    tripDatabase = FirebaseDatabase.instance.reference();
    tripsReference = tripDatabase.child('Trips');
    _odometerReadingDiag = new TextEditingController();

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trip Options")),
      body: Container(
        margin: EdgeInsets.all(1.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            showSelectedTrip(),
            _showPauseResumeButton(),
            _showEndTripButton(),
            _showOdoTextField()
          ],
        ),
      ),
    );
  }

  //Displays the information of the selected trip
  Widget showSelectedTrip() {
    return Container(
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        decoration: BoxDecoration(
            color: Colors.blue[200],
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(children: <Widget>[
          Text(widget.trip.notes,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text(widget.trip.vehicle,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text(widget.trip.startOdometer.toString(),
              style: new TextStyle(fontSize: 20.0, color: Colors.black))
        ]));
  }

  void setPausedOrResume() {
    if (!widget.trip.paused) {
      //Pause the trip
      print("Selected trip paused set to true");
      tripsReference.child(widget.trip.tripID).child("paused").set(true);
    } else {
      //Resume the trip
      print("Selected trip paused set to false");
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
    }
  }

  //Set inProgress to false in DB
  void endTrip() {
    print("Selected trip inProgress set to false");
    tripsReference.child(widget.trip.tripID).child("inProgress").set(false);
  }

  Widget _showOdoTextField() {
    return Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: TextField(
          controller: _odometerReadingDiag,
          decoration: InputDecoration(labelText: "Odometer Reading"),
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
          keyboardType: TextInputType.number,
        ));
  }

  Widget _showPauseResumeButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color:
                (widget.trip.paused) ? Colors.green[300] : Colors.yellow[300],
            child: (widget.trip.paused)
                ? Text('Resume Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.black))
                : Text('Pause Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              //We are setting isPaused in Trip to true in DB
              setPausedOrResume();
              Navigator.pop(context);
            },
          ),
        ));
  }

  Widget _showEndTripButton() {
    print("User Pressed End Trip Button!");
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.red[300],
            child: Text('END TRIP',
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              endTrip();
              Navigator.pop(context);
            },
          ),
        ));
  }
}
