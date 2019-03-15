const config = {
  apiKey: "AIzaSyB_4KJ05TIv6G6sHUObbV91k2Q3qINw52c",
  authDomain: "mileagelogger-1755e.firebaseapp.com",
  databaseURL: "https://mileagelogger-1755e.firebaseio.com",
  projectId: "mileagelogger-1755e"
  //storageBucket: "bucket.appspot.com"
};
firebase.initializeApp(config);

function handleSignOut() {
  firebase.auth().signOut();
  window.location.href = "login.html";
}

function initApp() {
  firebase.auth().onAuthStateChanged(function(user) {
    document
      .getElementById("sign-out")
      .addEventListener("click", handleSignOut, false);
  });
}

window.onload = function() {
  initApp();
};
