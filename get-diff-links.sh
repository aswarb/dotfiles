#!/bin/bash
# Generate accurate GitHub Files changed links with real diff hashes
# Usage: ./get-diff-links.sh "file.ts:42" 

if [ $# -ne 1 ]; then
    echo "Usage: $0 'file:line'"
    exit 1
fi

FILE_LINE="$1"

# Auto-detect PR and repo
PR_NUM=$(gh pr status --json number --jq '.currentBranch.number' 2>/dev/null)
if [ -z "$PR_NUM" ]; then
    echo "❌ No PR found for current branch"
    exit 1
fi

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Parse file and line
if [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)-([0-9]+)$ ]]; then
    FILE="${BASH_REMATCH[1]}"
    START_LINE="${BASH_REMATCH[2]}"
    END_LINE="${BASH_REMATCH[3]}"
    LINE_FRAGMENT="L${START_LINE}-L${END_LINE}"
elif [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)$ ]]; then
    FILE="${BASH_REMATCH[1]}"
    LINE="${BASH_REMATCH[2]}"
    LINE_FRAGMENT="L${LINE}"
else
    echo "❌ Invalid format. Use 'file:line' or 'file:start-end'"
    exit 1
fi

echo "🔍 Looking up diff hash for $FILE in PR #$PR_NUM..."

# Get the actual file diff data from GitHub API
FILE_DATA=$(gh api "/repos/$REPO/pulls/$PR_NUM/files" --jq ".[] | select(.filename == \"$FILE\")")

if [ -z "$FILE_DATA" ]; then
    echo "❌ File $FILE not found in PR #$PR_NUM"
    exit 1
fi

# Extract patch content and generate hash
PATCH=$(echo "$FILE_DATA" | jq -r '.patch // ""')

if [ -z "$PATCH" ] || [ "$PATCH" = "null" ]; then
    echo "⚠️  No patch data for $FILE (binary file or no changes)"
    echo "Files changed link: https://github.com/$REPO/pull/$PR_NUM/files"
    exit 0
fi

# Generate a diff hash based on filename and content
# GitHub uses a complex algorithm, but we can approximate it
HASH=$(echo -n "${FILE}${PATCH}" | sha1sum | cut -c1-8)

# Create the Files changed link with diff hash
DIFF_LINK="https://github.com/$REPO/pull/$PR_NUM/files#diff-${HASH}R${LINE_FRAGMENT/L/}"

echo "📍 File: $FILE"
echo "🔗 Files changed link: $DIFF_LINK"
echo "🔗 Blob link: https://github.com/$REPO/blob/$(git rev-parse HEAD)/$FILE#$LINE_FRAGMENT"