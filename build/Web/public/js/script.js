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

// function writeUserData() {
//   var database = firebase.database();
//   var dat = document.getElementById("data").value;
//   firebase
//     .database()
//     .ref()
//     .on("value", function(snapshot) {
//       document.getElementById("firebase-status").textContent = JSON.stringify(
//         snapshot.val(),
//         null,
//         2
//       );
//     });
//   firebase
//     .database()
//     .ref("Users/test")
//     .set({
//       username: "user",
//       email: "user.email",
//       data: dat
//     });
// }

function handleSignOut() {
  // alert("Logout has been pressed");
  firebase.auth().signOut();
  window.location.href = "login.html";
}

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




async function generateTripTable(trips) {
  // console.log(trips[0]);
  var dataSets = [];
  var totalMiles = 0;
  var totalCharges = 0
  for (var i = 0; i < trips.length; i++) {
    let date = new Date(trips[i].startTime);
    totalMiles += trips[i].milesTraveled;
    totalCharges += trips[i].totCharges;
    // console.log(date.toLocaleDateString());
    // console.log("Miles Travelled = " + trips[i].milesTraveled);
    dataSets.push([
      date.toLocaleDateString(),
      trips[i].notes,
      trips[i].vehicle,
      trips[i].milesTraveled,
      "$" + trips[i].totCharges,
      '<div class="text-center"><button data-toggle="modal" data-target="#myDeleteModal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></button> <button data-toggle="modal" data-target="#myUpdateModal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></button></div>',
      trips[i].tripKey,
      trips[i].startOdometer,
      trips[i].endOdometer
    ]);
  }

  console.log("Total miles logged = " + totalMiles);
  console.log("Total Charges = $" + totalCharges);
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
    aaSorting: [[0, "desc"]]
  });

  /* Formating function for row details */
  // function fnFormatDetails(oTable, nTr) {
  //   var aData = oTable.fnGetData(nTr);
  //   var sOut = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">';
  //   sOut += "<tr><td>Vehicle:</td><td>" + aData[2] + "</td></tr>";
  //   sOut += "<tr><td>Final Odometer:</td><td>" + aData[8] + "</td></tr>";
  //   sOut += "<tr><td>Fees or Tolls:</td><td>$" + aData[6] + "</td></tr>";
  //   sOut += "</table>";

  //   return sOut;
  // }

  // ------------------------------- //
  // UPDATING AND DELETING TRIP LOG  //
  // ------------------------------- //
  var id
  $('#hidden-table-info tbody').on( 'click', 'tr', function () {
    // oTable.$('tr.selected').addClass('selected');
    var row = this.rowIndex;
    
    $(this).addClass('selected');
    if ( $(this).hasClass('selected') ) {
      // console.log("Row index  " + row);
      $(this).removeClass('selected');
      var aData = oTable.fnGetData(this);
      id = aData[6];
      console.log("Row " + row + " selected - Vehicle: " + aData[2] + ": Date is: " + aData[0] + " Trip Key = " + aData[6]);
      var start = document.getElementById("updateStartOdo");
      var final = document.getElementById("updateEndOdo");
      var notes = document.getElementById("updateNotes");
      var fees = document.getElementById("updateFees");
      start.value = aData[7];
      final.value = aData[8];
      notes.value = aData[1];
      fees.placeholder = aData[4];
    }
    
    // Listener for updating Trip Log
    $("#updateLog").on('click', function() {
      console.log("Trip Key for Updating = " + id);
      console.log("starting Odo = " + start.value + " Final Odo = " + final.value + " Notes = " + notes.value + " Fees = " + fees.value);
      // oTable.$('tr.selected').removeClass('selected');
    });

    // Listener for deleting log
    $("#deleteLog").on('click', function() {
      console.log("Trip Key for Deleting = " + id);
      // oTable.$('tr.selected').removeClass('selected');
      // table.row('.selected').remove().draw( false );
      tripsRef.child(id).remove();
    });

  });
  


  $(document).ready(function() {
  //   /*
  //    * Insert a 'details' column to the table
  //    */
  //   var nCloneTh = document.createElement("th");
  //   var nCloneTd = document.createElement("td");
  //   nCloneTh.style.width = "50px";
  //   nCloneTh.innerHTML = "Details";
  //   nCloneTd.innerHTML =
  //     '<img src="lib/advanced-datatable/images/details_open.png">';
  //   nCloneTd.className = "center";

  //   $("#hidden-table-info thead tr").each(function() {
  //     this.insertBefore(nCloneTh, this.childNodes[4]);
  //   });

  //   $("#hidden-table-info tbody tr").each(function() {
  //     this.insertBefore(nCloneTd.cloneNode(true), this.childNodes[4]);
  //   });

  //   /* Add event listener for opening and closing details
  //    * Note that the indicator for showing which row is open is not controlled by DataTables,
  //    * rather it is done here
  //    */
  //   $("#hidden-table-info tbody td img").live("click", function() {
  //     var nTr = $(this).parents("tr")[0];
  //     if (oTable.fnIsOpen(nTr)) {
  //       /* This row is already open - close it */
  //       this.src = "lib/advanced-datatable/media/images/details_open.png";
  //       oTable.fnClose(nTr);
  //     } else {
  //       /* Open this row */
  //       this.src = "lib/advanced-datatable/images/details_close.png";
  //       oTable.fnOpen(nTr, fnFormatDetails(oTable, nTr), "details");
  //     }
  //   });

  //   $("#hidden-table-info tbody td").live("click", function() {
  //     var nTr = $(this).parents("tr")[0];
  //   });

  });
}

