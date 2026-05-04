#!/bin/bash
# List all PR comments in a readable format
# Usage: ./list-comments.sh [--unresolved] [--resolved] [--all]

FILTER="all"
if [ "$1" = "--unresolved" ]; then
    FILTER="unresolved"
elif [ "$1" = "--resolved" ]; then
    FILTER="resolved"
elif [ "$1" = "--all" ]; then
    FILTER="all"
elif [ $# -gt 0 ]; then
    echo "Usage: $0 [--unresolved|--resolved|--all]"
    echo ""
    echo "Options:"
    echo "  --unresolved  Show only unresolved comments"
    echo "  --resolved    Show only resolved comments"
    echo "  --all         Show all comments (default)"
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

echo "📋 Comments on PR #${PR_NUM} (${FILTER})"
echo "=========================================="

# Get all comments (both issue comments and review comments)
echo "Fetching comments..."

# Get general PR comments
GENERAL_COMMENTS=$(gh api "/repos/$REPO/issues/$PR_NUM/comments" --jq '.[] | "GENERAL|\(.id)|\(.user.login)|\(.created_at)|\(.body)"')

# Get review comments 
REVIEW_COMMENTS=$(gh api "/repos/$REPO/pulls/$PR_NUM/comments" --jq '.[] | "REVIEW|\(.id)|\(.user.login)|\(.created_at)|\(.body)|\(.path):\(.line)|\(.resolved // false)"')

# Combine and sort by creation time
ALL_COMMENTS=$(printf "%s\n%s" "$GENERAL_COMMENTS" "$REVIEW_COMMENTS" | grep -v '^$' | sort -t'|' -k4)

if [ -z "$ALL_COMMENTS" ]; then
    echo "No comments found on this PR"
    exit 0
fi

COMMENT_COUNT=0

while IFS='|' read -r type id author created_at body location resolved; do
    # Apply filtering
    if [ "$type" = "REVIEW" ]; then
        if [ "$FILTER" = "unresolved" ] && [ "$resolved" = "true" ]; then
            continue
        elif [ "$FILTER" = "resolved" ] && [ "$resolved" = "false" ]; then
            continue
        fi
    elif [ "$FILTER" = "resolved" ] || [ "$FILTER" = "unresolved" ]; then
        # General comments can't be resolved, skip when filtering by resolution
        continue
    fi
    
    ((COMMENT_COUNT++))
    
    # Format timestamp
    FORMATTED_TIME=$(date -d "$created_at" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$created_at")
    
    echo ""
    if [ "$type" = "GENERAL" ]; then
        echo "💬 General Comment #$id - @$author ($FORMATTED_TIME)"
    else
        RESOLVE_STATUS="📖"
        if [ "$resolved" = "true" ]; then
            RESOLVE_STATUS="✅"
        fi
        echo "$RESOLVE_STATUS Review Comment #$id - @$author ($FORMATTED_TIME)"
        echo "   📍 $location"
    fi
    
    # Format comment body (limit length, preserve formatting)
    FORMATTED_BODY=$(echo "$body" | sed 's/^/   /' | head -5)
    if [ ${#body} -gt 200 ]; then
        FORMATTED_BODY=$(echo "$body" | cut -c1-200 | sed 's/^/   /')
        echo "$FORMATTED_BODY..."
    else
        echo "$FORMATTED_BODY"
    fi
    
done <<< "$ALL_COMMENTS"

echo ""
echo "=========================================="
echo "Total: $COMMENT_COUNT comments shown"

if [ "$FILTER" != "all" ]; then
    TOTAL_COMMENTS=$(echo "$ALL_COMMENTS" | wc -l)
    echo "Filter: $FILTER (of $TOTAL_COMMENTS total comments)"
fi