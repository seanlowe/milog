var config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e"
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);


// Database references
var tripsRef = firebase.database().ref();
var vehicleRef = firebase.database().ref();

// ------------------------------------------------ //
//                 SIGN OUT USER                    //
// ------------------------------------------------ //
function handleSignOut() {
  // alert("Logout has been pressed");
  firebase.auth().signOut();
  window.location.href = "login.html";
}


// ------------------------------------------------ //
//             GENERATE TRIP LOGS TABLE             //
// ------------------------------------------------ //
async function generateTripTable(userId) {
  var trips = [];
  trips = await getTripData(userId);
  var vehicles = [];
  vehicles = await getVehicleData(userId);
  // console.log(trips[0]);
  var dataSets = [];
  var totalMiles = 0;
  var totalCharges = 0
  for (var i = 0; i < trips.length; i++) {
    let date = new Date(trips[i].startTime);
    // console.log("Miles Traveled = " + trips[i].milesTraveled + " Trip charges = " + trips[i].totCharges);
    totalMiles += parseInt(trips[i].milesTraveled);
    totalCharges += parseFloat(trips[i].totCharges);
    // console.log(date.toLocaleDateString());
    // console.log("Miles Travelled = " + trips[i].milesTraveled);
    dataSets.push([
      date.toLocaleDateString(),
      trips[i].notes,
      trips[i].vehicle,
      trips[i].milesTraveled,
      "$" + trips[i].totCharges,
      '<div class="text-center"><button data-toggle="modal" data-target="#myDeleteModal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></button> <button data-toggle="modal" data-target="#myUpdateModal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></button></div>',
      // '<div class="hidden">' + trips[i].startTime + '</div>',
      trips[i].tripKey,
      trips[i].startOdometer,
      trips[i].endOdometer,
      trips[i].startTime
    ]);
  }

  // Sorting the trips array by startTime
  trips.sort(function (a, b) {
      return a.startTime - b.startTime;
    });

  // ------------------------------------------------ //
  //               CREATE PDF OF LOGS                 //
  // ------------------------------------------------ //
  $("#makePDF").on('click', function() {
    // Get Todays Date
    var today = new Date().toLocaleDateString();
  
    // Get and set Date ranges for the array of trips to be printed
    var startDate = document.getElementById('startDate').value;
    var endDate = document.getElementById('endDate').value;
    // console.log("Start Date = " + startDate, "End Date = " + endDate);
    totalMiles = 0;
    totalCharges = 0;
    var rows = [];
    if(startDate == "" && endDate == "") {
      // console.log("To timestamp: " + new Date(startDate).getTime());
      for(var i = 0; i < trips.length; i++) {
        let date = new Date(trips[i].startTime);
        totalMiles += parseInt(trips[i].milesTraveled);
        totalCharges += parseFloat(trips[i].totCharges);
        rows.push([
          date.toLocaleDateString(),
          trips[i].notes,
          trips[i].vehicle,
          trips[i].milesTraveled,
          "$" + trips[i].totCharges
        ]);
        // console.log(rows[i]);
      }
    } else {
      newStartDate = new Date(startDate).getTime();
      newEndDate = new Date(endDate).getTime();
      // console.log("Starting Timestamp: " + newStartDate, "Ending Timestamp: " + newEndDate);
      if(newEndDate > newStartDate) {
        for(var i = 0; i < trips.length; i++) {
          if(trips[i].startTime > newStartDate && trips[i].startTime <= newEndDate + (1000*60*60*24)) {
            let date = new Date(trips[i].startTime);
            totalMiles += parseInt(trips[i].milesTraveled);
            totalCharges += parseFloat(trips[i].totCharges);
            // console.log("Trip " + " Note = " + trips[i].notes);
            rows.push([
              date.toLocaleDateString(),
              trips[i].notes,
              trips[i].vehicle,
              trips[i].milesTraveled,
              "$" + trips[i].totCharges
            ]);
          }
          // console.log(rows[i]);
        }
      } else {
        alert("Final Date cannot be earlier than the Starting Date");
      }
    }

    // init the jsPDF library
    const pdf = new jsPDF();

    // Set the Column Header titles
    var col = [["Log Date", "Notes", "Vehicle", "Miles Travelled", "Fees"]];

    // HEADER
    pdf.setFontSize(20);
    pdf.setTextColor(40);
    pdf.text("MiLog Summary - " + today, 15, 22);
    pdf.setFontSize(12);
    pdf.text("Date Ranges - (" + rows[0][0] + " - " + rows[rows.length-1][0] + ")", 15, 28);
    
    // TABLE
    pdf.setFontSize(14);
    pdf.setTextColor(40);
    pdf.autoTable({
      head: col,
      body: rows,
      margin: {top: 34},
      columnStyles: {
        3: {halign: 'center'}
      }
    });
    pdf.setLineWidth(1);
    pdf.line(15, pdf.autoTable.previous.finalY + 4, pdf.internal.pageSize.width - 15, pdf.autoTable.previous.finalY + 5);

    // FOOTER
    pdf.setFontSize(18);
    pdf.text(15, pdf.autoTable.previous.finalY + 13, "TOTALS ")
    pdf.text(pdf.internal.pageSize.width - 56, pdf.autoTable.previous.finalY + 13, totalMiles.toString());
    pdf.text(pdf.internal.pageSize.width - 33, pdf.autoTable.previous.finalY + 13, "$" + totalCharges.toString());

    // EXPORT - SAVE
    pdf.save('MiLog-Summary-' + today + '.pdf');

    document.getElementById('startDate').value = "";
    document.getElementById('endDate').value = "";

  })


  // console.log("Total miles logged = " + totalMiles);
  // console.log("Total Charges = $" + totalCharges);
  // console.log(dataSets);

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

  // ------------------------------------------------ //
  //          UPDATING AND DELETING TRIP LOG          //
  // ------------------------------------------------ //
  var id;
  var start;
  var final;
  var notes;
  var fees;
  var row;
  var totMiles;
  $('#hidden-table-info tbody').on( 'click', 'tr', function () {
    row = this.rowIndex;
    
    $(this).addClass('selected');
    if ( $(this).hasClass('selected') ) {
      // console.log("Row index  " + row);
      $(this).removeClass('selected');
      var aData = oTable.fnGetData(this);
      id = aData[6];
      console.log("Row " + row + " selected - Vehicle: " + aData[2] + ": Date is: " + aData[0] + " Trip Key = " + aData[6]);
      // start = document.getElementById("updateStartOdo");
      // final = document.getElementById("updateEndOdo");
      totMiles = document.getElementById("updateMiles");
      notes = document.getElementById("updateNotes");
      fees = document.getElementById("updateFees");
      totMiles.value = aData[3];
      // start.value = aData[7];
      // final.value = aData[8];
      notes.value = aData[1];
      fees.placeholder = aData[4];
    }
  });

  // ------------------------------------------------ //
  //        Listener for updating Trip Log            //
  // ------------------------------------------------ //
  $("#updateLog").on('click', function() {
    var updatedFees;
    if(fees.value != "") {
      updatedFees = parseFloat(fees.value);
      tripsRef.child("Trips").child(id).update({
        milesTraveled: totMiles.value,
        notes: notes.value,
        totCharges: updatedFees
      })
      location.reload();
    } else {
      // updatedFees = parseFloat(fees.placeholder);
      tripsRef.child("Trips").child(id).update({
        milesTraveled: totMiles.value,
        notes: notes.value
      })
      location.reload();
    }
    console.log("Trip Key for Updating = " + id + " - Row index = " + row);
    console.log("Total Miles: " + totMiles.value + " / Notes: " + notes.value + " / Fees: " + updatedFees);
    
    // var table = $('#hidden-table-info').DataTable();
    // var temp = table.row(row).data();
    // temp[3] = totMiles.value;
    // temp[1] = notes.value;
    // temp[4] = updatedFees;
    // $('#hidden-table-info').dataTable().fnUpdate(temp,row-1,undefined,false);
  });

  // ------------------------------------------------ //
  //           Listener for deleting log              //
  // ------------------------------------------------ //
  $("#deleteLog").on('click', function() {
    console.log("Row " + row + "Trip Key for Deleting = " + id);
    // var table = $('#hidden-table-info').DataTable();
    // table.row(row-1).remove().draw();
    tripsRef.child("Trips").child(id).remove();
    location.reload();
  });
  


  $(document).ready(function() {
    // ------------------------------------------------ //
    //           Generate Vehicle Drop Down             //
    // ------------------------------------------------ //
    var list = document.getElementById("vehicle-list");
    for(var i = 0; i < vehicles.length; i++) {
      // console.log(vehicles[i]);
      var option = document.createElement('option');
      option.setAttribute("id", i);
      option.value = option.innerHTML = vehicles[i].name;
      list.appendChild(option);
    }    
    // console.log(document.getElementById(1).innerHTML);

    // ------------------------------------------------ //
    //       GET TOTAL MILES TRAVELED FROM USER         //
    // ------------------------------------------------ //
    var totMileage;
    $("#knowMiles").on('click', function() {
      totMileage = document.getElementById('totalMileage').value;
      document.getElementById('showMiles').classList.remove('hidden');
      document.getElementById('totMiles').innerHTML = totMileage;
    })

    // ------------------------------------------------ //
    //    Listener to trigger button click with Enter   //
    // ------------------------------------------------ //
    document
      .getElementById("totalMileage")
      .addEventListener("keyup", function(event) {
        // Number 13 is the "Enter" key on the keyboard
        if (event.keyCode === 13) {
            // Cancel the default action, if needed
            event.preventDefault();
            // Trigger the button element with a click
            document.getElementById("knowMiles").click();
        }
    });

    // ------------------------------------------------ //
    //    Listener to trigger button click with Enter   //
    // ------------------------------------------------ //
    document
      .getElementById("tripNotes")
      .addEventListener("keyup", function(event) {
        // Number 13 is the "Enter" key on the keyboard
        if (event.keyCode === 13) {
            // Cancel the default action, if needed
            event.preventDefault();
            // Trigger the button element with a click
            document.getElementById("createLog").click();
        }
    });

    // ------------------------------------------------ //
    //    RESETTING THE FIELDS IN THE CREAT LOG MODAL   //
    // ------------------------------------------------ //
    $("#cancelCreate").on('click', function() {
      document.getElementById('totalMileage').value = "";
      document.getElementById('initialOdo').value = "";
      document.getElementById('finalOdo').value = "";
      document.getElementById('tripNotes').value = "";
      document.getElementById('tripFees').value = "";
      document.getElementById('showMiles').classList.add('hidden');
    })

    // ------------------------------------------------ //
    //  INITIALIZING THE FIELDS IN THE CREAT LOG MODAL  //
    // ------------------------------------------------ //
    $("#create").on('click', function() {
      document.getElementById('totalMileage').value = "";
      document.getElementById('initialOdo').value = "";
      document.getElementById('finalOdo').value = "";
      document.getElementById('tripNotes').value = "";
      document.getElementById('tripFees').value = "";
      var total = document.getElementById('totalMileage').value;
      console.log("Total Miles " + total);
      document.getElementById('showMiles').classList.add('hidden');
      document.getElementById('initialOdo').readOnly = false;
        document.getElementById('finalOdo').readOnly = false;
    });

    // *************************************************************** //
    //                       CREATE NEW TRIP LOG                       //
    // *************************************************************** //
    $("#createLog").on('click', function() {
      var tripDate = Date.now();
      // console.log(tripDate);
      var tripVehicle;
      var vehicleKey;
      var lastOdo;
      for(var i = 0; i < vehicles.length; i++) {
        if(document.getElementById(i).selected) {
          tripVehicle = document.getElementById(i).innerHTML;
          vehicleKey = vehicles[i].vehicleKey;
          lastOdo = vehicles[i].lastKnownOdometer;
        }
      }

      // ------------------------------------------------ //
      //     MODAL FOR GETTING TOTAL MILES TRAVELLED      //
      // ------------------------------------------------ //
      var totMileage;
      $("#knowMiles").on('click', function() {
        totMileage = document.getElementById('totalMileage').value;
        document.getElementById('showMiles').classList.remove('hidden');
        document.getElementById('totMiles').innerHTML = totMileage;
        document.getElementById('initialOdo').readOnly = true;
        document.getElementById('finalOdo').readOnly = true;
      })

      var totMileage = document.getElementById('totalMileage').value;
      var startMileage = document.getElementById('initialOdo').value;
      var finalMileage = document.getElementById('finalOdo').value;
      var tripNotes = document.getElementById('tripNotes').value;
      var tripFees = document.getElementById('tripFees').value;

      // ------------------------------------------------ //
      // Make sure user enters mileage or odometer readings
      // ------------------------------------------------ //
      if (totMileage == "" && startMileage == "" && finalMileage == "" || tripNotes == ""
          || tripVehicle == "") {
        alert("Must enter required fields");
      } else if (totMileage == "" && startMileage != "" && finalMileage == "") {
        alert("Must enter Final Odometer Reading");
      } else if (totMileage == "" && startMileage == "" && finalMileage != ""){
        alert("Must enter Starting Odometer Reading");
      } else if (totMileage == "" && startMileage != "" && finalMileage != "" && startMileage > finalMileage){
        alert("Final odometer reading must be greater than the Starting odometer reading");
      } else if (totMileage == "" && startMileage != "" && finalMileage != "" && startMileage < lastOdo){
        alert("Starting mileage cannot be less than the Last known Odometer for this vehicle");
      } else {
        var totalMiles;
        var fees;
        if(totMileage != "") {
          totalMiles = totMileage;
        } else if(totMileage == "" && startMileage == "" && finalMileage == "") {
          totalMiles = "ERROR";
        } else {
          totalMiles = finalMileage - startMileage;
          lastOdo = finalMileage;
        }
        totalMiles = parseInt(totalMiles);
        if(tripFees == "") {
          fees = 0;
        } else {
          fees = parseFloat(tripFees);
        }
        console.log("Trip Date = " + tripDate, "Vehicle: " + tripVehicle, "Total Miles: " + totalMiles, " Starting Odometer: " + startMileage, " Final Odometer: " + finalMileage, " Notes: " + tripNotes, " Fees: " + fees);
        console.log("The selected vehicles key is " + vehicleKey);
        tripsRef.child("Trips").push({
          endOdometer: finalMileage,
          endTime: 0,
          inProgress: false,
          milesTraveled: totalMiles,
          notes: tripNotes,
          paused: false,
          startOdometer: startMileage,
          startTime: tripDate,
          totCharges: fees,
          userID: userId,
          vehicle: tripVehicle
        });
        // Adding the data to the database
        vehicleRef.child("Vehicles").child(vehicleKey).update({
          inUse: false,
          lastKnownOdometer: lastOdo,
          name: tripVehicle,
          userID: userId
        });
        location.reload();
        // var table = $('#hidden-table-info').DataTable();
        // table.row.add([
        //   tripDate,
        //   tripNotes,
        //   tripVehicle,
        //   totalMiles,
        //   fees,
        //   '<div class="text-center"><button data-toggle="modal" data-target="#myDeleteModal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></button> <button data-toggle="modal" data-target="#myUpdateModal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></button></div>'
        // ]).draw();

        // ------------------- //
        // RESETTING THE MODAL //
        // ------------------- //
        document.getElementById('totalMileage').value = "";
        document.getElementById('initialOdo').value = "";
        document.getElementById('finalOdo').value = "";
        document.getElementById('tripNotes').value = "";
        document.getElementById('tripFees').value = "";
        document.getElementById('showMiles').classList.add('hidden');
      }

    });

    // tripsRef.on('child_added', function(data) {
    //   // addCommentElement(postElement, data.key, data.val().text, data.val().author);
    //   console.log(tripsRef.child("Trips").key);
    // });
    
    // tripsRef.on('child_changed', function(data) {
    //   // setCommentValues(postElement, data.key, data.val().text, data.val().author);
    //   generateTripTable(userId);
    //   console.log("Trip Updated");
    // });
    
    // tripsRef.on('child_removed', function(data) {
    //   // deleteComment(postElement, data.key);
    //   console.log("Trip Deleted");
    // });

  });
}

