import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleList extends StatefulWidget {
  final VoidCallback onSignedOut;
  final String userID;

  VehicleList(this.userID, this.onSignedOut);

  @override
  _VehicleListState createState() => new _VehicleListState();
}


class _VehicleListState extends State<VehicleList> {
  // variables
  List<Vehicle> _vehicleList;
  Query _vehicleQuery;

  final FirebaseDatabase _database =FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _vehicleList = new List();
    _vehicleQuery = _database
      .reference()
      .child("Vehicles")
      .orderByChild("userID")
      .equalTo(widget.userID);
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
      ),
    );
  }

}