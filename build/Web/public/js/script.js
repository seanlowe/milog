var config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e"
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);

// Database references
var tripsRef = firebase.database().ref("Trips");
var vehicleRef = firebase.database().ref("Vehicles");
var usersRef = firebase.database().ref("Users");

// function googleSignIn() {
//   var provider = new firebase.auth.GoogleAuthProvider();

//   firebase
//     .auth()
//     .signInWithPopup(provider)
//     .then(function(result) {
//       // This gives you a Google Access Token. You can use it to access the Google API.
//       var token = result.credential.accessToken;
//       // The signed-in user info.
//       var user = result.user;
//       // ...
//     })
//     .catch(function(error) {
//       // Handle Errors here.
//       var errorCode = error.code;
//       var errorMessage = error.message;
//       // The email of the user's account used.
//       var email = error.email;
//       // The firebase.auth.AuthCredential type that was used.
//       var credential = error.credential;
//       // ...
//     });

//   firebase.auth().onAuthStateChanged(function(user) {
//     if (user) {
//       window.location.href = "home.html";
//     }
//   });
// }

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

// function handleSignIn() {
//   var email = document.getElementById("email").value;
//   var password = document.getElementById("password").value;
//   // alert("sign in button pressed");
//   if (email.length < 4) {
//     alert("Please enter an email address.");
//     return;
//   }
//   if (password.length < 4) {
//     alert("Please enter a password.");
//     return;
//   }
//   alert("entered email");
//   // Sign in with email and pass.
//   // [START authwithemail]
//   firebase
//     .auth()
//     .signInWithEmailAndPassword(email, password)
//     .catch(function(error) {
//       // Handle Errors here.
//       var errorCode = error.code;
//       var errorMessage = error.message;
//       // [START_EXCLUDE]
//       if (errorCode === "auth/wrong-password") {
//         alert("Wrong password.");
//       } else {
//         alert(errorMessage);
//       }
//       console.log(error);
//       // [END_EXCLUDE]
//     });
//   // [END authwithemail]

//   firebase.auth().onAuthStateChanged(function(user) {
//     if (user) {
//       window.location.href = "home.html";
//     }
//   });
// }

function handleSignOut() {
  // alert("Logout has been pressed");
  firebase.auth().signOut();
  window.location.href = "login.html";
}

/**
 * Handles the sign up button press.
 */
// function handleSignUp() {
//   var email = document.getElementById("signup-Email").value;
//   var password = document.getElementById("signup-Password").value;
//   if (email.length < 4) {
//     alert("Please enter an email address.");
//     return;
//   }
//   if (password.length < 4) {
//     alert("Please enter a password.");
//     return;
//   }
//   // Sign up with email and pass.
//   // [START createwithemail]
//   firebase
//     .auth()
//     .createUserWithEmailAndPassword(email, password)
//     .catch(function(error) {
//       // Handle Errors here.
//       var errorCode = error.code;
//       var errorMessage = error.message;
//       // [START_EXCLUDE]
//       if (errorCode == "auth/weak-password") {
//         alert("The password is too weak.");
//       } else {
//         alert(errorMessage);
//       }
//       console.log(error);
//       // [END_EXCLUDE]
//     });
//   // [END createwithemail]
// }

// /**
//  * Sends an email verification to the user.
//  */
// function sendEmailVerification() {
//   firebase
//     .auth()
//     .currentUser.sendEmailVerification()
//     .then(function() {
//       // Email Verification sent!
//       alert("Email Verification Sent!");
//     });
// }

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
  var header_count =
    $("#vehicleTable > thead")
      .children("tr")
      .children("th").length - 1;
  console.log(header_count);
}

async function generateTripTable(trips) {
  var dataSets = [];
  for (var i = 0; i < trips.length; i++) {
    let date = new Date(trips[i].startTime);
    // console.log(date.toLocaleDateString());
    dataSets.push([
      date.toLocaleDateString(),
      trips[i].notes,
      trips[i].vehicle,
      trips[i].milesTraveled,
      '<div class="text-center"><a href="home.html#myDeleteModal" data-toggle="modal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></a> <a href="home.html#myUpdateModal" data-toggle="modal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></a></div>'
      
    ]);
  }

  console.log(dataSets);

  /*
   * Initialse DataTables, with no sorting on the 'details' column
   */
  var oTable = $("#hidden-table-info").dataTable({
    aaData: dataSets,
    aoColumnDefs: [
      {
        bSortable: false,
        aTargets: [0]
      }
    ],
    aaSorting: [[1, "asc"]]
  });

  /* Formating function for row details */
  function fnFormatDetails(oTable, nTr) {
    var aData = oTable.fnGetData(nTr);
    var sOut = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">';
    sOut += "<tr><td>Vehicle:</td><td>" + aData[2] + "</td></tr>";
    sOut += "<tr><td>Final Odometer:</td><td> Final Reading </td></tr>";
    sOut += "<tr><td>Fees or Tolls:</td><td>Total Fees</td></tr>";
    sOut += "</table>";

    return sOut;
  }

  $(document).ready(function() {
    /*
     * Insert a 'details' column to the table
     */
    var nCloneTh = document.createElement("th");
    var nCloneTd = document.createElement("td");
    nCloneTh.style.width = "50px";
    nCloneTh.innerHTML = "Details";
    nCloneTd.innerHTML =
      '<img src="lib/advanced-datatable/images/details_open.png">';
    nCloneTd.className = "center";

    $("#hidden-table-info thead tr").each(function() {
      this.insertBefore(nCloneTh, this.childNodes[4]);
    });

    $("#hidden-table-info tbody tr").each(function() {
      this.insertBefore(nCloneTd.cloneNode(true), this.childNodes[4]);
    });

    /* Add event listener for opening and closing details
     * Note that the indicator for showing which row is open is not controlled by DataTables,
     * rather it is done here
     */
    $("#hidden-table-info tbody td img").live("click", function() {
      var nTr = $(this).parents("tr")[0];
      if (oTable.fnIsOpen(nTr)) {
        /* This row is already open - close it */
        this.src = "lib/advanced-datatable/media/images/details_open.png";
        oTable.fnClose(nTr);
      } else {
        /* Open this row */
        this.src = "lib/advanced-datatable/images/details_close.png";
        oTable.fnOpen(nTr, fnFormatDetails(oTable, nTr), "details");
      }
    });

    $("#hidden-table-info tbody td").live("click", function() {
      var nTr = $(this).parents("tr")[0];
    });

  });
}

