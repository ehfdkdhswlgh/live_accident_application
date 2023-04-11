const functions = require("firebase-functions");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});


exports.helloJihwan = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello jihwan!", {structuredData: true});
  response.send("Hello from Firebase!");
});

//firebase deploy --only "functions:함수이름"
