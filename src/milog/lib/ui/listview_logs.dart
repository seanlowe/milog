import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:milog/ui/user_screen.dart';
import 'package:milog/ui/log_screen.dart';
import 'package:milog/ui/trip_action.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:milog/ui/vehicle_list.dart';
import 'package:milog/ui/faq_screen.dart';

class ListViewLog extends StatefulWidget {
  ListViewLog({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  // This is the state of ListViewLogs
  _ListViewLogState createState() => new _ListViewLogState();
}

class _ListViewLogState extends State<ListViewLog> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */
  // ----------------------------------------

  List<Trip> _tripList;
  List<Vehicle> _vehicleList;
  bool tripInProgress;

  var tripsReference;
  var vehicleReference;

  // Query to get the User's trips & vehicles
  Query _tripQuery;
  Query _vehicleQuery;

  // The database reference
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onTripAddedSubscription;         //Triggers when a trip is added
  StreamSubscription<Event> _onTripChangedSubscription;       //Triggers when a trip is changed
  StreamSubscription<Event> _onVehicleAddedSub;               //Triggers when a vehicle is added
  StreamSubscription<Event> _onVehicleChangedSub;             //Triggers when a vehicle is changed
  StreamSubscription<Event> _onTripRemovedSub;                //Triggers when a trip is removed
  StreamSubscription<Event> _onVehicleRemovedSub;             //Triggers when a vehicle is removed

  String miLogSite = 'https://milog.org';

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override
  void initState() {
    super.initState();
    tripInProgress = false;

    _tripList = new List();
    _vehicleList = new List();
    _tripQuery = _database
        .reference()
        .child("Trips")
        .orderByChild("userID")
        .equalTo(widget.userId);
    _vehicleQuery = _database
        .reference()
        .child("Vehicles")
        .orderByChild("userID")
        .equalTo(widget.userId);

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    tripsReference = _database.reference().child('Trips');
    vehicleReference = _database.reference().child('Vehicles');

    //TODO: Need to add Listener for when the database data changes

    //Listeners for Trip List
    _onTripAddedSubscription = _tripQuery.onChildAdded.listen(_onLogAdded);
    _onTripChangedSubscription =
        _tripQuery.onChildChanged.listen(_onLogUpdated);

    //Listeners for Vehicle List
    _onVehicleAddedSub = _vehicleQuery.onChildAdded.listen(_onVehicleAdded);
    _onVehicleChangedSub =
        _vehicleQuery.onChildChanged.listen(_onVehicleUpdated);

    _onTripRemovedSub = _tripQuery.onChildRemoved.listen(_onTripRemovedDB);
    _onVehicleRemovedSub = _vehicleQuery.onChildRemoved.listen(_onVehicleRemovedDB);
  }

  @override
  void dispose() {
    _onTripAddedSubscription.cancel();
    _onTripChangedSubscription.cancel();
    _onVehicleAddedSub.cancel();
    _onVehicleChangedSub.cancel();
    _onTripRemovedSub.cancel();
    _onVehicleRemovedSub.cancel();
    super.dispose();
  }

  // We need to return a Scaffold instead of another instance of
  // Material app for the Drawer to work
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Trips")),
      drawer: _showDrawer(context),
      body: Scaffold(
        body: Center(
          child: _showTripList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewLog(context),
        ),
      ),
    );
  }

  // ----------------------------------------
  /*         NAVIGATION FUNCTIONS          */
  // ----------------------------------------

  // main source of navigation throughout the app
  Widget _showDrawer(BuildContext context) {
    return Drawer(
      elevation: 12.0,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent[400]),
              child: Container(
                child: Text(
                  '\n\n\nMain Menu',
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10.0),
                width: 10.0,
                height: 10.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: AssetImage("images/miLog.png"),
                    alignment: Alignment(1, 1),
                    fit: BoxFit.scaleDown,
                  ),
                  // Add the Drawer image here (user icon perhaps?)
                ),
              )),
          Container(
              child: Column(
            children: <Widget>[
              ListTile(
                title: Text('Account'),
                leading: new Icon(Icons.perm_identity, color: Colors.black),
                // trailing: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue,)))),
                onTap: () {
                  _navigateToUserScreen();
                },
              ),
              ListTile(
                title: Text('Vehicles'),
                leading: new Icon(Icons.directions_car, color: Colors.blue),
                onTap: () {
                  _navigateToVehicles(context);
                },
              ),
              ListTile(
                leading: new Icon(Icons.web, color: Colors.blue[300]),
                title: Text('Go to milog.org'),
                onTap: () {
                  //Open milog.org in browser
                  _launchInBrowser(miLogSite);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: new Icon(Icons.help, color: Colors.orange),
                title: Text('FAQ'),
                onTap: () {
                 _navigateToFAQ(context);
                },
              ),
              ListTile(
                leading: new Icon(Icons.exit_to_app, color: Colors.red[300]),
                title: Text('Sign Out'),
                onTap: () {
                  _signOut();
                  Navigator.pop(context);
                },
              ),
              // End of container -> column -> children
            ],
          )),
        ],
      ),
    );
  }

  void _navigateToVehicles(BuildContext context) async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VehicleList(widget.userId, _vehicleQuery, _vehicleList)),
    );
  }

  void _navigateToLog(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      // We want to update the Trip, so pass true
      MaterialPageRoute(
          builder: (context) => LogScreen(
              _vehicleList, _vehicleQuery, widget.userId, trip, true)),
    );
  }

  void _navigateToTripAction(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      // We're not updating the Trip, so don't pass in true
      MaterialPageRoute(
          builder: (context) => TripAction(widget.userId, trip, _vehicleList)),
    );
  }

  void _navigateToFAQ(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQScreen()),
    );
    Navigator.pop(context);
  }

  void _navigateToUserScreen() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserScreen()),
    );
  }

  // Signs out the user
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  // ----------------------------------------
  /*            WEB FUNCTIONS              */
  // ----------------------------------------

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  // ----------------------------------------
  /*  ADD / DELETE & SUPPORTING FUNCTIONS  */
  // ----------------------------------------

  // Check to make sure we can't delete a trip that is in progress
  void checkIfCanDel(BuildContext context, Trip trip, int position) {
    if (!trip.inProgress) _showConfimDelDialog(context, trip, position);
  }

  // supporting function to checkIfCanDel()
  // middle step to deleting a log
  void _showConfimDelDialog(BuildContext context, Trip trip, int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete Trip",
              style: TextStyle(fontSize: 18.0, color: Colors.red)),
          content: Text("Are you sure you want to delete this trip?",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Yes",
                style: TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              onPressed: () {
                //Delete trip from the database rather than the applicatio
                _deleteTrip(context, trip, position);          
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "No",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
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

  /*Deletes the passed in trip from the DB
  _onTripRemovedSub then gets activated by DB and deletes the trip in the app*/
  void _deleteTrip(BuildContext context, Trip trip, int position) async {
    await tripsReference.child(trip.tripID).remove();
  }

  // function used to create a log
  void _createNewLog(BuildContext context) async {
    if (!_checkEmptyVehicleList()) {
      // for (int i = 0; i < _vehicleList.length; i++) {
      //   print(_vehicleList[i].name.toString());
      // }
      // If there is a trip in progress
      if (tripInProgress) {
        _showDialogTripInProgress();
      } else {
        /*
        Mobile apps typically reveal their contents via full-screen elements called "screens" or "pages". 
        In Flutter these elements are called routes and they're managed by a Navigator widget. 
        The navigator manages a stack of Route objects and provides methods for managing the stack, like Navigator.push and Navigator.pop.
        */
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogScreen(_vehicleList, _vehicleQuery,
                  widget.userId, Trip.newTrip(), false),
            ));
      }
    }
  }

  bool _checkEmptyVehicleList() {
    bool result = false;
    if (_vehicleList.isEmpty) {
      result = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Oops!",
                style: TextStyle(fontSize: 18.0, color: Colors.red)),
            content: Text("Please Add A Vehicle",
                style: TextStyle(fontSize: 18.0, color: Colors.black)),
            actions: <Widget>[
              // buttons at the bottom of the dialog
              FlatButton(
                child: Text(
                  "Add Vehicle",
                  style: TextStyle(fontSize: 18.0, color: Colors.blueAccent),
                ),
                onPressed: () {
                  _navigateToVehicles(context);
                  result = false;
                  // Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    return result;
  }

  // Dialog that shows a trip is in progress
  // supporting function to _createNewLog()
  void _showDialogTripInProgress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Oops!",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content: Text("A Trip is already in progress.",
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

  // ----------------------------------------
  /*    DATABASE SUBSCRIPTION FUNCTIONS    */
  // ----------------------------------------

  void _onVehicleAdded(Event event) {
    print("Entered _onVehicleAdded");
    setState(() {
      _vehicleList.add(new Vehicle.fromSnapshot(event.snapshot));
    });
  }

  void _onTripRemovedDB(Event event){
    print("onTripRemovedDB was invoked");
    var oldTripValue = _tripList
        .singleWhere((trip) => trip.tripID == event.snapshot.key);
    setState(() {
      _tripList.removeAt(_tripList.indexOf(oldTripValue));
    });
  }

  void _onVehicleRemovedDB(Event event){
    print("onVehicleRemovedDB was invoked");
    var oldVehicleValue = _vehicleList
        .singleWhere((vehicle) => vehicle.vehicleID == event.snapshot.key);
    setState(() {
      _vehicleList.removeAt(_vehicleList.indexOf(oldVehicleValue));
    });
  }

  void _onVehicleUpdated(Event event) {
    var oldVehicleValue = _vehicleList
        .singleWhere((vehicle) => vehicle.vehicleID == event.snapshot.key);
    setState(() {
      _vehicleList[_vehicleList.indexOf(oldVehicleValue)] =
          new Vehicle.fromSnapshot(event.snapshot);
    });
  }

  void _onLogUpdated(Event event) {
    var oldLogValue =
        _tripList.singleWhere((trip) => trip.tripID == event.snapshot.key);
    setState(() {
      print("Entered _onLogUpdated!");
      _tripList[_tripList.indexOf(oldLogValue)] =
          new Trip.fromSnapshot(event.snapshot);
      isTripInProg();
    });
  }

  void _onLogAdded(Event event) {
    print("Entered _onLogAdded!");
    setState(() {
      print("onLogAdded added a Trip to the _tripList list!");
      _tripList.add(new Trip.fromSnapshot(event.snapshot));
      isTripInProg();
    });
  }

  // supporting function for _onLogAdded() & _onLogUpdated()
  // Sets tripInProgress if a trip is in progress, otherwise sets to false
  void isTripInProg() {
    sortTrips();
    bool inProgress = false;
    for (Trip t in _tripList) {
      if (t.inProgress) {
        tripInProgress = true;
        inProgress = true;
      }
    }
    (inProgress) ? makeInProgFirst() : tripInProgress = false;
  }

  // supporting function for isTripInProg()
  // Swaps the first index trip with trip that is in progress
  void makeInProgFirst() {
    if (_tripList.length > 0) {
      for (int i = 0; i < _tripList.length; i++) {
        Trip temp;
        if (_tripList[i].inProgress) {
          temp = _tripList[0];
          _tripList[0] = _tripList[i];
          _tripList[i] = temp;
        }
      }
    }
  }

  //Sorts the tips based on the timestamp (in progress trip always first)
  void sortTrips(){
    _tripList.sort((b, a) => a.startTime.compareTo(b.startTime));
  }

  // ----------------------------------------
  /*           TRIPLIST FUNCTIONS          */
  // ----------------------------------------

  // function that actually shows the list of trips
  Widget _showTripList() {
    if (_tripList.length > 0) {
      return ListView.builder(
          // How many items in the list
          itemCount: _tripList.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                Divider(
                  height: 5.0,
                ),
                Container(
                  decoration: (_tripList[position].inProgress)
                      ? new BoxDecoration(
                          color: Colors.yellow[300],
                          border: new Border(
                              bottom: BorderSide(color: Colors.blue, width: 2)))
                      : new BoxDecoration(
                          color: Colors.white,
                          border: new Border(
                              bottom:
                                  BorderSide(color: Colors.blue, width: 2))),
                  // If trip is in progress, the containers is yellow
                  child: ListTile(
                      title: Text(
                        _tripList[position].notes.toString(),
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: _showTripSubtitle(
                          _tripList[position].inProgress, position),
                      leading: _tripIcon(_tripList[position].inProgress,
                          _tripList[position].paused),
                      // TAP
                      onTap: () {
                        if (_tripList[position].inProgress) {
                          _navigateToTripAction(context, _tripList[position]);
                        } else {
                          _navigateToLog(context, _tripList[position]);
                        }
                      },
                      // LONG PRESS
                      onLongPress: () => checkIfCanDel(
                          context, _tripList[position], position)),
                ),
              ],
            );
          });
    } else {
      return Center(
          child: Text(
        "No Trip Logs",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  // supporting function for _showTripList()
  Widget _showTripSubtitle(bool inProg, int position) {
    if (inProg) {
      return Text(
        "Active car: " + _tripList[position].vehicle.toString(),
        style: TextStyle(
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      return Text(
        "Miles Traveled: " + _tripList[position].milesTraveled.toString(),
        style: TextStyle(
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
        ),
      );
    }
  }

  // supporting function for _showTripList()
  // Decides what icon to put into the trip ListTile (that's in a container)
  Widget _tripIcon(bool inProg, bool paused) {
    if (inProg && !paused)
      return Icon(Icons.drive_eta, color: Colors.blue[300]);
    else if (inProg && paused)
      return Icon(Icons.watch_later, color: Colors.orange);
    else {
      return Icon(Icons.check_circle, color: Colors.green[300]);
    }
  }
} // end of class _ListViewLogState
