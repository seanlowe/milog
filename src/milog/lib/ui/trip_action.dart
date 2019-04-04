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

    _odometerReadingDiag.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trip Options")),
      body: Container(
        margin: EdgeInsets.all(1.0),
        alignment: Alignment.topCenter,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showSelectedTrip(),
            _showPauseResumeButton(),
            _showEndTripButton(),
            _showOdoTextField(),
            _showAddChargeButton(),
          ],
        ),
      ),
    );
  }

  //Displays the information of the selected trip
  Widget _showSelectedTrip() {
    return Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
      widget.trip.setpaused = true;
    } else {
      //Resume the trip
      print("Selected trip paused set to false");
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
      widget.trip.setpaused = false;
    }
  }

  /*Check if the user entered something in the Odometer TextField
  If there is something, it pops to the main screen.
  End the trip by setting the endOdometer and invoke calculation
  */
  void processOdoMiles() {
    if (_odometerReadingDiag.text == "") {
      print("User did not put a Odometer value! -> aborting");
      _showDialogEmptyOdo();
    }
    //TODO: Need to check if the input is correct!
    else {
      //Sets the end Odometer reading in the DB
      widget.trip.setEndOdo(int.parse(_odometerReadingDiag.text));
      //Sets endOdometer in DB
      tripsReference
          .child(widget.trip.tripID)
          .child("endOdometer")
          .set(int.parse(_odometerReadingDiag.text));
      //Sets milesTraveled in DB
      tripsReference
          .child(widget.trip.tripID)
          .child("milesTraveled")
          .set(widget.trip.milesTraveled);
      //Sets endTime via Server timestamp
      tripsReference
          .child(widget.trip.tripID)
          .child("endTime")
          .set(ServerValue.timestamp);
      //End the trip - set inProgress and paused to false just in case
      tripsReference.child(widget.trip.tripID).child("inProgress").set(false);
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
      Navigator.pop(context);
    }
  }

  //When user presses pause or resume
  //TODO: Check user input!
  void processPause() {
    if (_odometerReadingDiag.text.isEmpty) {
      _showDialogEmptyOdo();
    } else {
      if (widget.trip.paused) {
        //Trip is paused
        print("#1 RAN!");
        widget.trip.resumeTrip(int.parse(_odometerReadingDiag.text));
        print("In trip, miles traveled = " +
            widget.trip.milesTraveled.toString());
        tripsReference
            .child(widget.trip.tripID)
            .child("startOdometer")
            .set(widget.trip.startOdometer);
      } else {
        print("#2 RAN!");
        //Trip is not paused
        widget.trip.pauseTrip(int.parse(_odometerReadingDiag.text));
        tripsReference
            .child(widget.trip.tripID)
            .child("milesTraveled")
            .set(widget.trip.milesTraveled);
        tripsReference
            .child(widget.trip.tripID)
            .child("startOdometer")
            .set(widget.trip.startOdometer);
      }
      //Update the trip paused bool
      setPausedOrResume();
      Navigator.pop(context);
    }
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

  //Dialog when Odometer field is empty
  void _showDialogEmptyOdo() {
    print("showDialogEmptyOdo invoked");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Oops!",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content: Text("Please enter your Odometer mileage",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            //buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Ok",
                style: TextStyle(fontSize: 18.0, color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogAddCharge() {
    TextEditingController _chargeFieldControl = TextEditingController();
    print("showDialogAddCharge invoked");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Trip Charge",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content: TextField(
            controller: _chargeFieldControl,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "0.00"),
          ),
          actions: <Widget>[
            //buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Add",
                style: TextStyle(fontSize: 18.0, color: Colors.green),
              ),
              onPressed: () {
                double newChargeAmt = double.parse(_chargeFieldControl.text.toString());
                print("Got: " + newChargeAmt.toString() + " from user.");
                //Set it in the trip object
                widget.trip.addCharge(newChargeAmt);
                //Set it in DB as well
                tripsReference.child(widget.trip.tripID).child('totCharges').set(widget.trip.totCharges);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showPauseResumeButton() {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
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
              processPause();
            },
          ),
        ));
  }

  Widget _showEndTripButton() {
    print("User Pressed End Trip Button!");
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60.0)),
            color: Colors.red[300],
            child: Text('END TRIP',
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              processOdoMiles();
            },
          ),
        ));
  }

  Widget _showAddChargeButton() {
    print("User Pressed Toll Charge Button!");
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60.0)),
            color: Colors.orange,
            child: Text('Add Charges \$',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
               _showDialogAddCharge();
            },
          ),
        ));
  }
}
