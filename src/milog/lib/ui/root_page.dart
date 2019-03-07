import 'package:flutter/material.dart';
import 'package:milog/ui/login_signup_page.dart';
import 'package:milog/services/authentication.dart';
import 'package:milog/ui/listview_logs.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

//Status flags
enum AuthStatus {
  //Don't know if logged in (loading)
  NOT_DETERMINED,
  //Not logged in
  NOT_LOGGED_IN,
  //User logged in and verfied email
  LOGGED_IN,
  //User logged in, but did not verify email
  LOGGED_IN_NOT_VER,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool _isEmailVerified = false;

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

  //Check if user verfied email
  void _checkEmailVerification() async {
    //await waits for the function to return
    _isEmailVerified = await widget.auth.isEmailVerified();
  }

  /*Changed this to async (due to the check if verified email... not sure if this is the right approach)
  This is done to make sure checkEmailVerification returns
  Without async, the user has to click twice (seems that checkEmailVerification takes longer than this thread)*/
  void _onLoggedIn() async { 
    await _checkEmailVerification();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    if (_isEmailVerified == false) {
      //If user did not* verify email
      setState(() {
        authStatus = AuthStatus.LOGGED_IN_NOT_VER;
        _showVerifyEmailDialog();
      });
    } else {
      //If user did* verify email
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    }
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
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
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

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
}
