# Agent 連接懶人包(Codex／Antigravity／OpenCode 三平台)— Firebase 版

讓你的 AI Agent 幫你接好 **Firebase**(資料庫＋登入＋網站一次搞定:**Firestore** 放資料、**Authentication** 管登入、**Hosting** 放網頁),最後自動做出一個測試網頁,看到「✅ 連線成功」就完成。

**你不用打任何指令,也不用複製任何金鑰。** 你只負責準備 Google 帳號、在瀏覽器按 Allow;其餘全部由 Agent 執行。三個平台的做法完全一樣。**全程都在 Firebase 免費方案(Spark)完成,不需要信用卡。**

> 這個包**不包含 Cloud Storage**(放照片/檔案用的)。Firebase 自 2024 年底起,Storage 的預設儲存空間一律要求帳號升級到付費方案(Blaze,需綁信用卡,雖然有免費額度),跟這個包「全程免費」的設計不符,所以刻意不碰。之後真的需要上傳檔案,再請 Agent 另外加開,牠會先跟你確認要不要升級付費方案。

---

## 三步驟

```
① 安裝其中一個 Agent  →  ② 用它開啟這個資料夾  →  ③ 說一句話
```

**① 安裝其中一個 Agent(選一個就好)**

| Agent | 下載 | 需要的帳號 |
|---|---|---|
| OpenAI Codex(桌面 App) | https://developers.openai.com/codex | ChatGPT 帳號(可用方案與額度以 OpenAI 公告為準) |
| Google Antigravity 2 | https://antigravity.google | Google 帳號(學校 Workspace 帳號可能被管理員限制,建議用個人帳號) |
| OpenCode(桌面版 2.x) | https://opencode.ai/download | 可先用內建免費模型,不一定要付費帳號 |

**② 取得這個資料夾並用 Agent 開啟**

- 到本 repo 頁面按綠色 **Code → Download ZIP**,解壓縮到桌面。
- 在 Agent 裡選「開啟資料夾／Open Folder」,選剛剛解壓縮的資料夾。

**③ 在對話框輸入這一句**

```text
照 AGENTS.md 幫我連接 Firebase
```

Agent 中途請你重開程式時,回來說:`照 AGENTS.md 繼續`。各平台備用說法見 [`CONNECT_PROMPT.md`](CONNECT_PROMPT.md);OpenCode 也可以直接輸入 `/connect-pack`。

---

## 你只需要做的事(約 10 分鐘)

- [ ] **準備 Google 帳號**:沒有的話在 Agent 打開的網頁申請一個(一般 Gmail 帳號即可,不用額外付費或額外註冊 Firebase)
- [ ] **在內建瀏覽器按 Allow／允許**:Agent 打開 Firebase CLI 的授權頁時,登入後按 **Allow**(只要一次)
- [ ] Windows 跳出「是否允許此 App 變更您的裝置」時按 **是**(只在需要安裝 Node.js 時出現)
- [ ] Agent 請求執行指令或連網的權限時按 **允許**
- [ ] **不用自己想專案名稱**,Agent 會用你的 Email 自動產生(見下方「名稱怎麼來的」)

## 名稱怎麼來的(不用自己想)

Google Cloud 的**專案 ID 是全世界 GCP 帳號共用、一旦用掉就永久保留**(即使之後刪除專案,短時間內也不能重複使用),不是只在你自己帳號內唯一。如果所有老師都取 `wang`、`hello`、`test` 這種簡稱,先建立的人會佔走名字,後面的人建立專案時就會看到 `Project ID ... is already in use` 而失敗。

所以這個包**不問你專案名稱**。Agent 在授權完成後,會執行 `scripts/new-nickname.*`,用你 Gmail 的名稱加上 6 位隨機數字自動產生:

| 你的 Gmail | 產生的暱稱 | 專案 ID | 網址 |
| --- | --- | --- | --- |
| `rwsung180@gmail.com` | `rwsung180-452759` | `rwsung180-452759-hello` | `https://rwsung180-452759-hello.web.app` |
| `john.doe.hr@gmail.com` | `johndoehr-305814` | `johndoehr-305814-hello` | `https://johndoehr-305814-hello.web.app` |

(尾碼每次執行都不同,是隨機的。)

想自己指定名稱也可以,跟 Agent 說「我的專案 ID 要用 `teacher-lin` 開頭」就好,Agent 會用 `-Seed` 參數,仍然會自動補上隨機數字避免撞名。

## Agent 會幫你做的事

