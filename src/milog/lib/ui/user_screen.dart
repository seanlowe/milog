import 'package:flutter/material.dart';
import 'package:milog/model/User.dart';

// Page for viewing and editing user information such as:
// - email
// - password

class UserScreen extends StatefulWidget {

  UserScreen();

  @override
  State<StatefulWidget> createState() => new _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */ 
  // ----------------------------------------

  // add some variables if needed

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("User Page"),),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.topCenter,
        child: ListView(
          children: <Widget>[
            //_showBody(),
            _showLogo(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Email: hello@hello.org            "),
                RaisedButton(
                  child: Text("change"),
                  onPressed: null,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  Text("Password: **********          "),
                  RaisedButton(
                    child: Text("change"),
                    onPressed: null,
                  ),
              ],
            ),
          ],
        )
      ),
    );
  }

  // Widget _showBody() {
  //   return Container(
  //     child: ,
  //   );
  // }

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

} // end of class _UserScreenState
