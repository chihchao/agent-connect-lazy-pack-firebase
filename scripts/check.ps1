# ============================================================
#  Read-only environment check for the Firebase connect pack.
#  Does NOT install anything, does NOT touch secrets.
#  Prints one line of JSON summarizing what is already done,
#  so AGENTS.md can decide which steps to skip on a re-run.
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

# ---------- node / npx ----------
$nodeOk = $false
$nodeVersion = ""
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
  $nodeOk = $true
  $nodeVersion = (node --version) 2>$null
}

$npxOk = $false
$npxCmd = Get-Command npx -ErrorAction SilentlyContinue
if ($npxCmd) { $npxOk = $true }

# ---------- firebase-tools (via npx, no global install needed) ----------
$cliOk = $false
$cliVersion = ""
if ($npxOk) {
  $cliOut = & npx -y firebase-tools --version 2>$null
  if ($LASTEXITCODE -eq 0 -and $cliOut) {
    $cliOk = $true
    $cliVersion = ($cliOut | Select-Object -Last 1).ToString().Trim()
  }
}

# ---------- login status ----------
$loginOk = $false
$loginEmail = ""
if ($cliOk) {
  $loginOut = (& npx -y firebase-tools login:list 2>&1) -join "`n"
  if ($loginOut -match "Logged in as") {
    $loginOk = $true
    $m = [regex]::Match($loginOut, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
    if ($m.Success) { $loginEmail = $m.Value }
  }
}

# ---------- existing project (resumability) ----------
$projectId = ""
$firebasercPath = "hello\.firebaserc"
if (Test-Path $firebasercPath) {
  $content = Get-Content $firebasercPath -Raw
  $m = [regex]::Match($content, '"default"\s*:\s*"([^"]*)"')
  if ($m.Success -and $m.Groups[1].Value -ne "CHANGE-ME-hello") {
    $projectId = $m.Groups[1].Value
  }
}

# ---------- auth already configured in firebase.json ----------
$authConfigured = $false
$firebaseJsonPath = "hello\firebase.json"
if (Test-Path $firebaseJsonPath) {
  $content = Get-Content $firebaseJsonPath -Raw
  if ($content -match '"googleSignIn"' -and $content -notmatch "CHANGE-ME") {
    $authConfigured = $true
  }
}

# ---------- web config already written ----------
$webconfigOk = $false
$webconfigPath = "hello\public\firebase-config.js"
if (Test-Path $webconfigPath) {
  $content = Get-Content $webconfigPath -Raw
  if ($content -notmatch "CHANGE-ME") { $webconfigOk = $true }
}

function BoolStr($b) { if ($b) { "true" } else { "false" } }
function Esc($s) { if ($null -eq $s) { "" } else { $s.Replace('\','\\').Replace('"','\"') } }

$json = '{{"node":{{"ok":{0},"version":"{1}"}},"npx":{{"ok":{2}}},"firebase_cli":{{"ok":{3},"version":"{4}"}},"login":{{"ok":{5},"email":"{6}"}},"project":{{"id":"{7}"}},"auth_configured":{8},"webconfig_ok":{9}}}' -f `
  (BoolStr $nodeOk), (Esc $nodeVersion), `
  (BoolStr $npxOk), `
  (BoolStr $cliOk), (Esc $cliVersion), `
  (BoolStr $loginOk), (Esc $loginEmail), `
  (Esc $projectId), `
  (BoolStr $authConfigured), `
  (BoolStr $webconfigOk)

Write-Output $json
