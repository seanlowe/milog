var config = {
    apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
    authDomain: "mileagelogger-1755e.firebaseapp.com",
    databaseURL: "https://mileagelogger-1755e.firebaseio.com",
    projectId: "mileagelogger-1755e"
    //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);

function changeEmail() {
    var user = firebase.auth().currentUser;
    var newEmail = document.getElementById("newEmail").value;
    alert(newEmail);
    user.updateEmail("newEmail").then(function() {
      // Update successful.
      alert("email updated!");
    }).catch(function(error) {
      // An error happened.
    });
}

function sendPasswordReset() {
    // var email = document.getElementById("resetEmail").value;
    var user = firebase.auth().currentUser;
    alert(user.email + " has changed password");
    // [START sendpasswordemail]
    firebase
      .auth()
      .sendPasswordResetEmail(user.email)
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

function handleSignOut() {
    // alert("Logout has been pressed");
    firebase.auth().signOut();
    window.location.href = "login.html";
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

function initApp() {
    // Listening for auth state changes.
    // [START authstatelistener]
    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        // User is signed in.
        document.getElementById("userEmail").textContent = user.email;
  
        // alert(user.email + " is signed in");
      } else {
        // User is signed out.
        alert("No one is signed in");
        window.location.href = "login.html";
      }
    });
    // [END authstatelistener]
  
    document
      .getElementById("changeEmail")
      .addEventListener("click", changeEmail, false);
    document
      .getElementById("resetPassword")
      .addEventListener("click", sendPasswordReset, false);
    document
      .getElementById("sign-out")
      .addEventListener("click", handleSignOut, false);
  }
  
  window.onload = function() {
    initApp();
  };