function getTripData(snapshot, uid) {
  var tripArray = [];
  snapshot.forEach(function(childSnapshot) {
    var key = childSnapshot.key;

    var value = childSnapshot.val();
    value.tripKey = key;
    // console.log("New Trip Object = " + obj["vehicle"]);
    
    if (value.userID == uid) {
      tripArray.push(value);
    }
  });
  return tripArray;
}

function getVehicleData(snapshot, uid) {
  var vehicleArray = [];
  snapshot.forEach(function(childSnapshot) {
    var key = childSnapshot.key;

    var value = childSnapshot.val();
    value.vehicleKey = key;
    if (value.userID ==  uid) {
      vehicleArray.push(value);
    }
  });
  return vehicleArray;
}

function generateVehicleTable(vehicles, userId) {
  var dataSets = [];
  for(var i = 0; i < vehicles.length; i++) {
    dataSets.push([
      vehicles[i].name,
      vehicles[i].lastKnownOdometer,
      '<div class="text-center"><button data-toggle="modal" data-target="#myDeleteModal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></button> <button data-toggle="modal" data-target="#myUpdateModal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></button></div>',
      vehicles[i].vehicleKey
      
    ]);
    
  }

  console.log(dataSets);

  for(var i = 0; i < dataSets.length; i++) {
    $("#vehicleTable > tbody").append("<tr></tr>");
      $("#vehicleTable > tbody > tr:last-child").append(
        "<td>" +
          vehicles[i].name +
          '</td><td class="centered">' +
          vehicles[i].lastKnownOdometer +
          "</td><td class=\"centered\"><button class='btn btn-primary btn-xs' data-toggle='modal' data-target='#updateVehicleModal'><i class='fa fa-pencil'></i></button>\n" +
          "<button class='btn btn-danger btn-xs' data-toggle='modal' data-target='#deleteVehicleModal'><i class='fa fa-trash-o '></i></button> </td>" +
          "<td style='display: none'>" + vehicles[i].vehicleKey +  "</td>"
      );
  }

  $(document).ready(function() {
    // ---------------------------------- //
    // SELECTING ROW TO UPDATE OR DELETE  //
    // ---------------------------------- //
    $('#vehicleTable tbody tr').on( 'click', function () {
      var name = this.cells[0].innerHTML;
      var id = this.cells[3].innerHTML;

      var newName = document.getElementById("newVehicleName");
      newName.placeholder = name;
      var title = document.getElementById("nameTitle");
      title.innerHTML = name;
      var deleteTitle = document.getElementById("nameTitleDelete");
      deleteTitle.innerHTML = name;
      console.log("Row " + this.rowIndex + " has been clicked and the Name is " + name);
      // console.log("Name = " + this.cells[0].innerHTML + " Vehicle Id: " + this.cells[3].innerHTML);
      // UPDATING VEHICLE
      $("#updateVehicle").on('click', function() {
        console.log("Vehicle to be Updated: " + name + ": ID = " + id);

      });
      // DELETING VEHICLE
      $("#deleteVehicle").on('click', function() {
        console.log("Vehicle to be Deleted: " + name + ": ID = " + id);
      });
    });

    // --------------------------- //
    // Generate Vehicle Drop Down  //
    // --------------------------- //
    var list = document.getElementById("vehicle-list");
    for(var i = 0; i < vehicles.length; i++) {
      var option = document.createElement('option');
      option.setAttribute("id", i);
      option.value = option.innerHTML = vehicles[i].name;
      list.appendChild(option);
    }    
    // console.log(document.getElementById(1).innerHTML);

    // ------------------ //
    //  CREATE NEW TRIP
    // ------------------ //
    $("#createLog").on('click', function() {
      var tripDate = document.getElementById('tripDate').value;
      var tripVehicle;
      for(var i = 0; i < vehicles.length; i++) {
        if(document.getElementById(i).selected) {
          tripVehicle = document.getElementById(i).innerHTML;
        }
      }
      // var tripVehicle = document.getElementById('vehicle').value;
      var totMileage = document.getElementById('totalMileage').value;
      var startMileage = document.getElementById('initialOdo').value;
      var finalMileage = document.getElementById('finalOdo').value;
      var tripNotes = document.getElementById('tripNotes').value;
      var tripFees = document.getElementById('tripFees').value;

      // Make sure user enters mileage or odometer readings
      if (totMileage == "" && startMileage == "" && finalMileage == "" || tripNotes == ""
          || tripDate == "" || tripVehicle == "") {
        alert("Must enter required fields");
      } else if (totMileage == "" && startMileage != "" && finalMileage == "") {
        alert("Must enter Final Odometer Reading");
      } else if (totMileage == "" && startMileage == "" && finalMileage != ""){
        alert("Must enter Starting Odometer Reading");
      } else if (totMileage == "" && startMileage != "" && finalMileage != "" && startMileage > finalMileage){
        alert("Final odometer reading must be greater than the Starting odometer reading");
      } else {
        var totalMiles;
        var fees;
        if(totMileage != "") {
          totalMiles = totMileage;
          
        } else {
          totalMiles = finalMileage - startMileage;
        }
        totalMiles = parseInt(totalMiles);
        if(tripFees == "") {
          fees = 0;
        } else {
          fees = parseFloat(tripFees);
        }
        tripDate = tripDate.split("-");
        var thisdate = tripDate[0] + "/" + tripDate[1] + "/" + tripDate[2];
        console.log(thisdate);
        var date = new Date(thisdate).getTime();
        console.log("Trip Date = " + date, "Vehicle: " + tripVehicle, "Total Mileage: " + totalMiles, " Starting Odometer: " + startMileage, " Final Odometer: " + finalMileage, " Notes: " + tripNotes, " Fees: " + fees);
        tripsRef.push({
          endOdometer: finalMileage,
          endTime: 0,
          inProgress: false,
          milesTraveled: totalMiles,
          notes: tripNotes,
          paused: false,
          startOdometer: startMileage,
          startTime: date,
          totCharges: fees,
          userID: userId,
          vehicle: tripVehicle
        });
        document.getElementById('tripDate').value = "";
        document.getElementById('totalMileage').value = "";
        document.getElementById('initialOdo').value = "";
        document.getElementById('finalOdo').value = "";
        document.getElementById('tripNotes').value = "";
        document.getElementById('tripFees').value = "";
      }

    });

    $("#addVehicle").on('click', function() {
      var vehicleName = document.getElementById("vehicleName").value;
      console.log(vehicleName);
      // vehicleRef.push({
      //   inUse: false,
      //   lastKnownOdometer: 0,
      //   name: vehicleName,
      //   userID: userID
      // });
    });

    vehicleRef.on('child_added', function(data) {
      // addCommentElement(postElement, data.key, data.val().text, data.val().author);

      console.log("Vehicle added");
    });
    
    vehicleRef.on('child_changed', function(data) {
      // setCommentValues(postElement, data.key, data.val().text, data.val().author);
      console.log("Vehicle Updated");
    });
    
    vehicleRef.on('child_removed', function(data) {
      // deleteComment(postElement, data.key);
      console.log("Vehicle Deleted");
    });

  });
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
      document.getElementById("userEmail").textContent = user.email;

      var tripArray = [];
      // Getting users trip data
      tripsRef.once("value").then(function(snapshot) {
        tripArray = getTripData(snapshot, user.uid);
        console.log("Trip array length = " + tripArray.length);
        generateTripTable(tripArray);
      });

      var vehicleArray = [];
      // Getting users Vehicle Data
      vehicleRef.once("value").then(function(snapshot) {
        vehicleArray = getVehicleData(snapshot, user.uid);
        console.log("Vehicle array length = " + vehicleArray.length)
        generateVehicleTable(vehicleArray, user.uid);
      });

      // alert(user.email + " is signed in");
    } else {
      // User is signed out.
      alert("No one is signed in");
      window.location.href = "login.html";
    }
  });
  // [END authstatelistener]

  // document
  //   .getElementById("changeEmail")
  //   .addEventListener("click", changeEmail, false);
  // document
  //   .getElementById("resetPassword")
  //   .addEventListener("click", changeEmail, false);
  document
    .getElementById("sign-out")
    .addEventListener("click", handleSignOut, false);
}

window.onload = function() {
  initApp();
};



// jQuery ready start
$(document).ready(function() {
  // -------------------------------------------------------- //
  // Preventing the use of "e, -, +, ." for any number inputs //
  // -------------------------------------------------------- //
  var tot = document.getElementById("totalMileage");
  tot.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  var start = document.getElementById("initialOdo");
  start.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  var final = document.getElementById("finalOdo");
  final.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  var newTot = document.getElementById("totalMileage");
  newTot.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  var newStart = document.getElementById("updateStartOdo");
  newStart.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  var newFinal = document.getElementById("updateEndOdo");
  newFinal.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  // ---------------- END OF NUMBER PREVETIONS --------------- //


  // Formatting the currency fields
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
      input_val = left_side + "." + right_side;
    } else {
      // no decimal entered
      // add commas to number
      // remove all non-digits
      input_val = formatNumber(input_val);
      input_val = input_val;

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
