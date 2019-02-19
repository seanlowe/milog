import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Trip.dart';
import 'package:milog/ui/log_screen.dart';

class ListViewLog extends StatefulWidget {
  @override
  _ListViewLogState createState() => new _ListViewLogState();
}

//The database reference
final database = FirebaseDatabase.instance.reference();
var tripsReferene;

class _ListViewLogState extends State<ListViewLog> {
  //List of Trips
  List<Trip> items;
  StreamSubscription<Event> _onTripAddedSubscription;
  StreamSubscription<Event> _onTripChangedSubscription;

  @override
  void initState() {
    super.initState();
    items = new List();

    //Turns on Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    tripsReferene = database.child('Trips');

    //TODO: Need to add Listener for when the database data changes
    _onTripAddedSubscription = logsReference.onChildAdded.listen(_onLogAdded);
    _onTripChangedSubscription = logsReference.onChildChanged.listen(_onLogUpdated);
  }

  @override
  void dispose() {
    _onTripAddedSubscription.cancel();
    _onTripChangedSubscription.cancel();
    super.dispose();
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
        ),
        body: Center(
          child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(15.0),
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(height: 5.0),
                    Container(
                      color: Colors.orangeAccent,
                      child:ListTile(
                        title: Text(
                          '${items[position].notes}',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Color(0xffffffff),
                          ),
                        ),
                        subtitle: Text(
                          '${items[position].vehicle}',
                          style: new TextStyle(
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
                            //     onPressed: () => _deleteLog(context, items[position], position)),
                          ],
                        ),
                        onTap: () => _navigateToLog(context, items[position]),
                        onLongPress: () => _deleteLog(context, items[position], position),
                      ),
                    ),
                  ],
                );
              }),
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Main Menu'),
                decoration: BoxDecoration(
                  color: Color(0xff42CB7C),
                  image:DecorationImage(
                    image:AssetImage('images/miLog.png'),
                    fit: BoxFit.contain,

                  )
                ),
              ),
              ListTile(
                title: Text('Trips'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
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
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
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
      items.add(new Trip.fromSnapshot(event.snapshot));
    });
  }

  void _onLogUpdated(Event event) {
    var oldLogValue = items.singleWhere((trip) => trip.tripID == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldLogValue)] = new Trip.fromSnapshot(event.snapshot);
    });
  }

  void _deleteLog(BuildContext context, Trip trip, int position) async {
    await logsReference.child(trip.tripID).remove().then((_) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToLog(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogScreen(trip)),
    );
  }

  void _createNewLog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogScreen(Trip.newTrip()),
    ));
  }
}