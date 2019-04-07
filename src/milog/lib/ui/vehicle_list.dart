import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Vehicle.dart';
import 'package:milog/ui/vehicle_screen.dart';
import 'package:milog/ui/vehicle_action.dart';

class VehicleList extends StatefulWidget {
  final String userID;
  List<Vehicle> _vehicleList;
  Query _vehicleQuery;

  //final Vehicle vehicle;

  //VehicleList(this.userID, this.vehicle);
  VehicleList(this.userID, this._vehicleQuery, this._vehicleList);

  @override
  _VehicleListState createState() => new _VehicleListState();
}


class _VehicleListState extends State<VehicleList> {
  // variables
  var vehicleReference;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  StreamSubscription<Event> _onVehicleAddedSub;
  StreamSubscription<Event> _onVehicleChangedSub;


  @override
  void initState() {
    super.initState();
    // widget._vehicleList = [];

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    vehicleReference = _database.reference().child('Vehicles');

    //_onVehicleAddedSub = widget._vehicleQuery.onChildAdded.listen(_onVehicleAdded);
    _onVehicleChangedSub = widget._vehicleQuery.onChildChanged.listen(_onVehicleUpdated);
  }

  @override
  void dispose() {
    //_onVehicleAddedSub.cancel();
    _onVehicleChangedSub.cancel();
    super.dispose();
  }

  Widget _showVehicleList() {
    if (widget._vehicleList.length > 0) {
      return ListView.builder(
        itemCount: widget._vehicleList.length,
        padding: const EdgeInsets.all(15.0),
        itemBuilder: (context, position) {
          return Column(
            children: <Widget>[
              Divider(height: 5.0),
              Divider(
                height: 5.0,
              ),
              Container( 
                decoration: 
                  (widget._vehicleList[position].inUse)
                      ? new BoxDecoration(color: Colors.yellow[300], border: new Border(bottom: BorderSide(color: Colors.blue, width: 2)))
                      : new BoxDecoration(color: Colors.white, border: new Border(bottom: BorderSide(color: Colors.blue, width: 2))),
                child: ListTile(
                title: Text(
                  widget._vehicleList[position].name,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black
                    ),
                ),
                subtitle: Text(
                  // "Odometer: " + widget._vehicleList[position].lastKnownOdometer.toString(),
                  "bool -> " + widget._vehicleList[position].inUse.toString(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // onTap -> update
                // onLongPress -> delete
                onTap: () => _navigateToVehicleAction(context, widget._vehicleList[position]),
                onLongPress: () => _checkIfCanDel(context, widget._vehicleList[position], position),
              )
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
    print("activated onVehicleAdded");
    setState(() {
      widget._vehicleList.add(new Vehicle.fromSnapshot(event.snapshot));
    });
  }

  void _onVehicleUpdated(Event event) {
    var oldVehicleValue = widget._vehicleList.singleWhere((vehicle) => vehicle.vehicleID == event.snapshot.key);
    setState(() {
      widget._vehicleList[widget._vehicleList.indexOf(oldVehicleValue)] = new Vehicle.fromSnapshot(event.snapshot);
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
        widget._vehicleList.removeAt(position);
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

} // end of class _VehicleListState