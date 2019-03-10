import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:milog/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/ui/log_screen.dart';

class ListViewLog extends StatefulWidget {
  ListViewLog({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _ListViewLogState createState() => new _ListViewLogState();
}

var tripsReference;

class _ListViewLogState extends State<ListViewLog> {
  //List of Trips
  List<Trip> _tripList;

  //The database reference
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onTripAddedSubscription;
  StreamSubscription<Event> _onTripChangedSubscription;

  Query _tripQuery;

  @override
  void initState() {
    super.initState();

    _tripList = new List();
    _tripQuery = _database
        .reference()
        .child("Trips")
        .orderByChild("userID")
        .equalTo(widget.userId);

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    tripsReference = database.child('Trips');

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
          itemCount: _tripList.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                Text('Current Trip:',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                    )),
                Divider(
                  height: 5.0,
                ),
                Container(
                  color: Colors.orangeAccent,
                  child: ListTile(
                    title: Text(
                      '${_tripList[position].notes}',
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Color(0xffffffff),
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
                        // IconButton(
                        //     icon: const Icon(Icons.remove_circle_outline),
                        //     onPressed: () => _deleteLog(context, _tripList[position], position)),
                      ],
                    ),
                    onTap: () => _navigateToLog(context, _tripList[position]),
                    onLongPress: () =>
                        _deleteLog(context, _tripList[position], position),
                  ),
                ),
              ],
            );
          });
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  Widget _showDrawer() {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Main Menu'),
            decoration: BoxDecoration(
                color: Color(0xff42CB7C),
                image: DecorationImage(
                  image: AssetImage('images/miLog.png'),
                  fit: BoxFit.fitWidth,
                )),
          ),
          ListTile(
            title: Text('Trips'),
            onTap: () {
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Account'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Vehicles'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () {
              _signOut();
              // Update the state of the app
              // ...
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiLog',
      home: Scaffold(
        appBar: AppBar(
          title: Text('MiLog'),
          centerTitle: true,
          backgroundColor: Color(0xff42CB7C),
          // actions: <Widget>[
          //   FlatButton(
          //       child: Text('Logout',
          //           style: TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: _signOut),
          // ],
        ),
        body: Center(
          child: _showTripList(),
        ),
        drawer: _showDrawer(context),
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
      _tripList.add(new Trip.fromSnapshot(event.snapshot));
    });
  }

  void _onLogUpdated(Event event) {
    var oldLogValue =
        _tripList.singleWhere((trip) => trip.tripID == event.snapshot.key);
    setState(() {
      _tripList[_tripList.indexOf(oldLogValue)] =
          new Trip.fromSnapshot(event.snapshot);
    });
  }

  void _deleteLog(BuildContext context, Trip trip, int position) async {
    await logsReference.child(trip.tripID).remove().then((_) {
      setState(() {
        _tripList.removeAt(position);
      });
    });
  }

  void _navigateToLog(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogScreen(widget.userId, trip)),
    );
  }

  void _createNewLog(BuildContext context) async {
    if (_tripList.length >= 1) {
      _showDialogTripInProgress();
    } else {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogScreen(widget.userId, Trip.newTrip()),
          ));
    }
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
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
