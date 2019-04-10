var config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e"
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);

function googleSignIn() {
  var provider = new firebase.auth.GoogleAuthProvider();

  firebase
    .auth()
    .signInWithPopup(provider)
    .then(function(result) {
      // This gives you a Google Access Token. You can use it to access the Google API.
      var token = result.credential.accessToken;
      // The signed-in user info.
      var user = result.user;
      // ...
    })
    .catch(function(error) {
      // Handle Errors here.
      var errorCode = error.code;
      var errorMessage = error.message;
      // The email of the user's account used.
      var email = error.email;
      // The firebase.auth.AuthCredential type that was used.
      var credential = error.credential;
      // ...
    });

  //   firebase.auth().onAuthStateChanged(function(user) {
  //     if (user) {
  //       window.location.href = "home.html";
  //     }
  //   });
}

function handleSignIn() {
  var email = document.getElementById("email").value;
  var password = document.getElementById("password").value;
  // alert("sign in button pressed");
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

  //   firebase.auth().onAuthStateChanged(function(user) {
  //     if (user) {
  //       window.location.href = "home.html";
  //     }
  //   });
}

function handleSignUp() {
  var email = document.getElementById("signup-Email").value;
  var password = document.getElementById("signup-Password").value;
  var verifyPass = document.getElementById("verify-Password").value;
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
  if(password == verifyPass) {
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
  } else {
    throw "Passwords do not match"
  }
  
}

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

function initApp() {
  var user = firebase.auth().currentUser;
  if (user) {
    window.location.href = "home.html";
  }
  // Listening for auth state changes.
  // [START authstatelistener]
  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      // User is signed in.
      window.location.href = "home.html";
    } else {
      // User is signed out.
      // alert("No one is signed in");
    }
  });
  // [END authstatelistener]

  document
    .getElementById("sign-in")
    .addEventListener("click", handleSignIn, false);
  // Triggers submit by clicking Enter
  document
    .getElementById("password")
    .addEventListener("keyup", function(event) {
      // Number 13 is the "Enter" key on the keyboard
      if (event.keyCode === 13) {
          // Cancel the default action, if needed
          event.preventDefault();
          // Trigger the button element with a click
          document.getElementById("sign-in").click();
      }
  });
  document
    .getElementById("verify-Password")
    .addEventListener("keyup", function(event) {
      // Number 13 is the "Enter" key on the keyboard
      if (event.keyCode === 13) {
          // Cancel the default action, if needed
          event.preventDefault();
          // Trigger the button element with a click
          document.getElementById("sign-up").click();
      }
  });
  document
    .getElementById("googleSignIn")
    .addEventListener("click", googleSignIn, false);
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
