#!/bin/bash
# Download Nexconn documentation to local references.
# Usage:
#   bash fetch-docs.sh [--force] [--max-age DAYS] [path]
#   bash fetch-docs.sh --prefetch [set]
#
#   path           remote doc path from llms.txt (e.g. /chatsdk-android.md)
#                  omit to download the llms.txt index itself
#   --force        refresh an existing cached file, ignoring its age
#   --max-age DAYS override the staleness threshold for this run. A cached file
#                  older than DAYS is re-downloaded automatically; DAYS=0 disables
#                  expiry (cache never goes stale). Defaults to 14 days.
#   --prefetch     bulk-fetch a curated set of core docs into ./references/cache.
#                  set defaults to "core". Available sets:
#                      core     ChatUI quickstarts (web/android/ios) + Chat/Call glossaries +
#                               Chat SDK quickstarts for all 4 platforms
#                      ui       ChatUI quickstarts only
#                      sdk      Chat SDK quickstarts only
#                      glossary Chat + Call glossaries only
#
# Caching: a cached file is reused only if it exists AND is younger than the
# max-age threshold. A stale file is re-downloaded; if the network is
# unavailable, the script falls back to the stale copy so offline use still
# works (with a warning).

set -euo pipefail

BASE_URL="https://docs.nexconn.ai"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REFERENCES_DIR="${SCRIPT_DIR}/../references"
CACHE_DIR="${REFERENCES_DIR}/cache"
MAX_RETRIES=3
FORCE=0
# Identify requests as originating from this skill (sent on every curl call).
CURL_HEADERS=(-A "nexconn-chat-skill/1.0.0 (fetch-docs)")
# Cache staleness threshold in days. 0 = never expire (legacy permanent cache).
DEFAULT_MAX_AGE_DAYS=14
MAX_AGE_DAYS="${DEFAULT_MAX_AGE_DAYS}"

# Curated prefetch sets. Edit these lists when official paths change.
PREFETCH_UI=(
  "/chatui-web.md"
  "/chatui-web/quickstart.md"
  "/chatui-android.md"
  "/chatui-ios.md"
)
PREFETCH_SDK=(
  "/chatsdk-web.md"
  "/chatsdk-android.md"
  "/chatsdk-ios.md"
  "/chatsdk-flutter.md"
)
PREFETCH_GLOSSARY=(
  "/guides/glossary/chat-glossary.md"
  "/guides/glossary/call-glossary.md"
)

print_usage() {
  cat >&2 <<'USAGE'
Usage:
  bash fetch-docs.sh [--force] [--max-age DAYS] [path]
  bash fetch-docs.sh [--force] [--max-age DAYS] --prefetch [core|ui|sdk|glossary]

  --force           ignore cache age and re-download
  --max-age DAYS    re-download cached files older than DAYS (0 = never expire)
USAGE
}

print_failure_help() {
  local url="$1"
  cat >&2 <<HELP

------------------------------------------------------------
Failed to download: ${url}

Fallback options:
  1. Open the URL in a browser or call WebFetch on the same URL,
     then save the rendered Markdown manually to:
       ${CACHE_DIR}/<path>
  2. Check whether you are behind a corporate proxy or VPN.
  3. Search the offline index instead:
       rg "<keyword>" "${REFERENCES_DIR}/llms.txt"
     Then read the closest already-cached file under references/cache/.
  4. Re-run with --force after the network is restored.
------------------------------------------------------------
HELP
}

# Echo the modification time of a file as a unix epoch (portable: BSD/macOS + GNU).
file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

# Return 0 if a cached file is fresh enough to reuse, 1 if missing or stale.
# Honors FORCE (always stale) and MAX_AGE_DAYS=0 (never stale).
cache_is_fresh() {
  local output="$1"
  [ "${FORCE}" -eq 0 ] || return 1
  [ -f "${output}" ] || return 1
  [ "${MAX_AGE_DAYS}" -gt 0 ] || return 0

  local now mtime age_secs max_secs
  now="$(date +%s)"
  mtime="$(file_mtime "${output}")"
  # If mtime is unreadable, treat as fresh rather than re-downloading blindly.
  [ -n "${mtime}" ] || return 0
  age_secs=$(( now - mtime ))
  max_secs=$(( MAX_AGE_DAYS * 86400 ))
  [ "${age_secs}" -lt "${max_secs}" ]
}

