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


exports.getEarthquake = functions.https.onRequest(async (req, res) => {
  // Firebase Firestore reference
  const db = admin.firestore();

  // URL of the public JSON data
  const url = "https://www.safetydata.go.kr/openApi/%EA%B8%B0%EC%83%81%EC%B2%AD_%EC%A7%80%EC%A7%84%ED%86%B5%EB%B3%B4?serviceKey=5ONNDO8QT5CEF2O3&returnType=JSON&pageNum=1&numRowsPerPage=200";

  (async () => {
    await tools.firestore.delete("/earthquake",
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
        const docRef = db.collection("earthquake").doc();

        await docRef.set({
          CD_STN: item.CD_STN,
          DT_REGT: item.DT_REGT,
          LOC_LOC: item.LOC_LOC,
          CORD_LON: item.CORD_LON,
          NO_REF: item.NO_REF,
          NO_ORD: item.NO_ORD,
          CORD_LAT: item.CORD_LAT,
          DT_STFC: item.DT_STFC,
          STAT_OTHER: item.STAT_OTHER,
          SECT_SCLE: item.SECT_SCLE,
          DT_TM_FC: item.DT_TM_FC,
        });
      }

      res.send("Data successfully stored in Firestore!");
    } catch (error) {
      console.error(error);
      res.status(500).send("Failed to fetch data from the public JSON URL");
    }
  })();
});


exports.getWildfire = functions.https.onRequest(async (req, res) => {
  // Firebase Firestore reference
  const db = admin.firestore();

  // URL of the public JSON data
  const url = "https://www.safetydata.go.kr/openApi/%EC%82%B0%EB%A6%BC%EC%B2%AD_%EA%B8%B0%EA%B4%80%EC%9A%A9_%EA%B8%88%EC%9D%BC%EC%82%B0%EB%B6%88%EB%B0%9C%EC%83%9D%ED%98%84%ED%99%A9?serviceKey=4KBL32YA9M0X80XU&returnType=JSON&pageNum=1&numRowsPerPage=200";

  (async () => {
    await tools.firestore.delete("/wildfire",
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
        // If any of the necessary fields are not present in the data, ignore and move to next item.
        if (!item.FRFR_INFO_ID || !item.FRFR_OCCRR_ADDR || !item.LAST_UPDT_DTM || !item.FRFR_FRNG_DTM ||
            !item.FRFR_OCCRR_TPCD || !item.FRST_RGSTN_DTM || !item.FRFR_STTMN_HMS || !item.RNO ||
            !item.FRFR_PRGRS_STCD || !item.FRFR_STTMN_DT || !item.FRFR_STTMN_ADDR ||
            !item.FRFR_LCTN_XCRD || !item.FRFR_LCTN_YCRD) {
          continue;
        }

        // Automatically generate a document identifier.
        const docRef = db.collection("wildfire").doc();

        await docRef.set({
          FRFR_INFO_ID: item.FRFR_INFO_ID,
          FRFR_OCCRR_ADDR: item.FRFR_OCCRR_ADDR,
          LAST_UPDT_DTM: item.LAST_UPDT_DTM,
          FRFR_FRNG_DTM: item.FRFR_FRNG_DTM,
          FRFR_OCCRR_TPCD: item.FRFR_OCCRR_TPCD,
          FRST_RGSTN_DTM: item.FRST_RGSTN_DTM,
          FRFR_STTMN_HMS: item.FRFR_STTMN_HMS,
          RNO: item.RNO,
          FRFR_PRGRS_STCD: item.FRFR_PRGRS_STCD,
          FRFR_STTMN_DT: item.FRFR_STTMN_DT,
          FRFR_STTMN_ADDR: item.FRFR_STTMN_ADDR,
          FRFR_LCTN_XCRD: item.FRFR_LCTN_XCRD,
          FRFR_LCTN_YCRD: item.FRFR_LCTN_YCRD,
        });
      }

      res.send("Data successfully stored in Firestore!");
    } catch (error) {
      console.error(error);
      res.status(500).send("Failed to fetch data from the public JSON URL");
    }
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
