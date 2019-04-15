import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  FAQScreen();

  @override
  State<StatefulWidget> createState() => new _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */
  // ----------------------------------------
  String q1 = "Add a trip";
  String q2 = "Update a trip";
  String q3 = "Delete a trip";
  String q4 = "Add a vehicle";
  String q5 = "Delete a vehicle";
  String q6 = "How to delete your account";
  String q7 = "How to print Trip Summary";

  String a1 = "Add Trips by pressing the + button on the bottom of the Trip Logs Screen";
  String a2 = "Click a trip to update its information";
  String a3 = "When a trip is finished, you may delete it by doing a Long Press on the trip.";
  String a4 = "Go to the *Drawer (top left) and select *Vehicles. In there, just like trips, press the + button on the bottom to add a vehicle.";
  String a5 = "Just like for trips, doing a Long Press on the vehicle you wish to remove.";
  String a6 = "You can delete you account on our website: www.milog.org (We will miss you!)";
  String a7 = "Printing your trip summary is done on our website: www.milog.org";

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("FAQ"),
      ),
      body: Container(
          margin: EdgeInsets.all(15.0),
          alignment: Alignment.topCenter,
          child: ListView(
            children: <Widget>[
              _showLogo(),
              _showQButton(q1, a1, _showDialogAns),
              _showQButton(q2, a2, _showDialogAns),
              _showQButton(q3, a3, _showDialogAns),
              _showQButton(q4, a4, _showDialogAns),
              _showQButton(q5, a5, _showDialogAns),
              _showQButton(q6, a6, _showDialogAns), 
              _showQButton(q7, a7, _showDialogAns), 
            ],
          )),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: Image.asset('images/miLog.png'),
        ),
      ),
    );
  }

  void _showDialogAns(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title,
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          content: Text(content,
              style: TextStyle(fontSize: 18.0, color: Colors.black)),
          actions: <Widget>[
            // buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Got it!",
                style: TextStyle(fontSize: 18.0, color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------
  /*              FAQ QUESTIONS            */
  // ----------------------------------------

  Widget _showQButton(String question, String ans, Function showDialog) {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
            color: Colors.grey[300],
            child: Text(question,
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              showDialog(question, ans);
            },
          ),
        ));
  }
} // end of class _FAQScreenState
