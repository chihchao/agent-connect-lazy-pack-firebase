# CONNECT_PROMPT — 對 Agent 說這一句就好

先用你的 Agent(Codex／Antigravity／OpenCode)**開啟這個資料夾**,再在對話框輸入:

```text
照 AGENTS.md 幫我連接 Firebase
```

Agent 會自己跑所有指令;你只需要準備 Google 帳號、在瀏覽器按 Allow。

**專案名稱不用你想**:Agent 會用你 Gmail 的名稱加 6 位隨機數字自動產生(例如 `rwsung180-452759-hello`),不會撞名。

## 中途重開後

Agent 請你重開程式(或開新對話)時,回來說:

```text
照 AGENTS.md 繼續
```

已完成的步驟會自動跳過。

## 如果 Agent 沒反應過來(備用說法,三平台通用)

```text
請讀這個資料夾的 AGENTS.md,從第 0 步開始照做:用 npx firebase-tools login 連 Firebase(授權網址開在你的內建瀏覽器),建立 Firebase 專案、開啟 Firestore、開通 Auth 登入方式、部署 Hosting 並驗收。所有指令都由你執行。
```

- **Codex 桌面 App**:可再補一句「用你的內建瀏覽器(Ctrl+Shift+B)開網址」。
- **Antigravity 2**:可再補一句「用 browser agent 開網址」。
- **OpenCode 桌面版 2.x**:直接輸入 `/connect-pack`。

## 規則(Agent 已內建,給你安心用)

- 不會叫你貼任何密碼、服務帳戶金鑰或 Token,只在瀏覽器按 Allow。
- 登入、授權優先在 Agent 的內建瀏覽器;卡住才改用你平常的瀏覽器。
- 不會觸碰 Blaze 付費方案;會花錢的動作一定先問你。
