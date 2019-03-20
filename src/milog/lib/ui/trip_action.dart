import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';

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

  //When the "Activity Starts"
  @override
  void initState() {
    super.initState();

    tripDatabase = FirebaseDatabase.instance.reference();
    tripsReference = tripDatabase.child('Trips');

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
            Text(widget.trip.notes,
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            Text(widget.trip.vehicle,
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            _showPauseResumeButton(),
            _showEndTripButton()
          ],
        ),
      ),
    );
  }

  void setPausedOrResume() {
    if (!widget.trip.paused) {
      //Pause the trip
      print("Trip is not paused -> pause");
      tripsReference.child(widget.trip.tripID).child("paused").set(true);
    } else {
      //Resume the trip
      print("Trip is paused -> resume");
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
    }
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
              Navigator.pop(context);
            },
          ),
        ));
  }
}
