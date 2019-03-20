import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/ui/log_screen.dart';
import 'package:milog/ui/trip_action.dart';

class ListViewLog extends StatefulWidget {
  ListViewLog({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  //This is the state of ListViewLogs
  _ListViewLogState createState() => new _ListViewLogState();
}

class _ListViewLogState extends State<ListViewLog> {
  //List of Trips
  List<Trip> _tripList;
  bool tripInProgress;

  var tripsReference;

  //The database reference
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onTripAddedSubscription;
  StreamSubscription<Event> _onTripChangedSubscription;

  //Query to get the User's trips
  Query _tripQuery;

  @override
  void initState() {
    super.initState();
    tripInProgress = false;

    _tripList = new List();
    _tripQuery = _database
        .reference()
        .child("Trips")
        .orderByChild("userID")
        .equalTo(widget.userId);

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    tripsReference = _database.reference().child('Trips');

    //TODO: Need to add Listener for when the database data changes
    _onTripAddedSubscription = _tripQuery.onChildAdded.listen(_onLogAdded);
    _onTripChangedSubscription =
        _tripQuery.onChildChanged.listen(_onLogUpdated);
  }

  @override
  void dispose() {
    _onTripAddedSubscription.cancel();
    _onTripChangedSubscription.cancel();
    super.dispose();
  }

  Widget _showTripList() {
    if (_tripList.length > 0) {
      return ListView.builder(
          //How many items in the list
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
                      ? new BoxDecoration(color: Colors.yellow[300])
                      : new BoxDecoration(color: Colors.white),
                  //If trip is in progress, the containers is yellow
                  child: ListTile(
                    title: Text(
                      '${_tripList[position].notes}',
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${_tripList[position].vehicle}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    leading: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(10.0)),
                        CircleAvatar(
                          backgroundColor: Color(0xff00A3BB),
                          radius: 15.0,
                          child: Text(
                            '${position + 1}',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>  _naviagateToTripAction(context, _tripList[position]),
                    onLongPress: () =>
                        _navigateToLog(context, _tripList[position]),
                  ),
                ),
              ],
            );
          });
    } else {
      return Center(
          child: Text(
        "No trip logs",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  Widget _showDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Main Menu'),
            decoration: BoxDecoration(
              color: Color(0xff42CB7C),
              //Add the Drawer image here (user icon perhaps?)
            ),
          ),
          ListTile(
            title: Text('Trips'),
            onTap: () {
              //Since we're currently in ListViewLog, do nothing
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Account'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Vehicles'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () {
              _signOut();
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  /*We need to return a Scaffold instead of another instance of
  Material app for the Drawer to work
  */
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MiLog")),
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

  void _onLogAdded(Event event) {
    setState(() {
      print("Entered _onLogAdded!");
      print("onLogAdded added a Trip to the _tripList list!");
      _tripList.add(new Trip.fromSnapshot(event.snapshot));
      isTripInProg();
    });
  }

  void _onLogUpdated(Event event) {
    var oldLogValue =
        _tripList.singleWhere((trip) => trip.tripID == event.snapshot.key);
    setState(() {
      print("Entered _onLogUpdated!");
      _tripList[_tripList.indexOf(oldLogValue)] =
          new Trip.fromSnapshot(event.snapshot);
    });
  }

  void _deleteLog(BuildContext context, Trip trip, int position) async {
    await tripsReference.child(trip.tripID).remove().then((_) {
      setState(() {
        _tripList.removeAt(position);
      });
    });
  }

  void _navigateToLog(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      //We want to update the Trip, so pass true
      MaterialPageRoute(
          builder: (context) => LogScreen(widget.userId, trip, true)),
    );
  }

  void _naviagateToTripAction(BuildContext context, Trip trip)async {
    await Navigator.push(
      context,
      //We want to update the Trip, so pass true
      MaterialPageRoute(
          builder: (context) => TripAction(widget.userId, trip)),
    );

  }

  void _createNewLog(BuildContext context) async {
    //If there is a trip in progress
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
            builder: (context) =>
                LogScreen(widget.userId, Trip.newTrip(), false),
          ));
    }
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  //Sets tripInProgress if a trip is in progress, otherwise sets to false
  void isTripInProg() {
    bool inProgress = false;
    for (Trip t in _tripList) {
      if(t.inProgress){
        tripInProgress = true;
        inProgress = true;
      }
    }
    (inProgress) ? makeInProgFirst() : tripInProgress = false;
  }

  //Swaps the first index trip with trip that is in progress
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

  //Dialog that shows a trip is in progress
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
}
