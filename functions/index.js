const functions = require("firebase-functions");
const cors = require('cors')({origin: true});
const request = require('request');
const converter = require("xml-js");

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


exports.getRSS = functions.https.onRequest((req, response) => {
  cors(req, response, () => {
    request(`https://news.google.com/rss/search?q=%EC%82%AC%EA%B1%B4%EC%82%AC%EA%B3%A0&hl=ko&gl=KR&ceid=KR%3Ako`, function (error, res, body) {
      response.send(res);
    });
  })
});
