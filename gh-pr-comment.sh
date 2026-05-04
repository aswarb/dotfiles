#!/bin/bash

# Script to post a line-specific comment on a GitHub Pull Request using gh api.
# This script is interactive and prompts the user for all necessary details.

echo "============================================================"
echo "GitHub PR Line Commenter Script (Context-Aware)"
echo "======================================================="

# --- 1. Attempt to auto-detect PR context ---
echo "Attempting to detect current PR context using 'gh pr view'..."
# Note: This requires the 'jq' tool to be installed for JSON parsing.
PR_INFO=$(gh pr view --json number,headRef,baseRef --jq '. | {pr_number: .number, head_ref: .headRef, base_ref: .baseRef}')

if [ $? -eq 0 ] && [ -n "$PR_INFO" ]; then
    # Extract PR Number
    PR_NUMBER=$(echo "$PR_INFO" | jq -r '.pr_number')
    
    # Determine Owner/Repo from the current directory structure (assuming standard repo layout)
    # This is a heuristic and might need manual adjustment if the repo structure is unusual.
    REPO_PATH=$(basename "$(git rev-parse --show-toplevel)")
    # Attempt to get owner from the remote URL
    OWNER=$(git remote get-url origin | sed -E 's/github.com\/(.*)\.git/\1/')
    REPO=$(echo "$REPO_PATH" | sed 's/.git$//')

    echo "✅ Context detected:"
    echo "   Owner: $OWNER"
    echo "   Repo: $REPO"
    echo "   PR Number: $PR_NUMBER"
    
    # Use the head branch as the default commit SHA if not provided
    COMMIT_ID=$(gh api --method GET /repos/${OWNER}/${REPO}/commits/${PR_INFO.head_ref} --jq '.sha')
    
    # Set defaults and prompt for confirmation
    OWNER=$OWNER
    REPO=$REPO
    PR_NUMBER=$PR_NUMBER
    COMMIT_ID=${COMMIT_ID:-$(read -p "Enter Commit SHA (if not auto-detected): ") }
else
    echo "⚠️ Could not automatically detect PR context. Please provide Owner, Repo, and PR Number manually."
    OWNER=""
    REPO=""
    PR_NUMBER=""
    COMMIT_ID=""
fi

# --- 2. Gather remaining details ---
read -p "Enter File Path (e.g., src/file.ts): " FILE_PATH

# 3. Get comment content and line details
echo ""
echo "--- Comment Details ---"
read -p "Enter the main body text for the comment (e.g., 'Please review this section:'): " COMMENT_BODY

echo ""
echo "--- Line Reference Details ---"
read -p "Enter the starting line number (e.g., 1): " START_LINE
read -p "Enter the starting side (e.g., LEFT/RIGHT): " START_SIDE
read -p "Enter the specific line number to highlight (e.g., 2): " LINE_NUMBER
read -p "Enter the side for the specific line (e.g., LEFT/RIGHT): " SIDE

# 4. Final Validation and Execution
echo ""
echo "====================================================================================="

# Check if essential variables are set
if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PR_NUMBER" ] || [ -z "$COMMIT_ID" ] || [ -z "$FILE_PATH" ]; then
    echo "❌ Error: Missing one or more required parameters (Owner, Repo, PR Number, Commit ID, File Path). Aborting."
    exit 1
fi

echo "✅ All details gathered. Attempting to post comment to PR #$PR_NUMBER..."

# Execute the gh api command
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/comments \
  -f body="${COMMENT_BODY}" \
  -f commit_id="${COMMIT_ID}" \
  -f path="${FILE_PATH}" \
  -F start_line="${START_LINE}" \
  -f start_side="${START_SIDE}" \
  -F line="${LINE_NUMBER}" \
  -f side="${SIDE}"

echo "====================================================================================="
echo "Comment posting attempt finished."