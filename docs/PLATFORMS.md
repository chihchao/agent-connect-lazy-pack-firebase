# PLATFORMS — 三平台差異對照

所有指令(`npx firebase-tools ...`)在三個平台上**完全一樣**,唯一的差異是「怎麼打開瀏覽器網址」。

| 項目 | OpenAI Codex(桌面 App) | Google Antigravity 2 | OpenCode(桌面版 2.x) |
|---|---|---|---|
| 代號(AGENTS.md 第 0 步用) | `codex` | `antigravity` | `opencode` |
| 內建瀏覽器 | 有,`Ctrl+Shift+B` 開啟 | 有,browser agent | 有,桌面版 2.x 的瀏覽器窗格 |
| 怎麼開網址 | 用內建的瀏覽器工具開網址 | 用 browser agent 開網址 | 用 `tools.browser.tabs.open` 開網址 |
| 執行終端機指令 | 內建終端機工具 | 內建終端機工具 | 內建終端機工具 |
| 專屬指令 | 無 | 無 | `/connect-pack`(見 `.opencode/commands/connect-pack.md`) |
| CLI／TUI／IDE 擴充版本 | 沒有內建瀏覽器,改用系統瀏覽器 | — | 1.x／TUI 沒有內建瀏覽器,改用系統瀏覽器 |

## 其他 Agent(Claude Code、Gemini CLI 等)

這些沒有「內建瀏覽器」的概念,`AGENTS.md` 裡的代號是 `other`。開網址的方式改用系統瀏覽器:

- Windows:`Start-Process "<網址>"`
- macOS:`open "<網址>"`
- Linux:`xdg-open "<網址>"`

行為跟三平台完全一樣,只是看不到 Agent 操作瀏覽器的過程,使用者需要自己確認瀏覽器裡發生的事(例如看到授權頁按 Allow)。

## 為什麼要用「內建瀏覽器優先」

1. **一致性**:研習現場每個人的系統瀏覽器設定不同(擴充套件、已登入帳號、公司政策),內建瀏覽器每個人都一樣,減少意外。
2. **可視性**:Agent 能讀到內建瀏覽器目前的畫面,可以一步步確認使用者看到什麼、該按哪裡;系統瀏覽器 Agent 看不到,只能靠使用者口述。
3. **隔離性**:內建瀏覽器的登入狀態跟使用者平常的瀏覽器分開,不會互相干擾,也不會不小心把研習用的測試帳號留在使用者的日常瀏覽器裡。

只有在內建瀏覽器卡住(擋登入、授權後一直沒有回呼成功)時才切換到系統瀏覽器,因為那樣會失去上面三個好處,是備援而不是預設。
