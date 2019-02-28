import 'package:firebase_database/firebase_database.dart';

class Trip{
  String _tripID; //The trip key
  String _carID;  //The car key
  int _startOdometer; //The start odometer reading
  int _endOdometer; //The end odometer reading
  int _milesTravelled; //The delta miles
  String _startTime;  //The start time of trip
  String _endTime;  //The ending time of the trip
  bool _paused; //If the trip is paused
  String _notes;  //Trip notes (client info etc)
  bool _inProgress; //If the trip is currently in progress
  String _vehicle;  //For now, this will just be a string

  Trip(this._tripID, this._carID, this._startOdometer, this._endOdometer,
      this._startTime, this._endTime, this._paused, this._notes, this._inProgress, this._vehicle);

  //Obj's type is explicitly defined so it's dynamic
  Trip.map(dynamic obj) {
    this._tripID = obj['tripID'];
    this._carID = obj['carID'];
    this._notes = obj['notes'];
    this._startTime = obj['startTime'];
    this._endTime = obj['endTime'];
    this._paused = obj['paused'];
    this._inProgress = obj['inProgress'];
    this._startOdometer = obj['startOdometer'];
    this._endOdometer = obj['endOdometer'];
    this._vehicle = obj['vehicle'];
  }

  //Named constructor "defaultTrip"
  Trip.defaultTrip(){
    this._tripID = "tripID";
    this._carID = "carID";
    this._notes = "tripNotes";
    this._startTime = "startTime";
    this._endTime = "endTime";
    this._paused = false;
    this._inProgress = false;
    this._startOdometer = 0;
    this._endOdometer = 0;
    this._vehicle = "vehicle";
  }

  //This is a "newTrip" constructor
  Trip.newTrip(){
    this._tripID = null;
    this._carID = null;
    this._notes = " ";
    this._startTime = null;
    this._endTime = null;
    this._paused = false;
    this._inProgress = false;
    this._startOdometer = 0;
    this._endOdometer = 0;
    this._vehicle = " ";
  }

  //Getters
  String get tripID => _tripID;
  String get carID => _carID; 
  int get startOdometer => _startOdometer;
  int get endOdometer => _endOdometer;
  String get startTime => _startTime;
  String get endTime => _endTime; 
  bool get paused => _paused;
  String get notes => _notes; 
  bool get inProgress => _inProgress;
  String get vehicle => _vehicle;

  /*This is how Snapshot gets values from Firebase
  We need to cast in order to match the datatypes!
  Use Caution!
  */
  Trip.fromSnapshot(DataSnapshot snapshot){
    _tripID = snapshot.key;
    _carID = snapshot.value['carID'];
    _notes = snapshot.value['notes'];
    _startOdometer = int.parse(snapshot.value['startOdometer']);
    _vehicle = snapshot.value['vehicle'];
  }

  void calculateFinalOdo(){
    
  }
}