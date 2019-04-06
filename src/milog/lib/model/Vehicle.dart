import 'package:firebase_database/firebase_database.dart';

class Vehicle {
  String _name;
  String _userID;
  String _vehicleID;
  bool _inUse;
  String _bluetoothMAC;   // MAC address of vehicle's bluetooth device, if any.
  int _lastKnownOdometer; // last reported Odo of the vehicle. 
      // If new trip w/ this vehicle has starting odo less than this number, throw error.

  Vehicle(this._name, this._userID, this._vehicleID, this._inUse, this._bluetoothMAC, this._lastKnownOdometer);

  // named constructor "defaultVehicle"
  Vehicle.defaultVehicle() {
    this._name = "Vehicle Name";
    this._userID = "userID";
    this._vehicleID = "vehicleID";
    this._inUse = false;
    this._bluetoothMAC = "00-00-00-00-00-00";
    this._lastKnownOdometer = 0;
    this._vehicleID = "vehicleID";
  }

  // New vehicle constructor
  Vehicle.newVehicle() {
    this._name = " ";
    this._userID = null;
    this._vehicleID = null;
    this._inUse = false;
    this._bluetoothMAC = null;
    this._lastKnownOdometer = 0;
    this._vehicleID = null;
  }

  // Getters
  String get name => _name;
  String get userID => _userID;
  String get vehicleID => _vehicleID;
  bool get inUse => _inUse;
  String get bluetoothMAC => _bluetoothMAC;
  int get lastKnownOdometer => _lastKnownOdometer;

  // Setters

  // Database snapshot getters
  Vehicle.fromSnapshot(DataSnapshot snapshot) :
    _name = snapshot.value['name'],
    _userID = snapshot.value['userID'],
    _inUse = snapshot.value['inUse'],
    _lastKnownOdometer = snapshot.value['lastKnownOdometer'];
    //_vehicleID = snapshot.value['vehicleID'],
    //_bluetoothMAC = snapshot.value['bluetoothMAC'],

  // check if mileage supplied by new trip is less than the last known odometer reading.
  bool checkOdoValid (int newTripOdo) {
    print("Vehicle object is checking if odometer is valid.");
    if (newTripOdo >= _lastKnownOdometer) {
      return true;
    }
    else {
      return false;
    }
  }

}