
var config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e",
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);

// Database references
var tripsRef = firebase.database().ref("Trips");
var vehicleRef = firebase.database().ref("Vehicles");
var usersRef = firebase.database().ref("Users");

function googleSignIn() {
  var provider = new firebase.auth.GoogleAuthProvider();

  firebase.auth().signInWithPopup(provider).then(function(result) {
    // This gives you a Google Access Token. You can use it to access the Google API.
    var token = result.credential.accessToken;
    // The signed-in user info.
    var user = result.user;
    // ...
  }).catch(function(error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // The email of the user's account used.
    var email = error.email;
    // The firebase.auth.AuthCredential type that was used.
    var credential = error.credential;
    // ...
  });

  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      window.location.href = "home.html";
    }
  });
}

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
  // alert("sign in button pressed");
  if (email.length < 4) {
    alert("Please enter an email address.");
    return;
  }
  if (password.length < 4) {
    alert("Please enter a password.");
    return;
  }
  alert("entered email");
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
        var warning = document.getElementById('warning-field');
        warning.style.display = 'block';
        warning.innerHTML = 'Wrong Password';
      } else {
        alert(errorMessage);
      }
      console.log(error);
      // [END_EXCLUDE]
    });
    // [END authwithemail]

    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        window.location.href = "home.html";
      }
    });
}

function handleSignOut() {
  // alert("Logout has been pressed");
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

function generateVehicleTable() {
  var header_count = $('#vehicleTable > thead').children('tr').children('th').length-1;
  console.log(header_count);
}

async function generateTripTable(trips) {
  var dataSets = [];
  for (var i = 0; i < trips.length; i++) {
    let date = new Date(trips[i].startTime);
    console.log(date.toLocaleDateString());
    dataSets.push(
      [
        date.toLocaleDateString(),
        trips[i].notes,
        trips[i].vehicle,
        trips[i].milesTraveled,
        0
      ]
    );
  }

  console.log(dataSets);

  /*
   * Initialse DataTables, with no sorting on the 'details' column
   */
  var oTable = $('#hidden-table-info').dataTable({
    "aaData": dataSets,
    "aoColumnDefs": [{
      "bSortable": false,
      "aTargets": [0]
    }],
    "aaSorting": [
      [1, 'asc']
    ]
  });

  /* Formating function for row details */
  function fnFormatDetails(oTable, nTr) {
    var aData = oTable.fnGetData(nTr);
    var sOut = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">';
    sOut += '<tr><td>Rendering engine:</td><td>' + aData[1] + ' ' + aData[4] + '</td></tr>';
    sOut += '<tr><td>Link to source:</td><td>Could provide a link here</td></tr>';
    sOut += '<tr><td>Extra info:</td><td>And any further details here (images etc)</td></tr>';
    sOut += '</table>';

    return sOut;
  }

  $(document).ready(function() {
    /*
     * Insert a 'details' column to the table
     */
    var nCloneTh = document.createElement('th');
    var nCloneTd = document.createElement('td');
    nCloneTd.innerHTML = '<img src="lib/advanced-datatable/images/details_open.png">';
    nCloneTd.className = "center";

    $('#hidden-table-info thead tr').each(function() {
      this.insertBefore(nCloneTh, this.childNodes[0]);
    });

    $('#hidden-table-info tbody tr').each(function() {
      this.insertBefore(nCloneTd.cloneNode(true), this.childNodes[0]);
    });

    // /*
    //  * Initialse DataTables, with no sorting on the 'details' column
    //  */
    // var oTable = $('#hidden-table-info').dataTable({
    //   "aoColumnDefs": [{
    //     "bSortable": false,
    //     "aTargets": [0]
    //   }],
    //   "aaSorting": [
    //     [1, 'asc']
    //   ]
    // });

    /* Add event listener for opening and closing details
     * Note that the indicator for showing which row is open is not controlled by DataTables,
     * rather it is done here
     */
    $('#hidden-table-info tbody td img').live('click', function() {
      var nTr = $(this).parents('tr')[0];
      if (oTable.fnIsOpen(nTr)) {
        /* This row is already open - close it */
        this.src = "lib/advanced-datatable/media/images/details_open.png";
        oTable.fnClose(nTr);
      } else {
        /* Open this row */
        this.src = "lib/advanced-datatable/images/details_close.png";
        oTable.fnOpen(nTr, fnFormatDetails(oTable, nTr), 'details');
      }
    });
  });
}

function getTripData(snapshot, uid) {
  // tripsRef.once("value").then(function(snapshot) {
    var tripArray = [];
    snapshot.forEach(function(childSnapshot) {
      var key = childSnapshot.key;
      var value = childSnapshot.val();

      if(value.userID == uid) {
        tripArray.push(value);
        // console.log(value);
        // console.log(key + ": " + value.notes);
        tripDate = value.startTime;
        tripNotes = value.notes;
        tripVehicle = value.vehicle;
        tripMiles = value.milesTraveled;
        // console.log("Trip array = " + tripArray.notes);
        // Dynamically generating tables from users data
        $('#vehicleTable > tbody').append('<tr></tr>');
        $('#vehicleTable > tbody > tr:last-child').append("<td>" + value.startTime + "</td><td>" +
          value.notes + "</td><td>" + value.vehicle + "<td class=\"center\">" +
          value.milesTraveled + "</td><td class=\"center\"><button class='btn btn-primary btn-xs'><i class='fa fa-pencil'></i></button>\n" +
          "<button class='btn btn-danger btn-xs'><i class='fa fa-trash-o '></i></button> </td>");
      }
    });
    // console.log("Trip array = " + tripArray.length);
    return tripArray;
  // });
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
      var header_count = $('#vehicleTable > thead').children('tr').children('th').length;
      // console.log(header_count);
      // alert(user.email + " is signed in");
      document.getElementById("userEmail").textContent = user.email;

      var tripDate = [];
      var tripNotes = [];
      var tripVehicle = [];
      var tripMiles = [];
      var tripArray = [];
      // generateTripTable(user.uid);
      // Get users data
      tripsRef.once("value").then(function(snapshot) {
        tripArray = getTripData(snapshot, user.uid);
        console.log("Trip array = " + tripArray.length);
        generateTripTable(tripArray);
      });

    } else {
      // User is signed out.
      alert("No one is signed in");

    }
  });
  // [END authstatelistener]

  document
    .getElementById("sign-in")
    .addEventListener("click", handleSignIn, false);
  document
    .getElementById("googleSignIn")
    .addEventListener("click", googleSignIn, false);
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
