import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milog/ui/login_signup_page.dart';

void main() {
  //Since this uses a Scaffold, we needs this helper function
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets("Testing Empty Entry", (WidgetTester tester) async {
    LoginSignUpPage login = LoginSignUpPage(
      onSignedIn: () {},
    );
    await tester.pumpWidget(makeTestableWidget(child: login));

    //Test if the widgets exist...
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Create an account"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);

    //Presses the Login button
    await tester.tap(find.text("Login"));
    await tester.pump();
    expect(find.text("Email can't be empty"), findsOneWidget);
    expect(find.text("Password can't be empty"), findsOneWidget);
  });

  testWidgets("Testing Field Entry", (WidgetTester tester) async {
    LoginSignUpPage login = LoginSignUpPage(
      onSignedIn: () {},
    );
    await tester.pumpWidget(makeTestableWidget(child: login));

    //Finds the email textfield and put the email into it
    Finder emailField = find.byKey(Key("Email"));
    await tester.enterText(emailField, "riadshash@gmail.com");
    expect(find.text("riadshash@gmail.com"), findsOneWidget);

    Finder passwordField = find.byKey(Key("Password"));
    await tester.enterText(passwordField, "fghfhgfgh");
    expect(find.text("fghfhgfgh"), findsOneWidget);
  });
}
