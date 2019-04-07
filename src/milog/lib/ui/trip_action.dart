import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:intl/intl.dart';

// This class handles pausing, resuming and ending trips

class TripAction extends StatefulWidget {
  final Trip trip;
  final String userId;
  // Query _vehicleQuery;
  List<Vehicle> _vehicleList;

  TripAction(this.userId, this.trip, this._vehicleList);

  @override
  State<StatefulWidget> createState() => new _TripScreenActionState();
}

class _TripScreenActionState extends State<TripAction> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */ 
  // ----------------------------------------

  var tripDatabase;
  var tripsReference;
  var vehicleReference;
  // TextEditing for the odometer input
  TextEditingController _odometerReadingDiag;

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  // When the Activity "Starts"
  @override
  void initState() {
    print("Entered TripAction (via navigator");
    super.initState();

    tripDatabase = FirebaseDatabase.instance.reference();
    tripsReference = tripDatabase.child('Trips');
    vehicleReference = tripDatabase.child('Vehicles');
    _odometerReadingDiag = new TextEditingController();

    // Turns on Persistence
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

  // ----------------------------------------
  /*           CONTENT BUILDING            */
  // ----------------------------------------

  // Displays the information of the selected trip
  Widget _showSelectedTrip() {
    return Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Column(children: <Widget>[
          Text("Notes: " + widget.trip.notes,
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Vehicle: " + widget.trip.vehicle,
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Starting Odometer: " + widget.trip.startOdometer.toString(),
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Date: " + getTripDate(),
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black))
        ]));
  }

  // TODO probably need to check if miles is >= starting odo here as well
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
              // We are setting isPaused in Trip to true in DB
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
               if(!_isOdoLessThanStart())
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

  // supporting function of _showSelectedTrip()
  String getTripDate() {
    print("startTime timestamp in Class: " + widget.trip.startTime.toString());

    DateTime date =
        new DateTime.fromMillisecondsSinceEpoch(widget.trip.startTime)
            .toLocal();
    var formatter = new DateFormat('MM/dd/yyyy');
    String formatted = formatter.format(date);
    return formatted;
  }

  // ----------------------------------------
  /*       TRIP PROCESSING FUNCTIONS       */
  // ----------------------------------------

  // supporting function of _showPauseResumeButton()
  // When user presses pause or resume
  // TODO: Check user input!
  void processPause() {
    if (_odometerReadingDiag.text.isEmpty) {
      _showDialogEmptyOdo();
    } else {
      if (widget.trip.paused) {
        // Trip is paused
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
        // Trip is not paused
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
      // Update the trip paused bool
      setPausedOrResume();
      Navigator.pop(context);
    }
  }

  // Returns true if entered Odo value is < starting Odometer value 
  bool _isOdoLessThanStart(){
    bool result = false;
    bool emptyOdo = _odometerReadingDiag.text.isEmpty;
    if(!emptyOdo){
      int odoVal = int.parse(_odometerReadingDiag.text.toString());
      if(odoVal < widget.trip.startOdometer){
        result = true;

        showDialog(
        context: context,
        builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Oops!",
              style: TextStyle(fontSize: 18.0, color: Colors.red)),
          content: Text("You entered an Odometer value less than your starting value.",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            // buttons at the bottom of the dialog
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
    }
    return result;
  }

  // supporting function for processPause() & processOdoMiles()
  // Dialog when Odometer field is empty
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
            // buttons at the bottom of the dialog
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

  // supporting function for processPause()
  void setPausedOrResume() {
    if (!widget.trip.paused) {
      // Pause the trip
      print("Selected trip paused set to true");
      tripsReference.child(widget.trip.tripID).child("paused").set(true);
      widget.trip.setpaused = true;
    } else {
      // Resume the trip
      print("Selected trip paused set to false");
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
      widget.trip.setpaused = false;
    }
  }

  // supporting function of _showEndTripButton()
  // Check if the user entered something in the Odometer TextField
  // If there is something, it pops to the main screen.
  // End the trip by setting the endOdometer and invoke calculation
  void processOdoMiles() {
    // If trip is not paused and the odometer text field is empty
    if (_odometerReadingDiag.text.isEmpty && !widget.trip.paused) {
      print("User did not put a Odometer value! -> aborting");
      _showDialogEmptyOdo();
      // If trip is paused and odometer text field is empty
    } else if (_odometerReadingDiag.text.isEmpty && widget.trip.paused) {
      print("Trip is paused and Odo text field is empty -> ending trip");
      widget.trip.endPausedTrip();
      // Sets endOdometer in DB
      tripsReference
          .child(widget.trip.tripID)
          .child("endOdometer")
          .set(widget.trip.endOdometer);
      // Sets endTime via Server timestamp
      tripsReference
          .child(widget.trip.tripID)
          .child("endTime")
          .set(ServerValue.timestamp);
      // End the trip - set inProgress and paused to false just in case
      tripsReference.child(widget.trip.tripID).child("inProgress").set(false);
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
      _setVehicleInactive(widget.trip.vehicle);
      Navigator.pop(context);
    } else {
      // Sets the end Odometer reading in the DB
      widget.trip.setEndOdo(int.parse(_odometerReadingDiag.text));
      // Sets endOdometer in DB
      tripsReference
          .child(widget.trip.tripID)
          .child("endOdometer")
          .set(int.parse(_odometerReadingDiag.text));
      // Sets milesTraveled in DB
      tripsReference
          .child(widget.trip.tripID)
          .child("milesTraveled")
          .set(widget.trip.milesTraveled);
      // Sets endTime via Server timestamp
      tripsReference
          .child(widget.trip.tripID)
          .child("endTime")
          .set(ServerValue.timestamp);
      // End the trip - set inProgress and paused to false just in case
      tripsReference.child(widget.trip.tripID).child("inProgress").set(false);
      tripsReference.child(widget.trip.tripID).child("paused").set(false);
      _setVehicleInactive(widget.trip.vehicle);
      Navigator.pop(context);
    }
  }

  // supporting function of processOdoMiles
  void _setVehicleInactive(String active) {
    for (int i = 0; i < widget._vehicleList.length; i++) {
      if (widget._vehicleList[i].name.toString() == active) {
        widget._vehicleList[i].setInUse = false;
        vehicleReference.child(widget._vehicleList[i].vehicleID).child('inUse').set(false);
      } 
    }
  }
  
  // supporting function of _showAddChargeButton()
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
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Add",
                style: TextStyle(fontSize: 18.0, color: Colors.green),
              ),
              onPressed: () {
                double newChargeAmt =
                    double.parse(_chargeFieldControl.text.toString());
                print("Got: " + newChargeAmt.toString() + " from user.");
                // Set it in the trip object
                widget.trip.addCharge(newChargeAmt);
                // Set it in DB as well
                tripsReference
                    .child(widget.trip.tripID)
                    .child('totCharges')
                    .set(widget.trip.totCharges);
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

} // end of class _TripScreenActionState