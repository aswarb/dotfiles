#!/bin/bash
# Usage: ./link-comment.sh "file.ts:42" "Your comment"
# Usage: ./link-comment.sh "file.ts:42-45" "Your comment about range"

if [ $# -ne 2 ]; then
    echo "Usage: $0 'file:line' 'comment'"
    echo "       $0 'file:start-end' 'comment'"
    echo "Example: $0 'src/app.ts:42' 'This needs fixing'"
    echo "Example: $0 'src/app.ts:42-45' 'This whole block is wrong'"
    exit 1
fi

FILE_LINE="$1"
COMMENT="$2"

# Auto-detect PR
PR_NUM=$(gh pr status --json number --jq '.currentBranch.number' 2>/dev/null)
if [ -z "$PR_NUM" ]; then
    echo "❌ No PR found for current branch"
    exit 1
fi

# Auto-detect repo
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Get current commit
COMMIT=$(git rev-parse HEAD)

# Helper function to create Files changed link  
create_files_changed_link() {
    local file="$1"
    local repo="$2"
    local pr_num="$3"
    
    # Simple, reliable approach: link to Files changed view
    # Users can then navigate to the specific file
    echo "https://github.com/${repo}/pull/${pr_num}/files"
}

# Parse file and line(s)
if [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)-([0-9]+)$ ]]; then
    # Range: file:start-end
    FILE="${BASH_REMATCH[1]}"
    START_LINE="${BASH_REMATCH[2]}"
    END_LINE="${BASH_REMATCH[3]}"
    LINE_FRAGMENT="#L${START_LINE}-L${END_LINE}"
    LINE_DESC="lines ${START_LINE}-${END_LINE}"
elif [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)$ ]]; then
    # Single line: file:line
    FILE="${BASH_REMATCH[1]}"
    LINE="${BASH_REMATCH[2]}"
    LINE_FRAGMENT="#L${LINE}"
    LINE_DESC="line ${LINE}"
else
    echo "❌ Invalid format. Use 'file:line' or 'file:start-end'"
    exit 1
fi

# Build the links
BLOB_LINK="https://github.com/${REPO}/blob/${COMMIT}/${FILE}${LINE_FRAGMENT}"
FILES_CHANGED_LINK=$(create_files_changed_link "$FILE" "$REPO" "$PR_NUM")

# Create comment with both link types
FULL_COMMENT="**[${FILE}:${LINE_DESC}](${BLOB_LINK})**  
📁 [View in Files changed](${FILES_CHANGED_LINK})

${COMMENT}"

echo "Adding comment to PR #${PR_NUM}:"
echo "📍 ${FILE}:${LINE_DESC}"
echo "💬 ${COMMENT}"
echo ""

# Post the comment
gh pr comment "$PR_NUM" --body "$FULL_COMMENT"

echo "✅ Comment posted with link to ${FILE}:${LINE_DESC}"