function getTripData(snapshot, uid) {
  // tripsRef.once("value").then(function(snapshot) {
  var tripArray = [];
  snapshot.forEach(function(childSnapshot) {
    var key = childSnapshot.key;
    var value = childSnapshot.val();

    if (value.userID == uid) {
      tripArray.push(value);

      tripDate = value.startTime;
      tripNotes = value.notes;
      tripVehicle = value.vehicle;
      tripMiles = value.milesTraveled;
      // console.log("Trip array = " + tripArray.notes);
      // Dynamically generating tables from users data
      $("#vehicleTable > tbody").append("<tr></tr>");
      $("#vehicleTable > tbody > tr:last-child").append(
        "<td>" +
          value.startTime +
          "</td><td>" +
          value.notes +
          "</td><td>" +
          value.vehicle +
          '<td class="center">' +
          value.milesTraveled +
          "</td><td class=\"center\"><button class='btn btn-primary btn-xs'><i class='fa fa-pencil'></i></button>\n" +
          "<button class='btn btn-danger btn-xs'><i class='fa fa-trash-o '></i></button> </td>"
      );
    }
  });
  return tripArray;
  // });
}

function createLog() {
  
}

// Delete log
function deleteLog() {

}

function updateLog() {

}

function addVehicle() {

}

function deleteVehicle() {

}

function updateVehicle() {

}

/**
 * initApp handles setting up UI event listeners and registering Firebase auth listeners:
 *  - firebase.auth().onAuthStateChanged: This listener is called when the user is signed in or
 *    out, and that is where we update the UI.
 */
function initApp() {
  // Listening for auth state changes.
  // [START authstatelistener]
  var tripArray = [];
  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      // User is signed in.
      var header_count = $("#vehicleTable > thead")
        .children("tr")
        .children("th").length;
      // console.log(header_count);
      // alert(user.email + " is signed in");
      document.getElementById("userEmail").textContent = user.email;

      var tripArray = [];
      // Get users data
      tripsRef.once("value").then(function(snapshot) {
        tripArray = getTripData(snapshot, user.uid);
        console.log("Trip array = " + tripArray.length);
        generateTripTable(tripArray);
      });
    } else {
      // User is signed out.
      alert("No one is signed in");
      window.location.href = "login.html";
    }
  });
  // [END authstatelistener]

  // document
  //   .getElementById("sign-in")
  //   .addEventListener("click", handleSignIn, false);
  // document
  //   .getElementById("googleSignIn")
  //   .addEventListener("click", googleSignIn, false);
  document
    .getElementById("sign-out")
    .addEventListener("click", handleSignOut, false);
  // document
  //   .getElementById("sign-up")
  //   .addEventListener("click", handleSignUp, false);
  document
    .getElementById("password-reset")
    .addEventListener("click", sendPasswordReset, false);
}

window.onload = function() {
  initApp();
};



// jQuery ready start
$(document).ready(function() {
  // jQuery code




  $("input[data-type='currency']").on({
    keyup: function() {
      formatCurrency($(this));
    },
    blur: function() {
      formatCurrency($(this), "blur");
    }
  });

  function formatNumber(n) {
    // format number 1000000 to 1,234,567
    return n.replace(/\D/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  function formatCurrency(input, blur) {
    // appends $ to value, validates decimal side
    // and puts cursor back in right position.

    // get input value
    var input_val = input.val();

    // don't validate empty input
    if (input_val === "") {
      return;
    }

    // original length
    var original_len = input_val.length;

    // initial caret position
    var caret_pos = input.prop("selectionStart");

    // check for decimal
    if (input_val.indexOf(".") >= 0) {
      // get position of first decimal
      // this prevents multiple decimals from
      // being entered
      var decimal_pos = input_val.indexOf(".");

      // split number by decimal point
      var left_side = input_val.substring(0, decimal_pos);
      var right_side = input_val.substring(decimal_pos);

      // add commas to left side of number
      left_side = formatNumber(left_side);

      // validate right side
      right_side = formatNumber(right_side);

      // On blur make sure 2 numbers after decimal
      if (blur === "blur") {
        right_side += "00";
      }

      // Limit decimal to only 2 digits
      right_side = right_side.substring(0, 2);

      // join number by .
      input_val = "$" + left_side + "." + right_side;
    } else {
      // no decimal entered
      // add commas to number
      // remove all non-digits
      input_val = formatNumber(input_val);
      input_val = "$" + input_val;

      // final formatting
      if (blur === "blur") {
        input_val += ".00";
      }
    }

    // send updated string to input
    input.val(input_val);

    // put caret back in the right position
    var updated_len = input_val.length;
    caret_pos = updated_len - original_len + caret_pos;
    input[0].setSelectionRange(caret_pos, caret_pos);
  }
});
