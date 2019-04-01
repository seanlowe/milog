import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleList extends StatefulWidget {
  final String userID;

  VehicleList(this.userID);

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
                  "title hkajhfkjahdkahsd",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black
                    ),
                ),
                subtitle: Text(
                  "subtitle akjhsdkasd",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                onTap: () => _navigateToVehicle(context, _vehicleList[position]),
                // onLongPress: () => _deleteVehicle(context, vehicle, position),
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

  }

  void _onVehicleUpdated(Event event) {

  }

  void _deleteVehicle(BuildContext context, Vehicle vehicle, int position) async {
    
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
      MaterialPageRoute(builder: (context) => VehicleScreen(widget.userID, Vehicle.newVehicle(), false),
      ));
  }

}