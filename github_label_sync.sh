#!/bin/bash

# ---------------------------------------------------------------------
# 🔐 Load environment variables from .env if available
# ---------------------------------------------------------------------
if [ -f ".env" ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# ------------------------------------------------------------------------------
# GitHub Label Sync Tool
# Syncs labels from a CSV file to a GitHub repository using GitHub API.
#
# Example:
#   ./github_label_sync.sh -f labels.csv -r user/repo -d
# ------------------------------------------------------------------------------

# 📌 Show usage instructions and exit
usage() {
  echo ""
  echo "Usage: $0 -f <csv_file> -r <repo> [-d] [-h]"
  echo ""
  echo "  -f   Path to label CSV file (default: labels.csv)"
  echo "  -r   GitHub repository in format user/repo (optional)"
  echo "  -d   Delete existing labels not in CSV (optional)"
  echo "  -h   Show this help message"
  echo ""
  exit 0
}

# 🌱 Default values
CSV_FILE="labels.csv"
REPO=""
DELETE_EXISTING_LABELS=0

# 🔄 Parse command-line arguments
while getopts ":f:r:dh" opt; do
  case ${opt} in
    f)
      CSV_FILE="$OPTARG"
      ;;
    r)
      REPO="$OPTARG"
      ;;
    d)
      DELETE_EXISTING_LABELS=1
      ;;
    h)
      usage
      ;;
    \?)
      echo "⛔ Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "⛔ Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# 🛠 Constants
MAX_DESC_LENGTH=100
HEX_COLOR_PATTERN="^[0-9A-Fa-f]{6}$"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# 📁 Check CSV file existence
echo -n "Validating GitHub labels in file: $CSV_FILE"
if [ ! -f "$CSV_FILE" ]; then
  echo "⛔ Error: File '$CSV_FILE' not found!"
  exit 1
fi

# 📋 Check CSV header
header=$(head -n 1 "$CSV_FILE")
if [ "$header" != "name,color,description" ]; then
  echo "⚠️ Warning: Header should be 'name,color,description'"
fi

# ✅ Validate CSV rows
line_number=0
has_errors=0
LABELS=()

while IFS= read -r line; do
  line_number=$((line_number + 1))
  if [ $line_number -eq 1 ] && [ "$line" = "name,color,description" ]; then
    continue
  fi
  if [ -z "$line" ]; then
    echo "⚠️ Warning: Line $line_number is empty"
    continue
  fi

  field_count=$(echo "$line" | awk -F, '{print NF}')
  if [ "$field_count" -ne 3 ]; then
    echo "⛔ Error: Line $line_number does not have exactly 3 fields (has $field_count)"
    has_errors=1
    continue
  fi

  name=$(echo "$line" | cut -d, -f1)
  color=$(echo "$line" | cut -d, -f2)
  description=$(echo "$line" | cut -d, -f3)

  if [ -z "$name" ]; then
    echo "⛔ Error: Line $line_number has empty name"
    has_errors=1
  fi

  if ! [[ $color =~ $HEX_COLOR_PATTERN ]]; then
    echo "⛔ Error: Line $line_number has invalid color code '$color'"
    has_errors=1
  fi

  desc_length=${#description}
  if [ "$desc_length" -gt "$MAX_DESC_LENGTH" ]; then
    echo "⛔ Error: Line $line_number description for '$name' is too long ($desc_length chars)"
    has_errors=1
  fi

  LABELS+=("$line")

done < "$CSV_FILE"

# 🚫 Exit on validation errors
if [ $has_errors -ne 0 ]; then
  echo "⚠️ Validation failed. Fix errors and try again."
  exit 1
else
  echo " ✅ Validate successfully"
fi

# ---------------------------------------------
# 🔧 GitHub API utility functions
# ---------------------------------------------

label_exists() {
  local label="$1"
  local encoded
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$label'''))")
  status=$(curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME/labels/$encoded")
  [ "$status" = "200" ]
}

label_create() {
  curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    --request POST \
    --data "{\"name\":\"$1\",\"color\":\"$2\", \"description\":\"$3\"}" \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME/labels"
}

label_update() {
  local label="$1"
  local encoded
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$label'''))")
  curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    --request PATCH \
    --data "{\"name\":\"$1\",\"color\":\"$2\", \"description\":\"$3\"}" \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME/labels/$encoded"
}

