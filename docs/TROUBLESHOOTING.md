# TROUBLESHOOTING — 卡住時看這裡

> 這份文件給 Agent 讀,使用者不需要自己照做任何一步;Agent 判斷卡在哪裡後,挑對應的小節處理。

## 1. Node.js 安裝失敗

- Windows 沒有 `winget`:改用系統瀏覽器開 https://nodejs.org/ ,引導使用者下載 LTS 版、一路「下一步」安裝。
- 裝完後 `node`／`npx` 指令找不到:PATH 還沒更新,見 `AGENTS.md` 第 1 步的 PATH 補救指令;仍不行就請使用者重開 Agent App。
- macOS 執行 `brew install node` 失敗:多半是沒裝 Homebrew,改走 nodejs.org 下載安裝檔。

## 2. `firebase login` 卡住或回呼失敗

- 症狀:使用者說已經按了 Allow,但 Agent 這邊的指令一直沒有結束。
- 常見原因:防毒軟體、學校或公司網路擋住 `localhost` 的回呼連線。
- 處理順序:
  1. 中斷目前的 `login` 指令。
  2. 改執行 `npx -y firebase-tools login --no-localhost`,改成「開網址 → 使用者授權拿到一段授權碼 → 讀出授權碼 → 執行 `npx -y firebase-tools login <授權碼>`」的手動流程,完全不需要本機回呼。
  3. 若仍失敗,請使用者改連手機熱點後再試一次原本的 `login` 流程(換一個網路環境,繞過學校/公司的防火牆規則)。
  4. Codex 沙盒詢問網路權限時,提醒使用者按允許。

## 3. 專案 ID 衝突

- 錯誤訊息含 `already in use` 或 `already exists`。
- 先判斷是不是「使用者自己之前已經用這個包跑過一次」:讀 `hello/.firebaserc` 的 `projects.default`,如果不是 `CHANGE-ME-hello`,那個就是舊專案的 ID,直接沿用,不用重建。
- 真的撞到別人名字(機率很低,約百萬分之一):重跑一次 `scripts/new-nickname.*`拿新的 `<專案 ID>`,同步更新 `.firebaserc`,再重跑第 4 步。

## 4. Firestore 建立失敗

- 錯誤提到 API 尚未啟用(例如 `firestore.googleapis.com` is not enabled):等待約 10 秒後重跑同一個 `firestore:databases:create` 指令一次,新專案的 API 啟用有時需要幾秒生效。
- 錯誤提到 location 不合法:執行 `npx -y firebase-tools firestore:locations --project <專案 ID>` 列出合法區域,預設建議用 `asia-east1`。
- 權限錯誤(`PERMISSION_DENIED`):回 `AGENTS.md` 第 3 步重新登入,確認是同一個有建立過這個專案的帳號。

## 5. Google 登入(`googleSignIn`)開通失敗

- 錯誤提到 OAuth brand 或 consent screen 無法自動建立:在內建瀏覽器開
  `https://console.cloud.google.com/apis/credentials/consent?project=<專案 ID>`,
  引導使用者:
  1. 使用者類型選「外部」(External)
  2. 應用程式名稱隨意填(例如 `<暱稱>-hello`)
  3. 使用者支援電子郵件、開發人員聯絡資訊都填使用者自己的 Email
  4. 一路儲存到底,不用額外新增範圍(scopes)或測試使用者
  完成後請使用者說「好了」,重跑 `AGENTS.md` 第 6 步的 `deploy --only auth` 指令即可。
- 這個問題**不影響** `anonymous` 和 `emailPassword` 兩種登入方式(它們不需要 OAuth brand),可以先讓這兩種正常運作,Google 登入晚一點補上也沒關係。

## 6. 部署(`deploy`)失敗

- `Authentication error` 或提到未登入:回第 3 步重新登入。
- 找不到專案別名／`.firebaserc`:確認第 4 步已經把 `<專案 ID>` 寫進 `hello/.firebaserc` 的 `projects.default`。
- 部署完網址打不開:Hosting 網域生效通常在 1 分鐘內,稍後再試;也可以同時試 `https://<專案 ID>.web.app` 和 `https://<專案 ID>.firebaseapp.com` 兩個網址。

## 7. 測試頁顯示錯誤

- 「權限不足／Missing or insufficient permissions」:
  - 最常見原因是 Firestore 規則(`firestore.rules`)還沒部署,或 Auth 的三種登入方式還沒開通成功。
  - 回 `AGENTS.md` 第 6、7 步確認都成功執行過(`deploy --only auth` 以及 `deploy --only firestore,hosting`),再重新整理網頁測試一次。
- 「找不到 Firebase 設定／apiKey 無效」:
  - `hello/public/firebase-config.js` 可能還是 `CHANGE-ME` 佔位值,代表第 4 步第 5 點沒有成功寫入,回頭重做,寫完要記得重新執行第 7 步部署,網頁才會更新。
- 「超過免費額度」:
  - Spark(免費)方案的每日用量在 UTC 0 點(台灣時間早上 8 點)重置,一般研習或教學測試用量遠低於上限,出現這個訊息通常代表誤觸其他問題(例如無限重試造成的迴圈),先確認網頁沒有卡在自動重試。

## 8. 意外被要求升級 Blaze 付費方案

- 本程序設計上全程只用 Spark(免費)方案就能完成 Firestore、Authentication、Hosting 三項服務。
- 如果任何指令的錯誤訊息要求升級到 Blaze(例如提到 billing account、pay-as-you-go),**先停下來,不要自動點任何升級/付款按鈕**,原樣把訊息內容告訴使用者,問他要不要升級(多半是不小心輸入了需要 Blaze 的功能,例如 Cloud Functions 或 Storage,確認使用者真的要那項功能才繼續)。
