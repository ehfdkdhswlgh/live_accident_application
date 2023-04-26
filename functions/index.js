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

exports.rssFeed = functions.pubsub.schedule("0 1 * * *") // 매일 새벽 1시에 업데이트
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

exports.getOpenData = functions.pubsub.schedule("every 1 minutes") // 함수 업데이트 할 때마다 gcp에서 vpc연결 설정해줘야함!
    .timeZone("Asia/Seoul")
    .onRun((context) => {
      const db = admin.firestore();
      (async () => {
        await request(apiURL, (err, response, body) => {
          if (err) throw err;
          parseString(body, (err, result) => {
            if (err) throw err;
            // result는 JSON 객체임 (String 타입이 아님!!!)
            // const jdata = result["response"]["body"]["items"]; // 오류남
            // const jstr = JSON.stringify(result["response"]["body"]);
            // const jdata = JSON.parse(jstr);
            // const items2 = jdata.items; // 오류남 jdata["items"] 도 오류남

            // let category = "err";
            // let fcstValue = "err";

            // ------------------------------------------------- 데이터 불러오기 성공 , 파싱작업만 하면됨---------------------------------------------

            // 시도해볼거 : xml 바로 파싱하는 방법 사용, xml2js 말고 다른거? 사용..
            // json 객체자체는 오류안남.. 문제는 items를 접근하는게 안됨..
            // 정안되면 xml을 바로 파싱하자

            const tem = {
              type: typeof(result),
              json: result,
            };

            db.collection("opendatas").add(tem).then(() => {
              console.log("added order");
            }, (error) => {
              console.error("Failed to add order");
            });

            // for (let k = 0; k < jdata.length; k++) {
            //   category = jdata[k].category;
            //   fcstValue = jdata[k].fcstValue;

            //   const tem = {
            //     category: category,
            //     fcstValue: fcstValue,
            //   };

            //   db.collection("opendatas").add(tem).then(() => {
            //     console.log("added order");
            //   }, (error) => {
            //     console.error("Failed to add order");
            //   });
            // }
          });
        });
      })();
      return null;
    });

// 마지막 줄에 반드시 엔터 ㄱㄱ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
