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
  String q1 = "Add a trip?";
  String q2 = "Update a trip";
  String q3 = "Delete a trip";
  String q4 = "Add a vehicle";
  String q5 = "Delete a vehicle";
  String q6 = "How to delete your account";
  String q7 = "How to print Trip Summary";

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("FAQ"),),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.topCenter,
        child: ListView(
          children: <Widget>[
            _showLogo(),          
          ],
        )
      ),
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

  // ----------------------------------------
  /*              FAQ QUESTIONS            */ 
  // ----------------------------------------

  Widget _showQ1Button() {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
            color: Colors.red[300],
            child: Text('END TRIP',
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: () {
              
            },
          ),
        ));
  }

} // end of class _FAQScreenState
