const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const RSS = "https://news.google.com/rss/search?q=%EC%82%AC%EA%B1%B4%EC%82%AC%EA%B3%A0&hl=ko&gl=KR&ceid=KR%3Ako";
const Parser = require("rss-parser");
const parser = new Parser();
const tools = require("firebase-tools");
// const cors = require("cors")({origin: true});
const request = require("request");
const parseString = require("xml2js").parseString;
const apiURL = "http://www.utic.go.kr/guide/imsOpenData.do?key=0cAz80l1BdSUmAIVQC7PTwqG64Z8dhcYE5osahGNKR9b74zBRw3borRY4qJocU";
const axios = require("axios");

// firebase deploy --only "functions:함수이름"
// 줄바꿈 2줄이상 금지
// 주석달고 스페이스바 누르고 할말적기
// 고정 IP 할당하기 : https://acver.tistory.com/entry/GCP-Cloud-Functions%EC%97%90-%EA%B3%A0%EC%A0%95-IP-%ED%95%A0%EB%8B%B9%ED%95%98%EA%B8%B0 에서 마지막 코드에서 --router-region=us-central1 추가해줘야함
// 고정 IP : 34.170.151.250 (us-central1)

// Cloud Scheduler 사용함 -> https://console.cloud.google.com/cloudscheduler?hl=ko&project=live-accident
// 최종실행상태가 실패라고 떠있는것은 정상적인 반응임

exports.getNews = functions.https.onRequest(async (req, res) => {
  // Firebase Firestore reference
  const db = admin.firestore();

  // URL of the public JSON data
  const url = "https://www.safetydata.go.kr/openApi/%EC%97%B0%ED%95%A9%EB%89%B4%EC%8A%A4_%EB%8D%B0%EC%9D%B4%ED%84%B0?serviceKey=F57OZ4W53D76E7Z6&returnType=JSON&pageNum=1&numRowsPerPage=200";

  (async () => {
    await tools.firestore.delete("/news",
        {project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
          force: true,
        });

    try {
      const response = await axios.get(url);
      const data = response.data;

      // Storing data into Firestore
      const newsData = data.responseData.data;
      for (const item of newsData) {
        // Automatically generate a document identifier.
        const docRef = db.collection("news").doc();

        await docRef.set({
          DT_REGT: item.DT_REGT,
          YHN_CN: item.YHN_CN,
          YHN_WRTER_NM: item.YHN_WRTER_NM,
          YHN_DATE: item.YHN_DATE,
          YHN_NO: item.YHN_NO,
          YHN_SJ: item.YHN_SJ,
        });
      }

      res.send("Data successfully stored in Firestore!");
    } catch (error) {
      console.error(error);
      res.status(500).send("Failed to fetch data from the public JSON URL");
    }
  })();
});

exports.getSms = functions.https.onRequest(async (req, res) => {
  // Firebase Firestore reference
  const db = admin.firestore();

  // URL of the public JSON data
  const url = "https://www.safetydata.go.kr/openApi/%ED%96%89%EC%A0%95%EC%95%88%EC%A0%84%EB%B6%80_%EA%B8%B4%EA%B8%89%EC%9E%AC%EB%82%9C%EB%AC%B8%EC%9E%90?serviceKey=36Z4ZZJ8A5TA903M&returnType=JSON&pageNum=1&numRowsPerPage=200";

  (async () => {
    await tools.firestore.delete("/sms",
        {project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
          force: true,
        });

    try {
      const response = await axios.get(url);
      const data = response.data;

      // Storing data into Firestore
      const newsData = data.responseData.data;
      for (const item of newsData) {
        // Automatically generate a document identifier.
        const docRef = db.collection("sms").doc();

        await docRef.set({
          DSSTR_SE_NM: item.DSSTR_SE_NM,
          CREAT_DT: item.CREAT_DT,
          RCV_AREA_NM: item.RCV_AREA_NM,
          MD101_SN: item.MD101_SN,
          DSSTR_SE_ID: item.DSSTR_SE_ID,
          RCV_AREA_ID: item.RCV_AREA_ID,
          MSG_SE_CD: item.MSG_SE_CD,
          DELETE_AT: item.DELETE_AT,
          MSG_CN: item.MSG_CN,
          EMRGNCY_STEP_ID: item.EMRGNCY_STEP_ID,
          REGIST_DT: item.REGIST_DT,
          REGISTER_ID: item.REGISTER_ID,
          EMRGNCY_STEP_NM: item.EMRGNCY_STEP_NM,
        });
      }

      res.send("Data successfully stored in Firestore!");
    } catch (error) {
      console.error(error);
      res.status(500).send("Failed to fetch data from the public JSON URL");
    }
  })();
});

