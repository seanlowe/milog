var config = {
    apiKey: process.env.FIREBASE_API_KEY,
    authDomain: process.env.FIREBASE_PROJECT_ID + ".firebaseapp.com",
    databaseURL: "https://" + process.env.FIREBASE_PROJECT_ID + ".firebaseio.com",
    projectId: process.env.FIREBASE_PROJECT_ID,
    //storageBucket: "bucket.appspot.com"
  };
  firebase.initializeApp(config); 