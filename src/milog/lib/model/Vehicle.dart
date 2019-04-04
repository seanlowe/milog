import 'package:firebase_database/firebase_database.dart';

class Vehicle {
  String _name;
  String _userID;
  String _bluetoothMAC;   // MAC address of vehicle's bluetooth device, if any.
  int _lastKnownOdometer; // last reported Odo of the vehicle. 
      // If new trip w/ this vehicle has starting odo less than this number, throw error.
  String _vehicleID;

  Vehicle(this._name, this._userID, this._bluetoothMAC, this._lastKnownOdometer);

  // named constructor "defaultVehicle"
  Vehicle.defaultVehicle() {
    this._name = "Vehicle Name";
    this._userID = "userID";
    this._bluetoothMAC = "00-00-00-00-00-00";
    this._lastKnownOdometer = 0;
    this._vehicleID = "vehicleID";
  }

  // New vehicle constructor
  Vehicle.newVehicle() {
    this._name = " ";
    this._userID = null;
    this._bluetoothMAC = null;
    this._lastKnownOdometer = null;
    this._vehicleID = null;
  }

  // Getters
  String get name => _name;
  String get userID => _userID;
  String get bluetoothMAC => _bluetoothMAC;
  int get lastKnownOdometer => _lastKnownOdometer;
  String get vehicleID => _vehicleID;

  // Setters

  // Database snapshot getters
  Vehicle.fromSnapshot(DataSnapshot snapshot) :
    _userID = snapshot.value['userID'],
    _name = snapshot.value['name'],
    _bluetoothMAC = snapshot.value['bluetoothMAC'],
    _lastKnownOdometer = snapshot.value['lastKnownOdometer'];

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