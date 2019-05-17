import 'package:flutter/material.dart';
import 'package:milog/services/authentication.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

// Page for viewing and editing user information such as:
// - email
// - password

// page is currently a mock-up

class UserScreen extends StatefulWidget {

  UserScreen(this.auth);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */ 
  // ----------------------------------------
  String userEmail;

  // add some variables if needed

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override void initState(){
    super.initState();
    userEmail = "";
    getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    getUserEmail();
    return new Scaffold(
      appBar: AppBar(title: Text("My Account"),),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.topCenter,
        child: ListView(
          children: <Widget>[
            _showLogo(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Text("Email: " + userEmail,
              textAlign: TextAlign.left,
              style: new TextStyle(
                  fontSize: 22.0, color: Colors.black, wordSpacing: 2)),
                _showChangeEmailButton(),
              ],
            ),
          ],
        )
      ),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 60.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: Image.asset('images/miLog.png'),
        ),
      ),
    );
  }

  Widget _showChangeEmailButton() {
    print("User Pressed Toll Charge Button!");
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(60.0)),
            color: Colors.blueAccent,
            child: Text("Change Email",
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              //Pop up a dialog to change the user's email...
            },
          ),
        ));
  }

  void getUserEmail() async{
    String email = await widget.auth.getUserEmail();
    setState((){
      this.userEmail = email;
    });
  }

} // end of class _UserScreenState
