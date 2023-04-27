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

// firebase deploy --only "functions:함수이름"
// 줄바꿈 2줄이상 금지
// 주석달고 스페이스바 누르고 할말적기
// 고정 IP 할당하기 : https://acver.tistory.com/entry/GCP-Cloud-Functions%EC%97%90-%EA%B3%A0%EC%A0%95-IP-%ED%95%A0%EB%8B%B9%ED%95%98%EA%B8%B0 에서 마지막 코드에서 --router-region=us-central1 추가해줘야함
// 고정 IP : 34.170.151.250 (us-central1)

exports.rssFeed = functions.pubsub.schedule("every 12 hours")
    .timeZone("Asia/Seoul")
    .onRun((context) => {
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
          };
          db.collection("rss").add(tem).then(() => {
            console.log("added order");
          }, (error) => {
            console.error("Failed to add order");
          });
        });
      })();

      return null;
    });

exports.getOpenData = functions.pubsub.schedule("every 12 hours") // 함수 업데이트 할 때마다 gcp에서 vpc연결 설정해줘야함!
    .timeZone("Asia/Seoul")
    .onRun((context) => {
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
              incidenteTypeCd = records[i]["incidenteTypeCd"];
              incidenteSubTypeCd = records[i]["incidenteSubTypeCd"];
              addressJibun = records[i]["addressJibun"];
              locationDataX = records[i]["locationDataX"];
              locationDataY = records[i]["locationDataY"];
              incidentTitle = records[i]["incidentTitle"];
              startDate = records[i]["startDate"];
              endDate = records[i]["endDate"];
              roadName = records[i]["roadName"];

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
      return null;
    });

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
      };
      db.collection("rss").add(tem).then(() => {
        console.log("added order");
      }, (error) => {
        console.error("Failed to add order");
      });
    });
  })();
});

exports.getOpenDataManual = functions.https.onRequest((req, resp) => { // 안에 request랑 이름이 겹쳐서 이름을 다르게 설정해야함
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
          incidenteTypeCd = records[i]["incidenteTypeCd"];
          incidenteSubTypeCd = records[i]["incidenteSubTypeCd"];
          addressJibun = records[i]["addressJibun"];
          locationDataX = records[i]["locationDataX"];
          locationDataY = records[i]["locationDataY"];
          incidentTitle = records[i]["incidentTitle"];
          startDate = records[i]["startDate"];
          endDate = records[i]["endDate"];
          roadName = records[i]["roadName"];

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
