
import 'package:firebase_database/firebase_database.dart';

class Log {
  String _id;
  String _vehicle;
  String _description;

  Log(this._id, this._vehicle, this._description);

  Log.map(dynamic obj) {
    this._id = obj['id'];
    this._vehicle = obj['vehicle'];
    this._description = obj['description'];
  }

  String get id => _id;
  String get vehicle => _vehicle;
  String get description => _description;

  Log.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _vehicle = snapshot.value['vehicle'];
    _description = snapshot.value['description'];
  }
}