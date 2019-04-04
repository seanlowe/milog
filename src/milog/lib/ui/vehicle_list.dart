import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:milog/ui/vehicle_screen.dart';
import 'package:milog/ui/vehicle_action.dart';

class VehicleList extends StatefulWidget {
  final String userID;
  final Vehicle vehicle;

  VehicleList(this.userID, this.vehicle);

  @override
  _VehicleListState createState() => new _VehicleListState();
}


class _VehicleListState extends State<VehicleList> {
  // variables
  var vehicleReference;
  List<Vehicle> _vehicleList;
  Query _vehicleQuery;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  StreamSubscription<Event> _onVehicleAddedSub;
  StreamSubscription<Event> _onVehicleChangedSub;


  @override
  void initState() {
    super.initState();
    _vehicleList = new List();
    _vehicleQuery = _database
      .reference()
      .child("Vehicles")
      .orderByChild("userID")
      .equalTo(widget.userID);

      FirebaseDatabase.instance.setPersistenceEnabled(true);
      vehicleReference = _database.reference().child('Vehicles');

      _onVehicleAddedSub = _vehicleQuery.onChildAdded.listen(_onVehicleAdded);
      _onVehicleChangedSub = _vehicleQuery.onChildChanged.listen(_onVehicleUpdated);
  }

  @override
  void dispose() {
    _onVehicleAddedSub.cancel();
    _onVehicleChangedSub.cancel();
    super.dispose();
  }

  Widget _showVehicleList() {
    if (_vehicleList.length > 0) {
      return ListView.builder(
        itemCount: _vehicleList.length,
        padding: const EdgeInsets.all(15.0),
        itemBuilder: (context, position) {
          return Column(
            children: <Widget>[
              Divider(height: 5.0),
              Divider(
                height: 5.0,
              ),
              ListTile(
                title: Text(
                  "title",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black
                    ),
                ),
                subtitle: Text(
                  "subtitle",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // onTap -> update
                // onLongPress -> delete
                onTap: () => _navigateToVehicleAction(context, _vehicleList[position]),
                onLongPress: () => _checkIfCanDel(context, _vehicleList[position], position),
              )
            ],
          );
        });
    } else {
      return Center(
        child: Text(
          "No Vehicles",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30.0),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicles")),
      body: Scaffold(
        body: Center(
          child:_showVehicleList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewVehicle(context),
        ),
      ),
    );
  }

  void _onVehicleAdded(Event event) {
    setState(() {
      _vehicleList.add(new Vehicle.fromSnapshot(event.snapshot));
      // isVehicleInUse();
    });
  }

  void _onVehicleUpdated(Event event) {
    var oldVehicleValue = _vehicleList.singleWhere((vehicle) => vehicle.vehicleID == event.snapshot.key);
    setState(() {
      _vehicleList[_vehicleList.indexOf(oldVehicleValue)] = new Vehicle.fromSnapshot(event.snapshot);
      // isVehicleInUse();
    });
  }

  void _checkIfCanDel(BuildContext context, Vehicle vehicle, int position) {
    if (!vehicle.inUse) {
      _showConfimDelDialog(context, vehicle, position);
    }
  }

  // show confirmation dialogue to delete vehicle
  void _showConfimDelDialog(BuildContext context, Vehicle vehicle, int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete Vehicle",
              style: TextStyle(fontSize: 18.0, color: Colors.red)),
          content: Text("Are you sure you want to delete this vehicle?",
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Yes",
                style: TextStyle(
                  fontSize: 18.0, 
                  color: Colors.red
                ),
              ),
              onPressed: () {
                _deleteVehicle(context, vehicle, position);
                Navigator.of(context).pop();
              },
            ),
             FlatButton(
              child: Text(
                "No",
                style: TextStyle(
                  fontSize: 18.0, 
                  color: Colors.black
                ),
              ),
              onPressed: () =>  Navigator.of(context).pop()
            ),
          ],
        );
      },
    );
  }


  void _deleteVehicle(BuildContext context, Vehicle vehicle, int position) async {
    await vehicleReference.child(vehicle.vehicleID).remove().then((_) {
      setState(() {
        _vehicleList.removeAt(position);
      });
    });
  }

  void _navigateToVehicleAction(BuildContext context, Vehicle vehicle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehicleAction(widget.userID, vehicle)),
    );
  }

  void _createNewVehicle(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehicleScreen(widget.userID, Vehicle.newVehicle()),
      ));
  }

  // checks if the vehicle is currently being used in a trip
  // void isVehicleInUse() {
  //   bool inUse = false;
  //   for (Vehicle v in _vehicleList) {
  //     if (v.inUse) {
  //       inUse = true;
  //     }
  //   }
  // }

} // end of class _VehicleListState