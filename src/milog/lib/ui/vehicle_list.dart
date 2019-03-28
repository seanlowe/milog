import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milog/model/Vehicle.dart';

class VehicleList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _VehicleListActionState();
}

class _VehicleListActionState extends State<VehicleList> {
  // variables

  @override
  void initState() {
    print("Entered VehicleList via navigator");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(""))
    )
  }
}