exports.getPolice = functions.https.onRequest(async (req, res) => {
  // Firebase Firestore reference
  const db = admin.firestore();

  // URL of the public JSON data
  const url = "https://www.safetydata.go.kr/openApi/%EA%B2%BD%EC%B0%B0%EC%B2%AD_%EA%B5%90%ED%86%B5%EB%8F%8C%EB%B0%9C%EC%83%81%ED%99%A9%EB%B0%9C%EC%83%9D%EC%A0%95%EB%B3%B4?serviceKey=0N6TVD9SUFR5F41S&returnType=JSON&pageNum=1&numRowsPerPage=200";

  (async () => {
    await tools.firestore.delete("/police",
        {project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
          force: true,
        });

    try {
      const response = await axios.get(url);
      const data = response.data;

      // Storing data into Firestore
      const newsData = data.responseData.data;
      for (const item of newsData) {
        // Automatically generate a document identifier.
        const docRef = db.collection("police").doc();

        await docRef.set({
          STD_LINK_ID: item.STD_LINK_ID,
          STATUS: item.STATUS,
          SUCCESS: item.SUCCESS,
          UPDATE_DESC: item.UPDATE_DESC,
          TYPE_OTHER: item.TYPE_OTHER,
          REG_DATE: item.REG_DATE,
          UPDATE_TYPE: item.UPDATE_TYPE,
          SUCCESS_C: item.SUCCESS_C,
          UPDATE_TIME: item.UPDATE_TIME,
          SUCCESS_M: item.SUCCESS_M,
          TYPE_DESC: item.TYPE_DESC,
          STATUS_DESC: item.STATUS_DESC,
        });
      }

      res.send("Data successfully stored in Firestore!");
    } catch (error) {
      console.error(error);
      res.status(500).send("Failed to fetch data from the public JSON URL");
    }
  })();
});

// rss함수도 유동IP사용시 오류가 자주 발생함 -> 고정IP사용할  것
exports.rssFeedManual = functions.https.onRequest((request, response) => {
  const db = admin.firestore();
  (async () => {
    await tools.firestore.delete("/rss",
        {project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
          force: true,
        });

    const feed = await parser.parseURL(RSS);

    feed.items.forEach((item) => {
      const tem = {
        title: item.title,
        link: item.link,
        pubDate: item.pubDate,
      };
      db.collection("rss").add(tem).then(() => {
        console.log("added order");
      }, (error) => {
        console.error("Failed to add order");
      });
    });
  })();
});

// 안에 request랑 이름이 겹쳐서 이름을 다르게 설정해야함
// 업데이트마다 vpc 다시 설정해줘야 함
exports.getOpenDataManual = functions.https.onRequest((req, resp) => {
  const db = admin.firestore();
  (async () => {
    await tools.firestore.delete("/opendatas",
        {project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
          force: true,
        });

    await request(apiURL, (err, response, body) => {
      if (err) throw err;
      parseString(body, (err, result) => {
        if (err) throw err;
        // result는 JSON 객체임 (String 타입이 아님)

        const records = result["result"]["record"];
        const len = Object.keys(records).length;

        let incidenteTypeCd = "NULL";
        let incidenteSubTypeCd = "NULL";
        let addressJibun = "NULL";
        let locationDataX = "NULL";
        let locationDataY = "NULL";
        let incidentTitle = "NULL";
        let startDate = "NULL";
        let endDate = "NULL";
        let roadName = "NULL";

        for (let i = 0; i < len; i++) {
          incidenteTypeCd = records[i]["incidenteTypeCd"][0];
          incidenteSubTypeCd = records[i]["incidenteSubTypeCd"][0];
          addressJibun = records[i]["addressJibun"][0];
          locationDataX = records[i]["locationDataX"][0];
          locationDataY = records[i]["locationDataY"][0];
          incidentTitle = records[i]["incidentTitle"][0];
          startDate = records[i]["startDate"][0];
          endDate = records[i]["endDate"][0];
          roadName = records[i]["roadName"][0];

          const tem = {
            incidenteTypeCd: incidenteTypeCd,
            incidenteSubTypeCd: incidenteSubTypeCd,
            addressJibun: addressJibun,
            locationDataX: locationDataX,
            locationDataY: locationDataY,
            incidentTitle: incidentTitle,
            startDate: startDate,
            endDate: endDate,
            roadName: roadName,
          };

          db.collection("opendatas").add(tem).then(() => {
            console.log("added order");
          }, (error) => {
            console.error("Failed to add order");
          });
        }
      });
    });
  })();
});

// 마지막 줄에 반드시 엔터 ㄱㄱ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