download_one() {
  local doc_path="$1"
  doc_path="${doc_path#/}"
  if [ -z "${doc_path}" ] || [[ "${doc_path}" == *".."* ]] || [[ "${doc_path}" == /* ]] || [[ "${doc_path}" == *\\* ]]; then
    echo "ERROR: Invalid documentation path: ${1}" >&2
    return 2
  fi
  if [[ "${doc_path}" != "llms.txt" && "${doc_path}" != *.md ]]; then
    echo "ERROR: Documentation path must be llms.txt or a .md file: ${1}" >&2
    return 2
  fi

  local url="${BASE_URL}/${doc_path}"
  local output="${CACHE_DIR}/${doc_path}"
  mkdir -p "$(dirname "${output}")"

  if cache_is_fresh "${output}"; then
    echo "Using cached file: ${output}"
    return 0
  fi
  if [ -f "${output}" ]; then
    echo "Cached file is stale (older than ${MAX_AGE_DAYS}d), refreshing: ${output}"
  fi

  local tmp="${output}.tmp.$$"
  trap 'rm -f "${tmp}"' RETURN

  local i
  for i in $(seq 1 $MAX_RETRIES); do
    echo "Downloading ${url} (attempt ${i}/${MAX_RETRIES}) ..."
    if curl -fSL "${CURL_HEADERS[@]}" --retry 2 --max-time 120 -o "${tmp}" "${url}"; then
      mv "${tmp}" "${output}"
      echo "Saved to ${output}"
      return 0
    fi
    echo "Attempt ${i} failed."
    sleep 2
  done

  rm -f "${tmp}"
  # Network failed. Fall back to a stale cache to preserve offline use.
  if [ -f "${output}" ]; then
    echo "WARNING: download failed; falling back to stale cache: ${output}" >&2
    return 0
  fi
  print_failure_help "${url}"
  return 1
}

download_index() {
  local output="${REFERENCES_DIR}/llms.txt"
  local url="${BASE_URL}/llms.txt"
  if cache_is_fresh "${output}"; then
    echo "Using cached file: ${output}"
    return 0
  fi
  if [ -f "${output}" ]; then
    echo "Cached index is stale (older than ${MAX_AGE_DAYS}d), refreshing: ${output}"
  fi
  local tmp="${output}.tmp.$$"
  trap 'rm -f "${tmp}"' RETURN
  local i
  for i in $(seq 1 $MAX_RETRIES); do
    echo "Downloading ${url} (attempt ${i}/${MAX_RETRIES}) ..."
    if curl -fSL "${CURL_HEADERS[@]}" --retry 2 --max-time 120 -o "${tmp}" "${url}"; then
      mv "${tmp}" "${output}"
      echo "Saved to ${output}"
      return 0
    fi
    echo "Attempt ${i} failed."
    sleep 2
  done
  rm -f "${tmp}"
  # Network failed. Fall back to a stale cache to preserve offline use.
  if [ -f "${output}" ]; then
    echo "WARNING: download failed; falling back to stale cache: ${output}" >&2
    return 0
  fi
  print_failure_help "${url}"
  return 1
}

# Parse leading flags (--force / --max-age can appear with prefetch or a path).
while true; do
  case "${1:-}" in
    --force|-f)
      FORCE=1
      shift
      ;;
    --max-age)
      shift
      if ! [[ "${1:-}" =~ ^[0-9]+$ ]]; then
        echo "ERROR: --max-age requires a non-negative integer (days)." >&2
        print_usage
        exit 2
      fi
      MAX_AGE_DAYS="$1"
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Prefetch mode
if [ "${1:-}" = "--prefetch" ]; then
  shift
  set_name="${1:-core}"
  case "${set_name}" in
    core)
      paths=( "${PREFETCH_UI[@]}" "${PREFETCH_SDK[@]}" "${PREFETCH_GLOSSARY[@]}" )
      ;;
    ui)
      paths=( "${PREFETCH_UI[@]}" )
      ;;
    sdk)
      paths=( "${PREFETCH_SDK[@]}" )
      ;;
    glossary)
      paths=( "${PREFETCH_GLOSSARY[@]}" )
      ;;
    *)
      echo "ERROR: Unknown prefetch set: ${set_name}" >&2
      print_usage
      exit 2
      ;;
  esac

  fail=0
  for p in "${paths[@]}"; do
    if ! download_one "${p}"; then
      fail=$((fail + 1))
    fi
  done
  if [ "${fail}" -gt 0 ]; then
    echo "Prefetch finished with ${fail} failure(s)." >&2
    exit 1
  fi
  echo "Prefetch (${set_name}) finished."
  exit 0
fi

# Single-path mode (or index when no path given).
if [ $# -gt 1 ]; then
  print_usage
  exit 2
fi

if [ $# -eq 0 ]; then
  download_index
  exit $?
fi

download_one "$1"
exit $?
