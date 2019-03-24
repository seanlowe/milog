
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

function handleSignIn() {
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
      // [END_EXCLUDE]
    });
    // [END authwithemail]
}

function handleSignOut() {
  firebase.auth().signOut();
  window.location.href = "login.html";
}

/**
 * Handles the sign up button press.
 */
function handleSignUp() {
  var email = document.getElementById("signup-Email").value;
  var password = document.getElementById("signup-Password").value;
  if (email.length < 4) {
    alert("Please enter an email address.");
    return;
  }
  if (password.length < 4) {
    alert("Please enter a password.");
    return;
  }
  // Sign up with email and pass.
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
  firebase
    .auth()
    .currentUser.sendEmailVerification()
    .then(function() {
      // Email Verification sent!
      alert("Email Verification Sent!");
    });
}

function sendPasswordReset() {
  var email = document.getElementById("resetEmail").value;
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

    if (user) {
      // User is signed in.
      var email = user.email;
      var emailVerified = user.emailVerified;
      var uid = user.uid;
      if (emailVerified == true){
        window.location.href = "home.html";
        document.getElementById("userEmail").textContent = email;
        alert("Signed in with email: " + email);
      } else {
        window.location.href = "login.html";
        sendEmailVerification();
        alert("Please verify your email");
      }
  
    } else {
      // User is signed out.
    }
  });
  // [END authstatelistener]

  document
    .getElementById("sign-in")
    .addEventListener("click", handleSignIn, false);
  document
    .getElementById("sign-out")
    .addEventListener("click", handleSignOut, false);
  document
    .getElementById("sign-up")
    .addEventListener("click", handleSignUp, false);
  document
    .getElementById("password-reset")
    .addEventListener("click", sendPasswordReset, false);
}


window.onload = function() {
  initApp();
};
