import 'package:firebase_database/firebase_database.dart';

class Trip{
  String _userID;
  String _tripID; //The trip key
  String _carID;  //The car key
  int _startOdometer; //The start odometer reading
  int _endOdometer; //The end odometer reading
  int _milesTraveled; //The delta miles
  int _startTime;  //The start time of trip
  String _endTime;  //The ending time of the trip
  bool _paused; //If the trip is paused
  String _notes;  //Trip notes (client info etc)
  bool _inProgress; //If the trip is currently in progress
  String _vehicle;  //For now, this will just be a string

  Trip(this._userID, this._tripID, this._carID, this._startOdometer, this._endOdometer, this._milesTraveled,
      this._startTime, this._endTime, this._paused, this._notes, this._inProgress, this._vehicle);

  //Named constructor "defaultTrip"
  Trip.defaultTrip(){
    this._userID = "userID";
    this._tripID = "tripID";
    this._carID = "carID";
    this._notes = "tripNotes";
    this._startTime = 0;
    this._endTime = "endTime";
    this._paused = false;
    this._inProgress = false;
    this._startOdometer = 0;
    this._endOdometer = 0;
    this._milesTraveled = 0;
    this._vehicle = "vehicle";
  }

  //This is a "newTrip" constructor
  Trip.newTrip(){
    this._userID = null;
    this._tripID = null;
    this._carID = null;
    this._notes = " ";
    this._startTime = 0;
    this._endTime = null;
    this._paused = false;
    this._inProgress = false;
    this._startOdometer = 0;
    this._endOdometer = 0;
    this._milesTraveled = 0;
    this._vehicle = " ";
  }

  //Getters
  String get userID => _userID;
  String get tripID => _tripID;
  String get carID => _carID; 
  int get startOdometer => _startOdometer;
  int get endOdometer => _endOdometer;
  String get startTime => null;
  String get endTime => _endTime; 
  bool get paused => _paused;
  String get notes => _notes; 
  bool get inProgress => _inProgress;
  String get vehicle => _vehicle;
  int get milesTraveled => _milesTraveled;

  //Setter for endOdo
  void setEndOdo(int input){
    if(input >=startOdometer){
       _endOdometer = input;
       calculateFinalOdo();
    } 
  }

  /*This is how Snapshot gets values from Firebase
  We need to cast in order to match the datatypes!
  Use Caution!
  */
  Trip.fromSnapshot(DataSnapshot snapshot) :
    _tripID = snapshot.key,
    _userID = snapshot.value["userID"],
    _carID = snapshot.value['carID'],
    _notes = snapshot.value['notes'],
    _startOdometer = snapshot.value['startOdometer'],
    _endOdometer = snapshot.value['endOdometer'],
    _milesTraveled =snapshot.value['milesTraveled'],
    _inProgress = snapshot.value['inProgress'],
    _paused = snapshot.value['paused'],
    _startTime = snapshot.value['startTime'],
    _vehicle = snapshot.value['vehicle'];
  
  toJson() {
    return {
      "tripID":tripID,
      "userID":userID,
      "carID":carID,
      "notes":notes,
      "paused":paused,
      "inProgress":inProgress,
      "startOdometer":startOdometer,
      "endOdometer":endOdometer,
      "milesTraveled":milesTraveled,
      "vehicle":vehicle,
    };
  }

  //Calculates delta Odometer and turns the value
  void calculateFinalOdo(){
    print("Trip object is calculating delta Miles");
    if(_endOdometer >=_startOdometer)
      _milesTraveled = _endOdometer - _startOdometer;
    else
      print("ERROR! -> startOdometer > endOdoter");
  }
}
