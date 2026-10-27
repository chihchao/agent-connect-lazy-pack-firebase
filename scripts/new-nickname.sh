#!/usr/bin/env bash
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
#    bash scripts/new-nickname.sh                    # read Email from firebase login:list
#    bash scripts/new-nickname.sh -e a.b@gmail.com
#    bash scripts/new-nickname.sh -d 6                # digits, default 6
#    bash scripts/new-nickname.sh -s wang              # explicit base
#    bash scripts/new-nickname.sh -c abc-1234-hello     # validate a name only
#
#  OUTPUT: one line of JSON with nickname / projectId / webapp
# ============================================================
set -uo pipefail

EMAIL=""
SEED=""
DIGITS=6
CHECK=""

while [ $# -gt 0 ]; do
  case "$1" in
    -e|--email) EMAIL="${2:-}"; shift 2 ;;
    -s|--seed)  SEED="${2:-}";  shift 2 ;;
    -d|--digits) DIGITS="${2:-}"; shift 2 ;;
    -c|--check) CHECK="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

# Google Cloud project id rules: 6-30 chars, lowercase letters, digits,
# hyphens; must start with a lowercase letter; must end with a letter
# or digit (cannot end with a hyphen).
is_valid_name() {
  printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9-]*[a-z0-9]$' || return 1
  local len="${#1}"
  [ "$len" -ge 6 ] && [ "$len" -le 30 ]
}

invalid_reason() {
  printf '%s' "$1" | grep -q '[A-Z]'  && { echo "uppercase letters are not allowed"; return; }
  printf '%s' "$1" | grep -Eq '^[a-z]' || { echo "must start with a lowercase letter"; return; }
  printf '%s' "$1" | grep -Eq '[a-z0-9]$' || { echo "must end with a lowercase letter or digit"; return; }
  printf '%s' "$1" | grep -Eq '^[a-z0-9-]+$' || { echo "only lowercase letters, digits and hyphens are allowed"; return; }
  [ "${#1}" -lt 6 ] && { echo "shorter than 6 characters"; return; }
  [ "${#1}" -gt 30 ] && { echo "longer than 30 characters"; return; }
  echo "ok"
}

# ---------- validate-only mode ----------
if [ -n "$CHECK" ]; then
  if is_valid_name "$CHECK"; then valid=true; else valid=false; fi
  printf '{"name":"%s","valid":%s,"length":%d,"reason":"%s"}\n' \
    "$CHECK" "$valid" "${#CHECK}" "$(invalid_reason "$CHECK")"
  [ "$valid" = "true" ] && exit 0 || exit 1
fi

# ---------- resolve the base string ----------
if [ -n "$SEED" ]; then
  source="$SEED"
elif [ -z "$EMAIL" ]; then
  who="$(npx -y firebase-tools login:list 2>&1)"
  if printf '%s' "$who" | grep -Eqo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'; then
    EMAIL="$(printf '%s' "$who" | grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' | head -n 1)"
    source="$EMAIL"
  else
    echo 'Could not read an email address from "firebase login:list". Finish login first, or pass -e.' >&2
    exit 1
  fi
else
  source="$EMAIL"
fi

# ---------- sanitize ----------
# Everything before the "@", lowercased, with every character that is
# not a-z0-9 removed (dots, plus signs, underscores all go away).
# The base is capped at 12 characters so that the final project id
# ( "<base>-<digits>-hello", up to 12+1+9+6=28 chars ) stays well under
# the 30-character Google Cloud project id limit.
base="${source%%@*}"
base="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')"
base="${base:0:12}"
[ -z "$base" ] && base="user"
case "$base" in [a-z]*) ;; *) base="u$base" ;; esac

# ---------- random suffix ----------
if [ "$DIGITS" -lt 3 ] || [ "$DIGITS" -gt 9 ]; then
  echo 'Digits must be between 3 and 9.' >&2
  exit 1
fi
if [ -r /dev/urandom ]; then
  suffix="$(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c "$DIGITS")"
else
  suffix=""
  while [ "${#suffix}" -lt "$DIGITS" ]; do
    suffix="$suffix$((RANDOM % 10))"
  done
fi
[ "${#suffix}" -lt "$DIGITS" ] && suffix="${suffix}0$((RANDOM % 9 + 1))"

nickname="$base-$suffix"
projectId="$nickname-hello"

# ---------- self check: never emit an invalid project id ----------
if ! is_valid_name "$projectId"; then
  echo "Generated an invalid project id: $projectId (this is a script bug)" >&2
  exit 1
fi

printf '{"nickname":"%s","projectId":"%s","webapp":"%s-hello-web"}\n' \
  "$nickname" "$projectId" "$nickname"
