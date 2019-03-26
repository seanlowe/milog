import 'package:firebase_database/firebase_database.dart';

class User {
  String _userID;
  String _userEmail;

  User(this._userID, this._userEmail);

  // default user constructor
  User.defaultUser() {
    this._userID = "user";
    this._userEmail = "email";
  }

  // new user constructor
  User.newUser() {
    this._userID = null;
    this._userEmail = null;
  }

  // Getters
  String get userID => _userID;
  String get userEmail => _userEmail;

  // Setters
  void setEmail(String value) {
    _userEmail = value;
  }

  // database snapshot getters
  User.fromSnapshot(DataSnapshot snapshot) {
    _userID = snapshot.key;
    _userEmail = snapshot.value['userEmail'];
  }

}