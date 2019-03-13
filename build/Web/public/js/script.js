// require('dotenv').config()

const status = {
  
}

const config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e",
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config); 


function writeUserData() {
  var database = firebase.database();
  var dat = document.getElementById("data").value;
  firebase
    .database()
    .ref()
    .on("value", function(snapshot) {
      document.getElementById("firebase-status").textContent = JSON.stringify(
        snapshot.val(),
        null,
        2
      );
    });
  firebase
    .database()
    .ref("Users/test")
    .set({
      username: "user",
      email: "user.email",
      data: dat
    });
}

function toggleSignIn() {
  if (firebase.auth().currentUser) {
    // [START signout]
    firebase.auth().signOut();
    // [END signout]
  } else {
    var email = document.getElementById("email").value;
    var password = document.getElementById("password").value;
    if (email.length < 4) {
      alert("Please enter an email address.");
      return;
    }
    if (password.length < 4) {
      alert("Please enter a password.");
      return;
    }
    // Sign in with email and pass.
    // [START authwithemail]
    firebase
      .auth()
      .signInWithEmailAndPassword(email, password)
      .catch(function(error) {
        // Handle Errors here.
        var errorCode = error.code;
        var errorMessage = error.message;
        // [START_EXCLUDE]
        if (errorCode === "auth/wrong-password") {
          alert("Wrong password.");
        } else {
          alert(errorMessage);
        }
        console.log(error);
        document.getElementById("sign-in").disabled = false;
        // [END_EXCLUDE]
      });
    // [END authwithemail]
  }
  document.getElementById("sign-in").disabled = true;
}

/**
 * Handles the sign up button press.
 */
function handleSignUp() {
  var email = document.getElementById("email").value;
  var password = document.getElementById("password").value;
  if (email.length < 4) {
    alert("Please enter an email address.");
    return;
  }
  if (password.length < 4) {
    alert("Please enter a password.");
    return;
  }
  // Sign in with email and pass.
  // [START createwithemail]
  firebase
    .auth()
    .createUserWithEmailAndPassword(email, password)
    .catch(function(error) {
      // Handle Errors here.
      var errorCode = error.code;
      var errorMessage = error.message;
      // [START_EXCLUDE]
      if (errorCode == "auth/weak-password") {
        alert("The password is too weak.");
      } else {
        alert(errorMessage);
      }
      console.log(error);
      // [END_EXCLUDE]
    });
  // [END createwithemail]
  
}

/**
 * Sends an email verification to the user.
 */
function sendEmailVerification() {
  // [START sendemailverification]

  firebase
    .auth()
    .currentUser.sendEmailVerification()
    .then(function() {
      // Email Verification sent!
      // [START_EXCLUDE]
      alert("Email Verification Sent!");
      // [END_EXCLUDE]
    });
  // [END sendemailverification]
}

function sendPasswordReset() {
  var email = document.getElementById("email").value;
  // [START sendpasswordemail]
  firebase
    .auth()
    .sendPasswordResetEmail(email)
    .then(function() {
      // Password Reset Email Sent!
      // [START_EXCLUDE]
      alert("Password Reset Email Sent!");
      // [END_EXCLUDE]
    })
    .catch(function(error) {
      // Handle Errors here.
      var errorCode = error.code;
      var errorMessage = error.message;
      // [START_EXCLUDE]
      if (errorCode == "auth/invalid-email") {
        alert(errorMessage);
      } else if (errorCode == "auth/user-not-found") {
        alert(errorMessage);
      }
      console.log(error);
      // [END_EXCLUDE]
    });
  // [END sendpasswordemail];
}

/**
 * initApp handles setting up UI event listeners and registering Firebase auth listeners:
 *  - firebase.auth().onAuthStateChanged: This listener is called when the user is signed in or
 *    out, and that is where we update the UI.
 */
function initApp() {
  // Listening for auth state changes.
  // [START authstatelistener]
  firebase.auth().onAuthStateChanged(function(user) {
    // [START_EXCLUDE silent]
    document.getElementById("verify-email").disabled = true;
    // [END_EXCLUDE]
    if (user && user.emailVerified == true) {
      // User is signed in.
      // window.location.href = "not-yet.html";
      var email = user.email;
      var emailVerified = user.emailVerified;
      var uid = user.uid;
      // [START_EXCLUDE]
      document.getElementById("sign-in-status").textContent =
        "Signed in";
      document.getElementById("sign-in").textContent = "Sign out";
      document.getElementById(
        "account-details"
      ).textContent = JSON.stringify(user, null, "  ");
      if (!emailVerified) {
        document.getElementById("verify-email").disabled = false;
      }
      // [END_EXCLUDE]
    } else if (user && user.emailVerified == false) {
      alert("Please verify your email");
      document.getElementById("verify-email").disabled = false;
    } else {
      // User is signed out.
      // [START_EXCLUDE]
      document.getElementById("sign-in-status").textContent =
        "Signed out";
      document.getElementById("sign-in").textContent = "Sign in";
      document.getElementById("account-details").textContent =
        "null";
      // [END_EXCLUDE]
    }
    // [START_EXCLUDE silent]
    document.getElementById("sign-in").disabled = false;
    // [END_EXCLUDE]
  });
  // [END authstatelistener]
  document
    .getElementById("sign-in")
    .addEventListener("click", toggleSignIn, false);
  // document
  //   .getElementById("sign-out")
  //   .addEventListener("click", handleSignOut, false);
  document
    .getElementById("sign-up")
    .addEventListener("click", handleSignUp, false);
  document
    .getElementById("verify-email")
    .addEventListener("click", sendEmailVerification, false);
  document
    .getElementById("password-reset")
    .addEventListener("click", sendPasswordReset, false);
}


window.onload = function() {
  initApp();
};
