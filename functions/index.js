const functions = require("firebase-functions");

// firebase deploy --only "functions:함수이름"
// 줄바꿈 2줄이상 금지
// 주석달고 스페이스바 누르고 할말적기

exports.helloWorld5 = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.helloJihwan = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello jihwan!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.helloJihoon = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello jihwan!", {structuredData: true});
  response.send("Hello from Firebase!");
});
