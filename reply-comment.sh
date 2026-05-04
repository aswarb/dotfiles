#!/bin/bash
# Reply to PR comments
# Usage: ./reply-comment.sh [comment-id] "Your reply"
# Usage: ./reply-comment.sh "Your reply"  # Uses fuzzy search to pick comment

if [ $# -eq 0 ] || [ $# -gt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [comment-id] 'reply text'"
    echo "       $0 'reply text'  # Interactive comment selection"
    echo ""
    echo "Examples:"
    echo "  $0 123456789 'Good catch, fixed!'"
    echo "  $0 'Thanks for the review'"
    exit 1
fi

# Auto-detect PR
PR_NUM=$(gh pr status --json number --jq '.currentBranch.number' 2>/dev/null)
if [ -z "$PR_NUM" ]; then
    echo "❌ No PR found for current branch"
    exit 1
fi

# Auto-detect repo
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

if [ $# -eq 2 ]; then
    # Comment ID provided
    COMMENT_ID="$1"
    REPLY="$2"
else
    # Interactive selection
    REPLY="$1"
    
    echo "📋 Fetching ALL comments on PR #${PR_NUM}..."
    
    # Get ALL comment types
    # 1. Line-specific review comments  
    REVIEW_COMMENTS=$(gh api "/repos/$REPO/pulls/$PR_NUM/comments" --jq '.[] | "REVIEW|\(.id)|\(.path):\(.line // "")|\(.user.login)|\(.body[0:100])..."')
    
    # 2. General PR issue comments
    GENERAL_COMMENTS=$(gh api "/repos/$REPO/issues/$PR_NUM/comments" --jq '.[] | "GENERAL|\(.id)|general:|\(.user.login)|\(.body[0:100])..."')
    
    # 3. Review-level comments (overall review feedback)
    REVIEW_LEVEL_COMMENTS=$(gh pr view "$PR_NUM" --json reviews --jq '.reviews[] | select(.body != "") | "REVIEW_LEVEL|\(.id)|review:|\(.author.login)|\(.body[0:100])..."')
    
    # Combine all comment types
    COMMENTS=$(printf "%s\n%s\n%s" "$REVIEW_COMMENTS" "$GENERAL_COMMENTS" "$REVIEW_LEVEL_COMMENTS" | grep -v '^$')
    
    if [ -z "$COMMENTS" ]; then
        echo "❌ No comments found on this PR"
        exit 1
    fi
    
    echo ""
    echo "All comments:"
    echo "============="
    
    # Display comments with numbers
    i=1
    declare -a comment_ids
    declare -a comment_types
    while IFS='|' read -r type id location author body; do
        if [ "$type" = "REVIEW" ]; then
            echo "[$i] 📝 $location - @$author (review comment)"
        elif [ "$type" = "REVIEW_LEVEL" ]; then
            echo "[$i] 📋 $location - @$author (review summary)"
        else
            echo "[$i] 💬 $location - @$author (general comment)" 
        fi
        echo "    $body"
        echo ""
        comment_ids[$i]=$id
        comment_types[$i]=$type
        ((i++))
    done <<< "$COMMENTS"
    
    # Get user selection
    echo -n "Select comment to reply to [1-$((i-1))]: "
    read -e -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -ge "$i" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi
    
    COMMENT_ID="${comment_ids[$selection]}"
fi

echo "💬 Replying to comment $COMMENT_ID on PR #${PR_NUM}"
echo "📝 Reply: $REPLY"
echo ""

# Determine comment type by checking which API endpoint returns the comment
echo "🔍 Detecting comment type..."

# Try as review comment first (inline comments)
if gh api "/repos/$REPO/pulls/comments/$COMMENT_ID" >/dev/null 2>&1; then
    echo "📝 Detected as review comment (inline)"
    # This is a review comment - reply to the thread using the correct endpoint
    gh api --method POST "/repos/$REPO/pulls/$PR_NUM/comments" \
        -F in_reply_to="$COMMENT_ID" \
        -f body="$REPLY"
    REPLY_SUCCESS=$?
elif gh api "/repos/$REPO/issues/comments/$COMMENT_ID" >/dev/null 2>&1; then
    echo "💬 Detected as general PR comment"
    # General comments don't have threaded replies - create new comment with reference
    # Get the original comment to show context
    ORIGINAL_COMMENT=$(gh api "/repos/$REPO/issues/comments/$COMMENT_ID")
    ORIGINAL_AUTHOR=$(echo "$ORIGINAL_COMMENT" | jq -r '.user.login')
    ORIGINAL_BODY=$(echo "$ORIGINAL_COMMENT" | jq -r '.body')
    
    # Truncate the body for preview
    if [ ${#ORIGINAL_BODY} -gt 80 ]; then
        ORIGINAL_PREVIEW="${ORIGINAL_BODY:0:80}..."
    else
        ORIGINAL_PREVIEW="$ORIGINAL_BODY"
    fi
    
    # Create a new comment with a clear reference to the original
    gh api --method POST "/repos/$REPO/issues/$PR_NUM/comments" \
        -f body="**@$ORIGINAL_AUTHOR** _[Replying to your comment](https://github.com/$REPO/pull/$PR_NUM#issuecomment-$COMMENT_ID):_

> $ORIGINAL_PREVIEW

$REPLY"
    REPLY_SUCCESS=$?
else
    echo "📋 Treating as review-level comment or other type"
    # For review-level comments or unknown types, create a new general comment
    gh api --method POST "/repos/$REPO/issues/$PR_NUM/comments" \
        -f body="_Replying to review/comment $COMMENT_ID:_

$REPLY"
    REPLY_SUCCESS=$?
fi

if [ $REPLY_SUCCESS -eq 0 ]; then
    echo "✅ Reply posted successfully"
else
    echo "❌ Failed to post reply"
    exit 1
fi