// ------------------------------------------------ //
//              GET USERS TRIP DATA                 //
// ------------------------------------------------ //
function getTripData(uid) {
  var tripArray = [];
  var Query = vehicleRef.child("Trips").orderByChild("userID").equalTo(uid);
  Query.once('value').then(function(snapshot) {
    snapshot.forEach(function(childSnapshot) {
      var key = childSnapshot.key;

      var value = childSnapshot.val();
      value.tripKey = key;
      // console.log("New Trip Object = " + obj["vehicle"]);
      
      if (value.userID == uid) {
        tripArray.push(value);
      }
    });
  });
  return new Promise(resolve => {
    setTimeout(() => {
      resolve(tripArray);
    }, 1000);
  });
}

// ------------------------------------------------ //
//              GET USERS VEHICLE DATA              //
// ------------------------------------------------ //
function getVehicleData(uid) {
  var vehicleArray = [];
  var Query = vehicleRef.child("Vehicles").orderByChild("userID").equalTo(uid);
  Query.once('value').then(function(snapshot) {
      snapshot.forEach(function(childSnapshot) {
      var key = childSnapshot.key;
  
      var value = childSnapshot.val();
      //   console.log(value.name);
      value.vehicleKey = key;
      if (value.userID ==  uid) {
          vehicleArray.push(value);
      }
      });
  });
  return new Promise(resolve => {
      setTimeout(() => {
        resolve(vehicleArray);
      }, 1000);
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
    if (user.emailVerified == true) {
      // console.log(user.emailVerified);
      // User is signed in.
      document.getElementById("userEmail").textContent = user.email;

      generateTripTable(user.uid);
      var tripArray = [];
      var vehicleArray = [];

      // alert(user.email + " is signed in");
    } else {
      // User is signed out.
      // alert("No one is signed in");
      window.location.href = "login.html";
    }
  });
  // [END authstatelistener]


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
  var newStart = document.getElementById("updateMiles");
  newStart.addEventListener("keydown", function(e) {
    // prevent: "e", "=", ",", "-", "."
    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
      e.preventDefault();
    }
  })
  // var newFinal = document.getElementById("updateEndOdo");
  // newFinal.addEventListener("keydown", function(e) {
  //   // prevent: "e", "=", ",", "-", "."
  //   if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
  //     e.preventDefault();
  //   }
  // })
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
