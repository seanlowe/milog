var config = {
    apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
    authDomain: "mileagelogger-1755e.firebaseapp.com",
    databaseURL: "https://mileagelogger-1755e.firebaseio.com",
    projectId: "mileagelogger-1755e"
    //storageBucket: "bucket.appspot.com"
  };
  firebase.initializeApp(config);
  
  // Database references
  var vehicleRef = firebase.database().ref();

  function handleSignOut() {
    // alert("Logout has been pressed");
    firebase.auth().signOut();
    window.location.href = "login.html";
  }

  // *************************************************************** //
  //                         Get Vehicle Data                        //
  // *************************************************************** //
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
  
  // *************************************************************** //
  //                  Generating the Vehicles Table                  //
  // *************************************************************** //
  async function generateVehicleTable(userId) {
    var vehicles = [];
    vehicles = await getVehicleData(userId);
    var dataSets = [];
    for(var i = 0; i < vehicles.length; i++) {
        console.log(vehicles[i].name);
      dataSets.push([
        vehicles[i].name,
        vehicles[i].lastKnownOdometer,
        '<div class="text-center"><button data-toggle="modal" data-target="#myDeleteModal" id="deleteRow" class="btn btn-danger btn-xs"><i class="fa fa-trash-o "></i></button> <button data-toggle="modal" data-target="#myUpdateModal" id="editRow" class="btn btn-primary btn-xs"><i class="fa fa-pencil"></i></button></div>',
        vehicles[i].vehicleKey
        
      ]);
      
    }
  
    // console.log(dataSets);
  
    for(var i = 0; i < dataSets.length; i++) {
      $("#vehicleTable > tbody").append("<tr></tr>");
        $("#vehicleTable > tbody > tr:last-child").append(
          "<td style='padding-left: 30px'>" +
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
        var id;
        var odo;
        var name;
        var newName;
        $('#vehicleTable tbody tr').on( 'click', function () {
          name = this.cells[0].innerHTML;
          odo = this.cells[1].innerHTML;
          id = this.cells[2].innerHTML;
    
          newName = document.getElementById("newVehicleName");
          newName.placeholder = name;
          var title = document.getElementById("nameTitle");
          title.innerHTML = name;
          var deleteTitle = document.getElementById("nameTitleDelete");
          deleteTitle.innerHTML = name;
          console.log("Row " + this.rowIndex + " has been clicked and the Name is " + name + " and it's ID = " + id);
          // console.log("Name = " + this.cells[0].innerHTML + " Vehicle Id: " + this.cells[3].innerHTML);
          
        });
    
        // *************************************************************** //
        //                       UPDATING VEHICLE
        // *************************************************************** //
        $("#updateVehicle").on('click', function() {
          odo = parseInt(odo);
          newName = document.getElementById("newVehicleName").value;
          console.log(name + " to be Updated to " + newName + ": ID = " + id);
          vehicleRef.child("Vehicles").child(id).update({
              inUse: false,
              lastKnownOdometer: odo,
              name: newName,
              userID: userId
          });
          location.reload();
        });
    
        // *************************************************************** //
        //                         DELETING VEHICLE                        //
        // *************************************************************** //
        $("#deleteVehicle").on('click', function() {
          console.log(name + " with ID = " + id + " was deleted");
          vehicleRef.child("Vehicles").child(id).remove();
          location.reload();
        });
    
        // *************************************************************** //
        //                    ADDING/CREATING A VEHICLE                    //
        // *************************************************************** //
        $("#addVehicle").on('click', function() {
          var vehicleName = document.getElementById("vehicleName").value;
          console.log(vehicleName);
          vehicleRef.child("Vehicles").push({
            inUse: false,
            lastKnownOdometer: 0,
            name: vehicleName,
            userID: userId
          });
          location.reload();
        });
    
      });
  }


  function initApp() {
    // Listening for auth state changes.
    // [START authstatelistener]
    var thisUser;
    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
          thisUser = user.uid;
        // User is signed in.
        document.getElementById("userEmail").textContent = user.email;
  
        generateVehicleTable(user.uid);
  
        // alert(user.email + " is signed in");
      } else {
        // User is signed out.
        // alert("No one is signed in");
        window.location.href = "login.html";
      }
    });

    
    document
      .getElementById("sign-out")
      .addEventListener("click", handleSignOut, false);
  }
  
  window.onload = function() {
    initApp();
  };