1. 檢查電腦環境,缺 Node.js 就幫你安裝
2. 打開 Google 帳號申請頁(沒帳號時)與 Firebase CLI 的授權頁
3. 用你的 Email 自動產生唯一的專案 ID(`<gmail 名稱>-<隨機數字>-hello`)
4. 建立一個 Firebase 專案 + 一個 Web App
5. 開啟 Firestore 資料庫(預設區域:`asia-east1`,彰化)
6. 開通三種登入方式:Email/Password、匿名登入、Google 登入
7. 把測試網站部署到 Firebase Hosting(網址 `https://<專案 ID>.web.app`)
8. 打開網頁按「測試連線」,確認「✅ 連線成功」(匿名登入 + 寫入並讀回 Firestore 都成功)
9. 給你一張「連接完成卡」(平台、網址、專案 ID)

## 瀏覽器原則

- **登入、授權、驗收 → 優先在 Agent 的內建瀏覽器**(Codex 桌面 App 內建瀏覽器、Antigravity 瀏覽器代理、OpenCode 桌面版 2.x 瀏覽器窗格)。每個人版本相同,Agent 也看得到畫面、能一步步帶你。
- 內建瀏覽器的登入狀態和你平常的瀏覽器分開,**請先記好 Google 帳號密碼**,需要在裡面登入一次。
- 內建瀏覽器擋登入或授權一直沒成功時,Agent 會改用你平常的瀏覽器。
- Agent **永遠不會**幫你輸入密碼,也不會讀取你的登入憑證。

## 隱私與安全

- 全程用瀏覽器 OAuth 授權,**不需要也不應該把任何密碼、服務帳戶金鑰或 Token 貼給 Agent**。若 Agent 要你貼,請拒絕。
- 測試網頁裡會看到一組 Firebase 網頁設定(`apiKey` 等)。這組設定**本質上是公開的**(所有 Firebase 網站的原始碼裡都看得到),不是密碼,安全性是由 Firestore 規則與登入驗證把關,不是靠隱藏這組設定。
- 免費方案(Spark)有每日用量上限,研習測試完全用不完。
- 這個包**不會**觸碰 Blaze 付費方案。如果過程中任何步驟突然要求升級付費方案,代表不正常,Agent 會先停下來問你,不會自動升級。
- 授權可以隨時撤銷:請 Agent 執行 `npx firebase-tools logout`;Google 帳號的「第三方應用程式存取權」頁面也可以移除 Firebase CLI 的授權。

## 這個包裡有什麼

| 檔案 | 用途 |
|---|---|
| `AGENTS.md` | **主程序**,三個 Agent 共讀 |
| `CLAUDE.md`、`GEMINI.md` | 一行導向 `AGENTS.md`(給其他 Agent) |
| `CONNECT_PROMPT.md` | 要說的那一句話＋各平台備用說法 |
| `scripts/check.sh`、`scripts/check.ps1` | Agent 執行的唯讀環境檢查(不安裝、不碰秘密) |
| `scripts/new-nickname.sh`、`scripts/new-nickname.ps1` | 從帳號 Email 產生唯一專案 ID(`名稱-隨機數字-hello`),並可檢查名稱合法性 |
| `.opencode/commands/connect-pack.md` | OpenCode 的 `/connect-pack` 指令 |
| `hello/firebase.json` | 專案設定(Agent 會改 Auth 設定,`.firebaserc` 綁定專案 ID) |
| `hello/firestore.rules`、`hello/firestore.indexes.json` | Firestore 安全規則與索引 |
| `hello/public/index.html` | 測試網頁 |
| `hello/public/firebase-config.js` | 網頁用的 Firebase 設定(Agent 部署前會改成真實值) |
| `docs/PLATFORMS.md` | 三平台差異對照 |
| `docs/TROUBLESHOOTING.md` | 卡住時看這裡 |

## 完成後下一步

拿到「✅ 連線成功」之後,你就有一個可以直接串接的 Firebase 後端了:

- 把 `hello/public/firebase-config.js` 裡那組設定值複製到你自己的網頁/App 專案,就能直接用同一個 Firebase 專案的 Firestore 和 Authentication。
- 想要讓使用者上傳圖片/檔案(Storage),跟 Agent 說「幫我加開 Firebase Storage」即可,牠會先跟你確認要不要升級 Blaze 付費方案再動作。
- 想要更進階的後端邏輯(例如寄信、第三方 API),可以再請 Agent 加開 Cloud Functions(一樣需要 Blaze 方案)。
