/*
This widget adds or updates logs. It's called using a navigator.
Since the same widget is used for updating and adding, a bool is
passed in to determine if we are adding or updating
*/

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:milog/ui/vehicle_list.dart';
import 'package:milog/ui/camera_screen.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatefulWidget {
  final Trip trip;
  final List<Vehicle> _vehicleList;
  Integer odometerFromPicture;
  final Query _vehicleQuery;
  final String userId;
  final bool update; // are we updating a trip?

  LogScreen(this._vehicleList, this._vehicleQuery, this.userId, this.trip,
      this.update);

  @override
  State<StatefulWidget> createState() => new _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */
  // ----------------------------------------

  // Every textbox needs a "controller"
  TextEditingController _vehicleController;
  TextEditingController _notesController;
  TextEditingController _odometerReading;

  // for dropdown selector .. DON'T TOUCH
  // the dropdown is fragile . . .
  Vehicle selected = null;

  var tripDatabase;
  var tripsReference;
  var vehicleReference;

  // String set titles for LogScreen (this class)
  String strUpdateTitle = "View & Edit Trip";
  String strNewTripTitle = "New Trip";
  String title;

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  // When the Activity "Starts"
  @override
  void initState() {
    super.initState();
    getTripDate();

    widget.odometerFromPicture = Integer(0);

    tripDatabase = FirebaseDatabase.instance.reference();
    tripsReference = tripDatabase.child('Trips');
    vehicleReference = tripDatabase.child('Vehicles');

    // Sets the appropriate title
    title = widget.update ? strUpdateTitle : strNewTripTitle;

    // Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    // Create instances of the controller => A controller for an editable text field.
    // Remember to convert things to Strings if they are going into textboxes!
    // This happens at start... what's written in the TextBoxes
    _notesController = new TextEditingController();
    _vehicleController = new TextEditingController();
    _odometerReading = new TextEditingController();

    // make sure odometerReading has some value in it regardless
    _odometerReading.text = "0";

    //Only adds the info in the textboxes when were are doing update
    if (widget.update) {
      _notesController.text = widget.trip.notes.toString();
      _vehicleController.text = widget.trip.vehicle.toString();
      _odometerReading.text = widget.trip.endOdometer.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.topCenter,
        child: new ListView(
          // shrinkWrap makes it scrollable
          shrinkWrap: true,
          /* New discovery, to make widgets optional, look at code below */
          children: <Widget>[
            _selectTopWidget(),
            _showNotesTextBox(),
            (widget.update) ? _showVehicleTextBox() : _showVehicleDropdown(),
            (widget.update) ? _showOdometerTextBox() : _showOdoAndCamera(),
            // Optional
            (widget.trip.startOdometer != 0) ? _showAddChargeButton() : null,
            _showPrimaryButton(),
          ].where((c) => c != null).toList(),
        ),
      ),
    );
  }

  // ----------------------------------------
  /*     REDACTED / UN-NEEDED AT PRESENT   */
  // ----------------------------------------

  // String _getVehicleName(Vehicle v) {
  //   return v.name.toString();
  // }

  // ----------------------------------------
  /*              INPUT FIELDS             */
  // ----------------------------------------

  // show a dropdown vehicle selector for new trips
  Widget _showVehicleDropdown() {
    List<DropdownMenuItem<Vehicle>> _listVehicles = [];

    // create array of DropdownMenuItems
    // print(widget._vehicleList[1].name.toString());
    _listVehicles = widget._vehicleList
        .map((val) => new DropdownMenuItem<Vehicle>(
              child: new Text(val.name.toString()),
              value: val,
            ))
        .toList();

    // print each item we got
    // for (int i = 0; i < _listVehicles.length; i++) {
    //   print("!!! " + _listVehicles[i].value.toString());
    // }

    return new Container(
        decoration: BoxDecoration(
          border: Border(bottom: new BorderSide(color: Colors.grey, width: 1)),
        ),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
                value: selected,
                items: _listVehicles,
                iconSize: 35.0,
                style: new TextStyle(
                  fontSize: 22.0,
                  color: Colors.black,
                ),
                hint: Text("Select a Vehicle"),
                onChanged: (value) {
                  selected = value;
                  if(int.parse(_odometerReading.text.toString()) < int.parse( selected.lastKnownOdometer.toString())){
                    _odometerReading.text = selected.lastKnownOdometer.toString();
                  }
                  print("selected = " +
                      selected.name +
                      " | value = " +
                      value.name);
                  setState(() {/* */});
                })));
  }

  Widget _showOdoAndCamera() {
    return ListTile(
        title: _showOdometerTextBox(),
        trailing: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.blue),
          color: Colors.blue,
          onPressed: () {
            _navigateToCamera(context);
          },
        ));
  }

  // show a textbox for vehicle field on existing trips
  Widget _showVehicleTextBox() {
    return TextField(
        controller: _vehicleController,
        decoration: InputDecoration(labelText: 'Vehicle'),
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
        ));
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

  // ----------------------------------------
  /*        BUTTONS & OTHER SHOWABLE       */
  // ----------------------------------------

  // Determines which widget to show, if updating or viewing
  // the Trip information will be displayed on top. If we are
  // adding a new trip, we don't have trip info so it will
  // return a text with instructions.
  Widget _selectTopWidget() {
    if (widget.trip.startOdometer == 0) {
      return _showAddIns();
    } else {
      return _showSelectedTrip();
    }
  }

  // A little message when adding a trip
  Widget _showAddIns() {
    return Center(
      child: Text('Almost ready to go!',
          style: new TextStyle(fontSize: 24.0, color: Colors.black)),
    );
  }

  //Button for adding charges when the trip is over
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

  // supporting function for _showAddChargeButton()
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

  void _navigateToVehicles(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VehicleList(
              widget.userId, widget._vehicleQuery, widget._vehicleList)),
    );
    Navigator.pop(context);
  }

  void _navigateToCamera(BuildContext contect) async {
    //print("Before Camera Screen: " + widget.odometerFromPicture.value.toString());
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraScreen(widget.odometerFromPicture)),
    );
    //print("After Camera Screen: " + widget.odometerFromPicture.value.toString());
    _showDialogCheckOdometer();
  }

  // ----------------------------------------
  /*           TRIPLIST FUNCTIONS          */
  // ----------------------------------------

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60.0)),
            color: Colors.green,
            child: (widget.update)
                ? Text('Update Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : Text('Add Trip',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              if (widget.trip.tripID != null) {
                updateTrip();
              } else {
                // We check if any fields are empty (true means there are empty fields)
                if (!_checkEmptyFields()) {
                  if (_checkOdo()) {
                    _setVehicleActive(selected);
                    // TODO: use push class/object instead
                    tripsReference.push().set({
                      'notes': _notesController.text.toString(),
                      // 'vehicle': _vehicleController.text,
                      'vehicle': selected.name.toString(),
                      'startOdometer':
                          int.parse(_odometerReading.text.toString()),
                      'startTime': ServerValue.timestamp,
                      'endTime': 0,
                      'endOdometer': 0,
                      'milesTraveled': 0,
                      'totCharges': 0.0,
                      'userID': widget.userId,
                      'vehicleID': selected.vehicleID,
                      'inProgress': true,
                      'paused': false
                    }).then((_) {
                      Navigator.pop(context);
                    });
                  }
                }
              }
            },
          ),
        ));
  }

  // supporting function for _showPrimaryButton()
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

  void _showDialogCheckOdometer() async {
    TextEditingController _odometerFieldDialog = TextEditingController();
    //Setting textField in this Dialog to the one from picture
    _odometerFieldDialog.text = widget.odometerFromPicture.value.toString();

    //Local helper function
    Widget _showTextField() {
      return TextField(
        controller: _odometerFieldDialog,
        keyboardType: TextInputType.number,
      );
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("We think your Odometer is:",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content:  _showTextField(),
          actions: <Widget>[
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(fontSize: 18.0, color: Colors.green),
              ),
              onPressed: () {
                //Copy what's in the TextField in Dialog to TextField in LogScreen.
                if(int.parse(_odometerFieldDialog.text.toString()) > int.parse(_odometerReading.text.toString())){
                  _odometerReading.text = _odometerFieldDialog.text.toString();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // supporting function for _showPrimaryButton()
  void _setVehicleActive(Vehicle active) {
    int index = widget._vehicleList.indexOf(selected);
    widget._vehicleList[index].setInUse = true;
    vehicleReference.child(selected.vehicleID).child('inUse').set(true);
  }

  // Checks if fields are empty
  bool _checkEmptyFields() {
    bool result = false;
    bool odoEmpty = false;
    if (_odometerReading.text.toString() == "0" ||
        _odometerReading.text.isEmpty) {
      odoEmpty = true;
    }
    bool notesEmpty = _notesController.text.isEmpty;
    bool selectedVehicleEmpty = false;
    if (selected == null) {
      selectedVehicleEmpty = true;
      result = true;
    }

    // If one of the fields are empty - call the dialog
    if (notesEmpty || odoEmpty || selectedVehicleEmpty) {
      _showDialogEmptyFields(odoEmpty, notesEmpty, selectedVehicleEmpty);
      result = true;
    }

    return result;
  }

  bool _checkOdo() {
    bool result = widget._vehicleList[widget._vehicleList.indexOf(selected)]
        .checkOdoValid(int.parse(_odometerReading.text.toString()));

    if (!result) {
      _showDialogInvalidOdometer();
    }

    return result;
    // return widget._vehicleList[widget._vehicleList.indexOf(widget._vehicleList.where((v) => v.vehicleID == widget.trip.vehicleID).elementAt(0))].checkOdoValid(newOdo);
  }

  void _showDialogInvalidOdometer() {
    print("_showDialogInvalidOdometer() invoked");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Oops!",
              style: TextStyle(fontSize: 18.0, color: Colors.red)),
          content: Text(
              "The Mileage you entered is less than the last known odometer for your" +
                  selected.name.toString() +
                  ".\n \nYour last known odometer was " +
                  selected.lastKnownOdometer.toString() +
                  " miles.",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            FlatButton(
              child: Text("OK",
                  style: TextStyle(fontSize: 18.0, color: Colors.blueAccent)),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  // Shows appropriate dialog when fields are empty
  void _showDialogEmptyFields(bool odo, bool notes, bool vehicle) {
    print("showDialogEmptyFields invoked");

    String message = "Please fill in: ";
    if (notes) {
      message += "\n *Note ";
    }
    if (vehicle) {
      message += "\n *Vehicle";
    }
    if (odo) {
      message += "\n *Odometer value";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Oops!",
              style: TextStyle(fontSize: 18.0, color: Colors.red)),
          content: Text(message,
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            //buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "OK",
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

  // Displays the information of the selected trip
  Widget _showSelectedTrip() {
    final formatCurrency = new NumberFormat.simpleCurrency();
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
          Text("Miles Traveled: " + widget.trip.milesTraveled.toString(),
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Fees: " + "${formatCurrency.format(widget.trip.totCharges)}",
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          Text("Date: " + getTripDate(),
              textAlign: TextAlign.left,
              style: new TextStyle(fontSize: 20.0, color: Colors.black))
        ]));
  }

  // supporting function for _showSelectedTrip()
  String getTripDate() {
    print("startTime timestamp in Class: " + widget.trip.startTime.toString());
    DateTime date =
        new DateTime.fromMillisecondsSinceEpoch(widget.trip.startTime)
            .toLocal();
    var formatter = new DateFormat('MM/dd/yyyy');
    String formatted = formatter.format(date);
    return formatted;
  }
} // end of class _LogScreenState

//Wrapper for Ints
class Integer {
  int _value;
  Integer(this._value);

  set setValue(int input) => _value = input;
  get value => _value;
}
