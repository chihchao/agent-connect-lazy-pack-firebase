// 這個檔案會在 AGENTS.md 第 4 步,由 Agent 用
//   npx -y firebase-tools apps:sdkconfig WEB <App ID> --project <專案 ID>
// 取得的真實設定值覆蓋掉下面的 CHANGE-ME 佔位值,不需要使用者手動填寫。
//
// 這組設定值本質上是公開的（所有 Firebase 網站的原始碼都看得到），
// 不是密碼，安全性是由 firestore.rules 和登入驗證把關，不是靠隱藏它。
export const firebaseConfig = {
  apiKey: "CHANGE-ME",
  authDomain: "CHANGE-ME.firebaseapp.com",
  projectId: "CHANGE-ME",
  storageBucket: "CHANGE-ME.firebasestorage.app",
  messagingSenderId: "CHANGE-ME",
  appId: "CHANGE-ME",
};
