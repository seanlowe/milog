import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:milog/model/log.dart';
import 'package:milog/ui/log_screen.dart';

class ListViewLog extends StatefulWidget {
  @override
  _ListViewLogState createState() => new _ListViewLogState();
}

final logsReference = FirebaseDatabase.instance.reference().child('Trips');

class _ListViewLogState extends State<ListViewLog> {
  List<Log> items;
  StreamSubscription<Event> _onLogAddedSubscription;
  StreamSubscription<Event> _onLogChangedSubscription;

  @override
  void initState() {
    super.initState();

    items = new List();

    _onLogAddedSubscription = logsReference.onChildAdded.listen(_onLogAdded);
    _onLogChangedSubscription = logsReference.onChildChanged.listen(_onLogUpdated);
  }

  @override
  void dispose() {
    _onLogAddedSubscription.cancel();
    _onLogChangedSubscription.cancel();
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
                          '${items[position].vehicle}',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Color(0xff63ccca),
                          ),
                        ),
                        subtitle: Text(
                          '${items[position].description}',
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
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _deleteLog(context, items[position], position)),
                          ],
                        ),
                        onTap: () => _navigateToLog(context, items[position]),
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
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Color(0xff397367),
                ),
              ),
              ListTile(
                title: Text('Logs'),
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
      items.add(new Log.fromSnapshot(event.snapshot));
    });
  }

  void _onLogUpdated(Event event) {
    var oldLogValue = items.singleWhere((log) => log.id == event.snapshot.key);
    setState(() {
      items[items.indexOf(oldLogValue)] = new Log.fromSnapshot(event.snapshot);
    });
  }

  void _deleteLog(BuildContext context, Log log, int position) async {
    await logsReference.child(log.id).remove().then((_) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToLog(BuildContext context, Log log) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogScreen(log)),
    );
  }

  void _createNewLog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogScreen(Log(null, "", ''))),
    );
  }
}