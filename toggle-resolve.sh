#!/bin/bash

# Toggle resolve/unresolve status of a review comment thread using GraphQL

set -e

# Auto-detect repository and PR
REPO_FULL=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')
PR_NUMBER=$(gh pr view --json number --jq '.number' 2>/dev/null || echo "")

if [[ -z "$PR_NUMBER" ]]; then
    echo "Error: Not in a PR context. Make sure you're on a branch with an associated PR."
    exit 1
fi

# Get comment ID from command line or interactive selection
if [[ -n "$1" ]]; then
    COMMENT_ID="$1"
else
    echo "Available review comments:"
    echo
    
    # Get review thread resolution status via GraphQL
    echo "Fetching thread resolution status..."
    THREAD_DATA=$(gh api graphql -f query="
    query {
      repository(owner: \"$REPO_OWNER\", name: \"$REPO_NAME\") {
        pullRequest(number: $PR_NUMBER) {
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              comments(first: 10) {
                nodes {
                  databaseId
                  path
                  line
                  originalLine
                  body
                }
              }
            }
          }
        }
      }
    }
    ")
    
    # Build arrays for the numbered list
    declare -a comment_ids
    declare -a comment_display
    
    i=1
    while IFS='|' read -r thread_id is_resolved comment_id path line body; do
        if [[ -n "$comment_id" && "$comment_id" != "null" ]]; then
            comment_ids[$i]=$comment_id
            status="[UNRESOLVED]"
            if [[ "$is_resolved" == "true" ]]; then
                status="[RESOLVED]"
            fi
            comment_display[$i]="$path:$line $status - $(echo "$body" | head -c 80)..."
            echo "[$i] ${comment_display[$i]}"
            ((i++))
        fi
    done < <(echo "$THREAD_DATA" | jq -r '
        .data.repository.pullRequest.reviewThreads.nodes[] as $thread |
        $thread.comments.nodes[] |
        select(.databaseId != null) |
        "\($thread.id)|\($thread.isResolved)|\(.databaseId)|\(.path)|\(.line // .originalLine)|\(.body)"
    ')
    
    if [[ $i -eq 1 ]]; then
        echo "No review comments found on this PR."
        exit 1
    fi
    
    echo
    read -p "Select comment to toggle resolve status [1-$((i-1))]: " selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -ge "$i" ]]; then
        echo "❌ Invalid selection"
        exit 1
    fi
    
    COMMENT_ID="${comment_ids[$selection]}"
fi

if [[ -z "$COMMENT_ID" ]]; then
    echo "Error: No comment ID provided"
    exit 1
fi

# Get current comment info 
COMMENT_INFO=$(gh api "/repos/$REPO_FULL/pulls/comments/$COMMENT_ID" 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo "❌ Could not find comment $COMMENT_ID. Make sure the comment ID is correct."
    exit 1
fi
FILE_PATH=$(echo "$COMMENT_INFO" | jq -r '.path')
LINE_NUMBER=$(echo "$COMMENT_INFO" | jq -r '.line // .original_line')

# We need to get the thread ID for GraphQL - query the PR for review threads
echo "Finding review thread for comment..."

# Query for the pull request and its review threads
THREAD_DATA=$(gh api graphql -f query="
query {
  repository(owner: \"$REPO_OWNER\", name: \"$REPO_NAME\") {
    pullRequest(number: $PR_NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 10) {
            nodes {
              databaseId
              path
              line
              originalLine
            }
          }
        }
      }
    }
  }
}
")

# Find the thread that contains our comment
THREAD_ID=$(echo "$THREAD_DATA" | jq -r --arg comment_id "$COMMENT_ID" '
  .data.repository.pullRequest.reviewThreads.nodes[] |
  select(.comments.nodes[] | .databaseId == ($comment_id | tonumber)) |
  .id
')

if [[ -z "$THREAD_ID" || "$THREAD_ID" == "null" ]]; then
    echo "❌ Could not find review thread for comment $COMMENT_ID"
    echo "This comment may not be part of a resolvable review thread."
    exit 1
fi

CURRENT_THREAD_RESOLVED=$(echo "$THREAD_DATA" | jq -r --arg thread_id "$THREAD_ID" '
  .data.repository.pullRequest.reviewThreads.nodes[] |
  select(.id == $thread_id) |
  .isResolved
')

if [[ "$CURRENT_THREAD_RESOLVED" == "true" ]]; then
    MUTATION="unresolveReviewThread"
    ACTION="Unresolving"
    NEW_STATUS="unresolved"
else
    MUTATION="resolveReviewThread"
    ACTION="Resolving" 
    NEW_STATUS="resolved"
fi

echo "$ACTION thread for comment $COMMENT_ID in $FILE_PATH:$LINE_NUMBER..."

# Execute the GraphQL mutation
RESULT=$(gh api graphql -f query="
mutation {
  $MUTATION(input: {threadId: \"$THREAD_ID\"}) {
    thread {
      id
      isResolved
    }
  }
}
")

# Check for errors
if echo "$RESULT" | jq -e '.errors' >/dev/null 2>&1; then
    echo "❌ GraphQL Error:"
    echo "$RESULT" | jq -r '.errors[].message'
    exit 1
fi

# Check if the operation was successful
SUCCESS=$(echo "$RESULT" | jq -r ".data.$MUTATION.thread.isResolved")

if [[ "$MUTATION" == "resolveReviewThread" && "$SUCCESS" == "true" ]] || \
   [[ "$MUTATION" == "unresolveReviewThread" && "$SUCCESS" == "false" ]]; then
    if [[ "$NEW_STATUS" == "resolved" ]]; then
        echo "✅ Review thread resolved!"
    else
        echo "🔄 Review thread unresolved!"
    fi
else
    echo "❌ Failed to $ACTION review thread"
    echo "Response: $RESULT"
    exit 1
fi