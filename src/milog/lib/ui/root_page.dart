import 'package:flutter/material.dart';
import 'package:milog/services/authentication.dart';
import 'package:milog/ui/login_signup_page.dart';
import 'package:milog/ui/listview_logs.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  // State is information that 
  // (1) can be read synchronously when the widget is built, and 
  // (2) might change during the lifetime of the widget.

  // This is the state of the RootPage
  State<StatefulWidget> createState() => new _RootPageState();
}

// Authentication Status Flags
enum AuthStatus {
  NOT_DETERMINED, // Don't know if logged in (loading)
  NOT_LOGGED_IN, // Not logged in
  LOGGED_IN, // User is logged in and email is verified
  LOGGED_IN_NOT_VER, // User logged in, but did not verify email
}

class _RootPageState extends State<RootPage> {
  // ----------------------------------------
  /*         VARIABLE DECLARATIONS         */ 
  // ----------------------------------------

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool _isEmailVerified = false;

  // ----------------------------------------
  /* FUNCTION OVERRIDES / CLERICAL FUNCTIONS */
  // ----------------------------------------

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      //WHEN NOT DETERMINED IF USER LOGGED IN
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      //WHEN USER IS NOT LOGGED IN
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      //WHEN THE USER IS LOGGED IN***
      case AuthStatus.LOGGED_IN:
        print("WE'RE LOGGED IN");
        if (_userId.length > 0 && _userId != null) {
          //Return the ListViewLog Widget
          return new ListViewLog(
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        } else
          return _buildWaitingScreen();
        break;
      case AuthStatus.LOGGED_IN_NOT_VER:
        print("WE'RE LOGGED IN BUT NOT VERIFIED");
        //Show the SignUpPage again
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ----------------------------------------
  /*           LOG IN / SIGN OUT           */ 
  // ----------------------------------------

  // Changed this to async (due to the check if verified email... 
  // not sure if this is the right approach)
  // This is done to make sure checkEmailVerification returns
  // Without async, the user has to click twice 
  // (seems that checkEmailVerification takes longer than this thread)
  void _onLoggedIn() async { 
    await _checkEmailVerification();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    if (_isEmailVerified == false) {
      // if user did not* verify email
      setState(() {
        authStatus = AuthStatus.LOGGED_IN_NOT_VER;
        _showVerifyEmailDialog();
      });
    } else {
      // if user did* verify email
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    }
  }

  // Sets state to NOT_LOGGED_IN
  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  // ----------------------------------------
  /*       AUTHENTICATION FUNCTIONS        */ 
  // ----------------------------------------

  // supporting function of _onLoggedIn()
  // Check if the user verfied their email
  void _checkEmailVerification() async {
    // await waits for the function to return
    _isEmailVerified = await widget.auth.isEmailVerified();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // supporting function of _showVerifyEmailDialog()
  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  // supporting function of _resentVerifyEmail()
  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

} // end of class _RootPageState