label_delete() {
  local label="$1"
  local encoded
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$label'''))")
  curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    --request DELETE \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME/labels/$encoded"
}

user_has_access() {
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME")
  [ "$code" = "200" ]
}

get_all_labels() {
  curl -s -u "$GITHUB_TOKEN":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    "https://api.github.com/repos/$REPO_USER/$REPO_NAME/labels?per_page=100" |
    grep '"name":' |
    sed -E 's/.*"name": "(.*)",?/\1/' |
    while read -r label; do
      printf '"%s"\n' "$label"
    done
}

# 🚀 Main logic
main() {
  echo
  echo "🚀 Starting GitHub label sync..."
  echo

  # 🧾 Prompt for repo or token if missing
  if [ -z "$REPO" ]; then
    read -rp "GitHub Org/Repo (e.g. user/repo): " REPO
  fi

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️ GITHUB_TOKEN not found in environment or .env file."
    read -rsp "🔐 Enter your GitHub Token: " GITHUB_TOKEN
    echo
  fi

  # 🧩 Split user/repo
  REPO_USER=$(cut -d/ -f1 <<<"$REPO")
  REPO_NAME=$(cut -d/ -f2 <<<"$REPO")

  # ✅ Validate repo access
  if ! user_has_access; then
    echo "⛔ Error: Invalid credentials or repo '$REPO'"
    exit 1
  fi

  # 🧹 Delete labels not in CSV
  if [ "$DELETE_EXISTING_LABELS" == "1" ]; then
    echo "🧹 Fetching and removing existing labels not in CSV..."
    
    # Read quoted labels as array (preserving spaces)
    readarray -t current_labels < <(get_all_labels)

    echo
    echo "Existing labels: ${current_labels[*]}"
    echo

    for label in "${current_labels[@]}"; do
      match=0
      for entry in "${LABELS[@]}"; do
        csv_label=$(cut -d, -f1 <<<"$entry")
        if [ "\"$csv_label\"" = "$label" ]; then  # compare quoted label
          match=1
          break
        fi
      done

      if [ "$match" -eq 0 ]; then
        # Strip surrounding quotes before passing to delete function
        clean_label="${label%\"}"
        clean_label="${clean_label#\"}"

        echo -n "🗑️  Deleting label: $clean_label ... "
        code=$(label_delete "$clean_label")
        if [ "$code" = "204" ]; then
          echo " ✅ Deleted successfully"
        elif [ "$code" = "404" ]; then
          echo " ⚠️  Not found (already deleted?)"
        else
          echo " ❌ Failed with status code $code"
        fi
      fi
    done
  fi

  # ♻️ Create or update labels
  created_count=0
  updated_count=0
  failed_count=0

  for entry in "${LABELS[@]}"; do
    name=$(cut -d, -f1 <<<"$entry" | xargs)
    color=$(cut -d, -f2 <<<"$entry" | xargs)
    desc=$(cut -d, -f3- <<<"$entry" | xargs)

    echo -n "🔄 Syncing label: \"$name\" ... "

    if label_exists "$name"; then
      status=$(label_update "$name" "$color" "$desc")
      if [ "$status" = "200" ]; then
        echo "✅ Updated (HTTP $status)"
        updated_count=$((updated_count + 1))
      else
        echo "❌ Failed to update (HTTP $status)"
        failed_count=$((failed_count + 1))
      fi
    else
      status=$(label_create "$name" "$color" "$desc")
      if [ "$status" = "201" ]; then
        echo "✅ Created (HTTP $status)"
        created_count=$((created_count + 1))
      else
        echo "❌ Failed to create (HTTP $status)"
        failed_count=$((failed_count + 1))
      fi
    fi
  done

  # 🎉 Summary
  echo
  echo "🎉 Sync complete!"
  echo "  ✅ Created: $created_count"
  echo "  🔄 Updated: $updated_count"
  echo "  ❌ Failed:  $failed_count"
}

# 🔗 Entry point
main "$@"
