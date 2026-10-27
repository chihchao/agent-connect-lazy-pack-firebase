#!/usr/bin/env bash
# ============================================================
#  Read-only environment check for the Firebase connect pack.
#  Does NOT install anything, does NOT touch secrets.
#  Prints one line of JSON summarizing what is already done,
#  so AGENTS.md can decide which steps to skip on a re-run.
# ============================================================
set -uo pipefail

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# ---------- node / npx ----------
node_ok=false
node_version=""
if command -v node >/dev/null 2>&1; then
  node_ok=true
  node_version="$(node --version 2>/dev/null || true)"
fi

npx_ok=false
if command -v npx >/dev/null 2>&1; then
  npx_ok=true
fi

# ---------- firebase-tools (via npx, no global install needed) ----------
cli_ok=false
cli_version=""
if $npx_ok; then
  if cli_out="$(npx -y firebase-tools --version 2>/dev/null)"; then
    cli_ok=true
    cli_version="$(printf '%s' "$cli_out" | tail -n1 | tr -d '\r\n')"
  fi
fi

# ---------- login status ----------
login_ok=false
login_email=""
if $cli_ok; then
  login_out="$(npx -y firebase-tools login:list 2>&1 || true)"
  if printf '%s' "$login_out" | grep -q "Logged in as"; then
    login_ok=true
    login_email="$(printf '%s' "$login_out" | grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' | head -n1)"
  fi
fi

# ---------- existing project (resumability) ----------
project_id=""
firebaserc_path="hello/.firebaserc"
if [ -f "$firebaserc_path" ]; then
  value="$(grep -Eo '"default"[[:space:]]*:[[:space:]]*"[^"]*"' "$firebaserc_path" 2>/dev/null | grep -Eo '"[^"]*"$' | tr -d '"')"
  if [ -n "$value" ] && [ "$value" != "CHANGE-ME-hello" ]; then
    project_id="$value"
  fi
fi

# ---------- auth already configured in firebase.json ----------
auth_configured=false
firebase_json_path="hello/firebase.json"
if [ -f "$firebase_json_path" ] && grep -q '"googleSignIn"' "$firebase_json_path" 2>/dev/null; then
  if ! grep -q "CHANGE-ME" "$firebase_json_path" 2>/dev/null; then
    auth_configured=true
  fi
fi

# ---------- web config already written ----------
webconfig_ok=false
webconfig_path="hello/public/firebase-config.js"
if [ -f "$webconfig_path" ] && ! grep -q "CHANGE-ME" "$webconfig_path" 2>/dev/null; then
  webconfig_ok=true
fi

printf '{"node":{"ok":%s,"version":"%s"},"npx":{"ok":%s},"firebase_cli":{"ok":%s,"version":"%s"},"login":{"ok":%s,"email":"%s"},"project":{"id":"%s"},"auth_configured":%s,"webconfig_ok":%s}\n' \
  "$node_ok" "$(json_escape "$node_version")" \
  "$npx_ok" \
  "$cli_ok" "$(json_escape "$cli_version")" \
  "$login_ok" "$(json_escape "$login_email")" \
  "$(json_escape "$project_id")" \
  "$auth_configured" \
  "$webconfig_ok"
