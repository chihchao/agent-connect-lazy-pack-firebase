# ============================================================
#  Generate a unique Firebase project id (Gmail name + random digits)
#
#  WHY THIS EXISTS
#    A Firebase/Google Cloud project ID is unique across ALL of GCP,
#    not just inside your own account, and once used it stays reserved
#    (even after the project is deleted, it cannot be reused for a
#    while). When many users pick the same short id (wang, hello,
#    test...), the first one to create it grabs it and everyone else
#    fails with:
#      Error: Project ID 'hello' is already in use. Please try a
#      unique Project ID.
#    Appending random digits makes a collision practically impossible.
#
#  USAGE
#    powershell -File scripts\new-nickname.ps1
#    powershell -File scripts\new-nickname.ps1 -Email a.b@gmail.com
#    powershell -File scripts\new-nickname.ps1 -Digits 6
#    powershell -File scripts\new-nickname.ps1 -Seed wang
#    powershell -File scripts\new-nickname.ps1 -Check abc-1234-hello
#
#  OUTPUT: one line of JSON with nickname / projectId / webapp
# ============================================================
param(
  [string]$Email = "",
  [string]$Seed = "",
  [int]$Digits = 6,
  [string]$Check = ""
)

$ErrorActionPreference = "Stop"

function Test-ValidName([string]$name) {
  if ($name -notmatch '^[a-z][a-z0-9-]*[a-z0-9]$') { return $false }
  if ($name.Length -lt 6 -or $name.Length -gt 30) { return $false }
  return $true
}

function Get-InvalidReason([string]$name) {
  if ($name -cmatch '[A-Z]') { return "uppercase letters are not allowed" }
  if ($name -notmatch '^[a-z]') { return "must start with a lowercase letter" }
  if ($name -notmatch '[a-z0-9]$') { return "must end with a lowercase letter or digit" }
  if ($name -notmatch '^[a-z0-9-]+$') { return "only lowercase letters, digits and hyphens are allowed" }
  if ($name.Length -lt 6) { return "shorter than 6 characters" }
  if ($name.Length -gt 30) { return "longer than 30 characters" }
  return "ok"
}

# ---------- validate-only mode ----------
if ($Check -ne "") {
  $valid = Test-ValidName $Check
  $reason = Get-InvalidReason $Check
  $validStr = if ($valid) { "true" } else { "false" }
  Write-Output ('{{"name":"{0}","valid":{1},"length":{2},"reason":"{3}"}}' -f $Check, $validStr, $Check.Length, $reason)
  if ($valid) { exit 0 } else { exit 1 }
}

# ---------- resolve the base string ----------
$source = ""
if ($Seed -ne "") {
  $source = $Seed
} elseif ($Email -ne "") {
  $source = $Email
} else {
  $who = (& npx -y firebase-tools login:list 2>&1) -join "`n"
  $m = [regex]::Match($who, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
  if ($m.Success) {
    $source = $m.Value
  } else {
    [Console]::Error.WriteLine('Could not read an email address from "firebase login:list". Finish login first, or pass -Email.')
    exit 1
  }
}

# ---------- sanitize ----------
# Everything before the "@", lowercased, with every character that is
# not a-z0-9 removed. Capped at 12 characters so the final project id
# ("<base>-<digits>-hello") stays well under the 30-character limit.
$base = $source.Split('@')[0].ToLower()
$base = ($base -replace '[^a-z0-9]', '')
if ($base.Length -gt 12) { $base = $base.Substring(0, 12) }
if ($base -eq "") { $base = "user" }
if ($base -notmatch '^[a-z]') { $base = "u$base" }

# ---------- random suffix ----------
if ($Digits -lt 3 -or $Digits -gt 9) {
  [Console]::Error.WriteLine('Digits must be between 3 and 9.')
  exit 1
}
$suffix = -join ((1..$Digits) | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 })

$nickname = "$base-$suffix"
$projectId = "$nickname-hello"

# ---------- self check: never emit an invalid project id ----------
if (-not (Test-ValidName $projectId)) {
  [Console]::Error.WriteLine("Generated an invalid project id: $projectId (this is a script bug)")
  exit 1
}

Write-Output ('{{"nickname":"{0}","projectId":"{1}","webapp":"{2}-hello-web"}}' -f $nickname, $projectId, $nickname)
