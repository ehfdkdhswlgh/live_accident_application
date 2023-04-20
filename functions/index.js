const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const RSS = "https://news.google.com/rss/search?q=%EC%82%AC%EA%B1%B4%EC%82%AC%EA%B3%A0&hl=ko&gl=KR&ceid=KR%3Ako";
const Parser = require("rss-parser");
const parser = new Parser();
const tools = require("firebase-tools");

// firebase deploy --only "functions:함수이름"
// firebase emulators:start --only functions
// 줄바꿈 2줄이상 금지
// 주석달고 스페이스바 누르고 할말적기

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

// 마지막 줄에 반드시 엔터 ㄱㄱ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
