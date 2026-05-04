#!/bin/bash
# Create inline review comments on specific lines of code
# Usage: ./review-comment.sh "file.ts:42" "Your review comment"        # Immediate mode
# Usage: ./review-comment.sh "file.ts:42-45" "Your review comment"     # Immediate mode 
# Usage: ./review-comment.sh --start-review                            # Start grouped review
# Usage: ./review-comment.sh --add "file.ts:42" "comment"              # Add to current review
# Usage: ./review-comment.sh --submit "Overall review summary"         # Submit current review
# Usage: ./review-comment.sh --status                                  # Show current review status
# Usage: ./review-comment.sh  # Interactive mode

REVIEW_STATE_FILE="/tmp/gh-review-$PR_NUM"

show_help() {
    echo "Usage: $0 [OPTIONS] ['file:line'] ['comment']"
    echo ""
    echo "Immediate Mode (default):"
    echo "  $0 'file.ts:42' 'comment'           Create individual review comment immediately"
    echo "  $0 'file.ts:42-45' 'comment'        Create multi-line review comment (range)"
    echo "  $0                                   Interactive mode"
    echo ""
    echo "Grouped Review Mode:"
    echo "  $0 --start-review                    Start a new grouped review session"
    echo "  $0 --add 'file:line' 'comment'      Add comment to current review (don't submit yet)"
    echo "  $0 --submit ['summary']              Submit all review comments with optional summary"
    echo "  $0 --status                          Show current review status"
    echo "  $0 --cancel                          Cancel current review session"
    echo ""
    echo "Examples:"
    echo "  $0 'src/app.ts:42' 'This needs fixing'                    # Single line comment"
    echo "  $0 'src/app.ts:42-45' 'Refactor this entire block'       # Multi-line comment"
    echo "  $0 --start-review                                          # Start grouped review"
    echo "  $0 --add 'src/app.ts:42' 'Issue 1'                       # Add to review"
    echo "  $0 --add 'src/util.ts:10-15' 'Issue 2 spans lines'       # Add multi-line comment"
    echo "  $0 --submit 'Overall the code looks good with minor fixes' # Submit review"
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# Auto-detect PR and repo
PR_NUM=$(gh pr status --json number --jq '.currentBranch.number' 2>/dev/null)
if [ -z "$PR_NUM" ]; then
    echo "❌ No PR found for current branch"
    exit 1
fi

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
COMMIT=$(git rev-parse HEAD)

# Handle grouped review mode commands
case "$1" in
    --start-review)
        if [ -f "$REVIEW_STATE_FILE" ]; then
            echo "⚠️  A review session is already active. Use --status to see it or --cancel to clear it."
            exit 1
        fi
        echo "🔄 Starting new grouped review session for PR #$PR_NUM"
        echo "{\"pr\": $PR_NUM, \"repo\": \"$REPO\", \"commit\": \"$COMMIT\", \"comments\": []}" > "$REVIEW_STATE_FILE"
        echo "✅ Review session started. Use --add to add comments, --submit to submit the review."
        exit 0
        ;;
    
    --status)
        if [ ! -f "$REVIEW_STATE_FILE" ]; then
            echo "ℹ️  No active review session."
            exit 0
        fi
        COMMENT_COUNT=$(jq '.comments | length' "$REVIEW_STATE_FILE")
        echo "📝 Active review session for PR #$PR_NUM"
        echo "   Comments queued: $COMMENT_COUNT"
        if [ "$COMMENT_COUNT" -gt 0 ]; then
            echo ""
            jq -r '.comments[] | "   • \(.path):\(.line) - \(.body[0:60])..."' "$REVIEW_STATE_FILE"
        fi
        echo ""
        echo "Use --add to add more comments, --submit to submit the review."
        exit 0
        ;;
        
    --cancel)
        if [ -f "$REVIEW_STATE_FILE" ]; then
            rm "$REVIEW_STATE_FILE"
            echo "🗑️  Review session cancelled."
        else
            echo "ℹ️  No active review session to cancel."
        fi
        exit 0
        ;;
        
    --add)
        if [ ! -f "$REVIEW_STATE_FILE" ]; then
            echo "❌ No active review session. Use --start-review first."
            exit 1
        fi
        if [ $# -ne 3 ]; then
            echo "Usage: $0 --add 'file:line' 'comment'"
            exit 1
        fi
        FILE_LINE="$2"
        COMMENT="$3"
        GROUPED_MODE=true
        ;;
        
    --submit)
        if [ ! -f "$REVIEW_STATE_FILE" ]; then
            echo "❌ No active review session to submit."
            exit 1
        fi
        
        SUMMARY="$2"
        if [ -z "$SUMMARY" ]; then
            SUMMARY="Code review"
        fi
        
        COMMENT_COUNT=$(jq '.comments | length' "$REVIEW_STATE_FILE")
        if [ "$COMMENT_COUNT" -eq 0 ]; then
            echo "❌ No comments in current review session. Use --add to add comments first."
            exit 1
        fi
        
        echo "📤 Submitting review with $COMMENT_COUNT comments..."

        # Validate each comment's line is within a diff hunk before hitting the API
        PR_DIFF=$(gh pr diff "$PR_NUM" 2>/dev/null)
        INVALID=false
        while IFS= read -r comment_json; do
            c_path=$(echo "$comment_json" | jq -r '.path')
            c_line=$(echo "$comment_json" | jq -r '.line | tonumber')
            c_start=$(echo "$comment_json" | jq -r '.start_line // empty')
            c_label="$c_path:${c_start:+$c_start-}$c_line"

            found=false
            in_file=false
            while IFS= read -r dl; do
                if [[ "$dl" =~ ^diff\ --git\ a/[^\ ]+\ b/(.+)$ ]]; then
                    [[ "${BASH_REMATCH[1]}" == "$c_path" ]] && in_file=true || in_file=false
                elif $in_file && [[ "$dl" =~ ^@@[^+]*\+([0-9]+)(,([0-9]+))? ]]; then
                    s=${BASH_REMATCH[1]}; cnt=${BASH_REMATCH[3]:-1}
                    (( c_line >= s && c_line < s + cnt )) && found=true && break
                fi
            done <<< "$PR_DIFF"

            if ! $found; then
                echo "   ❌ $c_label — line not in diff"
                INVALID=true
            fi
        done < <(jq -c '.comments[]' "$REVIEW_STATE_FILE")

        if [ "$INVALID" = true ]; then
            echo "Fix the above line numbers before submitting."
            exit 1
        fi

        # Build the review submission payload
        REVIEW_PAYLOAD=$(jq --arg body "$SUMMARY" '{
            commit_id: .commit,
            body: $body,
            event: "COMMENT",
            comments: [.comments[] | {
                path: .path,
                body: .body,
                line: (.line | tonumber),
                side: "RIGHT"
            } + (if .start_line then {start_line: (.start_line | tonumber), start_side: "RIGHT"} else {} end)]
        }' "$REVIEW_STATE_FILE")
        
        # Submit the review (stdout = JSON body, stderr discarded — gh adds its own non-JSON line there)
        API_RESPONSE=$(echo "$REVIEW_PAYLOAD" | gh api --method POST "/repos/$REPO/pulls/$PR_NUM/reviews" --input - 2>/dev/null)
        RESULT=$?

        if [ $RESULT -eq 0 ]; then
            echo "✅ Review submitted successfully with $COMMENT_COUNT comments"
            rm "$REVIEW_STATE_FILE"
        else
            echo "❌ Failed to submit review"
            echo ""
            API_JSON=$(echo "$API_RESPONSE" | grep '^{' | head -1)
            API_MSG=$(echo "$API_JSON" | jq -r '.message // "Unknown error"' 2>/dev/null)
            API_ERRORS=$(echo "$API_JSON" | jq -r '.errors[]? | if type == "string" then . else .message // .code end' 2>/dev/null)
            echo "   GitHub: $API_MSG"
            [ -n "$API_ERRORS" ] && echo "$API_ERRORS" | while IFS= read -r e; do echo "   • $e"; done
            echo ""
            echo "   Queued comments:"
            jq -r '.comments[] | "   [\(.path):\(if .start_line then (.start_line + "-") else "" end)\(.line)] \(.body[0:80])"' "$REVIEW_STATE_FILE" 2>/dev/null
            exit 1
        fi
        exit 0
        ;;
        
    --*)
        echo "❌ Unknown option: $1"
        show_help
        exit 1
        ;;
esac

# Regular immediate mode or interactive mode logic
GROUPED_MODE=${GROUPED_MODE:-false}

if [ "$GROUPED_MODE" = false ] && [ $# -eq 0 ]; then
    # Interactive mode
    echo "📁 Interactive review comment creation"
    echo "========================================"
    echo ""
    
    # Show changed files in this PR
    echo "Files changed in this PR:"
    CHANGED_FILES=$(gh pr view "$PR_NUM" --json files --jq '.files[].path')
    TOTAL_FILES=$(echo "$CHANGED_FILES" | wc -l)
    
    if [ -z "$CHANGED_FILES" ]; then
        echo "❌ No files found in this PR"
        exit 1
    fi
    
    echo "(Showing all $TOTAL_FILES files)"
    if [ "$TOTAL_FILES" -gt 20 ]; then
        echo "⚠️  Large PR with $TOTAL_FILES files. Consider using direct mode: $0 'file:line' 'comment'"
    fi
    echo ""
    
    i=1
    declare -a file_paths
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "[$i] $file"
            file_paths[$i]=$file
            ((i++))
        fi
    done <<< "$CHANGED_FILES"
    
    echo ""
    read -p "Select file to comment on [1-$((i-1))]: " file_selection
    
    if ! [[ "$file_selection" =~ ^[0-9]+$ ]] || [ "$file_selection" -lt 1 ] || [ "$file_selection" -ge "$i" ]; then
        echo "❌ Invalid file selection"
        exit 1
    fi
    
    SELECTED_FILE="${file_paths[$file_selection]}"
    
    # Show the file content with line numbers (with pagination for large files)
    echo ""
    echo "Content of $SELECTED_FILE:"
    echo "=========================================="
    if [ -f "$SELECTED_FILE" ]; then
        TOTAL_LINES=$(awk 'END{print NR}' "$SELECTED_FILE" 2>/dev/null || echo "0")
        if [ "$TOTAL_LINES" -gt 100 ]; then
            echo "(File has $TOTAL_LINES lines - showing first 100. Use 'cat -n $SELECTED_FILE' to see all)"
            echo ""
            cat -n "$SELECTED_FILE" | head -100
            echo ""
            echo "... (remaining $((TOTAL_LINES - 100)) lines truncated)"
        else
            cat -n "$SELECTED_FILE"
        fi
    else
        echo "❌ File not found: $SELECTED_FILE"
        exit 1
    fi
    
    echo ""
    read -p "Enter line number (or range like 10-15): " line_input
    read -p "Enter your review comment: " comment_text
    
    FILE_LINE="$SELECTED_FILE:$line_input"
    COMMENT="$comment_text"
    
elif [ "$GROUPED_MODE" = false ] && [ $# -eq 1 ]; then
    # Only comment provided - need file:line interactively
    COMMENT="$1"
    echo "📁 Select file and line for comment: \"$COMMENT\""
    echo ""
    
    # Show changed files
    echo "Files changed in this PR:"
    CHANGED_FILES=$(gh pr view "$PR_NUM" --json files --jq '.files[].path')
    TOTAL_FILES=$(echo "$CHANGED_FILES" | wc -l)
    
    echo "(All $TOTAL_FILES files)"
    if [ "$TOTAL_FILES" -gt 20 ]; then
        echo "⚠️  Large PR - consider using direct mode: $0 'file:line' 'comment'"
    fi
    echo ""
    
    i=1
    declare -a file_paths
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "[$i] $file"
            file_paths[$i]=$file
            ((i++))
        fi
    done <<< "$CHANGED_FILES"
    
    echo ""
    read -p "Select file [1-$((i-1))]: " file_selection
    read -p "Enter line number (or range): " line_input
    
    SELECTED_FILE="${file_paths[$file_selection]}"
    FILE_LINE="$SELECTED_FILE:$line_input"
    
elif [ "$GROUPED_MODE" = false ]; then
    # Both file:line and comment provided (immediate mode)
    FILE_LINE="$1"
    COMMENT="$2"
fi

# Parse file and line(s) for both immediate and grouped mode
if [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)-([0-9]+)$ ]]; then
    # Range: file:start-end
    FILE="${BASH_REMATCH[1]}"
    START_LINE="${BASH_REMATCH[2]}"
    END_LINE="${BASH_REMATCH[3]}"
    SINGLE_LINE=false
    LINE_DESC="lines $START_LINE-$END_LINE"
elif [[ "$FILE_LINE" =~ ^([^:]+):([0-9]+)$ ]]; then
    # Single line: file:line
    FILE="${BASH_REMATCH[1]}"
    START_LINE="${BASH_REMATCH[2]}"
    END_LINE="$START_LINE"
    SINGLE_LINE=true
    LINE_DESC="line $START_LINE"
else
    echo "❌ Invalid file:line format. Use 'file.ts:42' or 'file.ts:42-45'"
    exit 1
fi

# Verify file exists
if [ ! -f "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
fi

# Get total lines in file for validation
TOTAL_LINES=$(awk 'END{print NR}' "$FILE" 2>/dev/null || echo "0")
if [ "$END_LINE" -gt "$TOTAL_LINES" ]; then
    echo "⚠️  Warning: Line $END_LINE exceeds file length ($TOTAL_LINES lines)"
    echo "Using line $TOTAL_LINES instead"
    END_LINE=$TOTAL_LINES
fi

if [ "$GROUPED_MODE" = true ]; then
    # Add comment to the review session
    echo "📝 Adding comment to review session: $FILE:$LINE_DESC"
    echo "💬 Comment: $COMMENT"
    
    # Create comment object
    if [ "$SINGLE_LINE" = true ]; then
        COMMENT_OBJ=$(jq -n \
            --arg path "$FILE" \
            --arg body "$COMMENT" \
            --arg line "$START_LINE" \
            '{path: $path, body: $body, line: $line}')
    else
        COMMENT_OBJ=$(jq -n \
            --arg path "$FILE" \
            --arg body "$COMMENT" \
            --arg start_line "$START_LINE" \
            --arg line "$END_LINE" \
            '{path: $path, body: $body, start_line: $start_line, line: $line}')
    fi
    
    # Add to review state
    jq --argjson comment "$COMMENT_OBJ" '.comments += [$comment]' "$REVIEW_STATE_FILE" > "$REVIEW_STATE_FILE.tmp" && mv "$REVIEW_STATE_FILE.tmp" "$REVIEW_STATE_FILE"
    
    COMMENT_COUNT=$(jq '.comments | length' "$REVIEW_STATE_FILE")
    echo "✅ Comment added to review session ($COMMENT_COUNT total). Use --submit to submit the review."
    
else
    # Immediate mode - post the comment right away
    echo "📝 Creating review comment on $FILE:$LINE_DESC"
    echo "💬 Comment: $COMMENT"
    echo ""
    echo "🚀 Posting review comment..."

    if [ "$SINGLE_LINE" = true ]; then
        # Single line comment
        API_ERROR=$(gh api --method POST "/repos/$REPO/pulls/$PR_NUM/comments" \
            -f body="$COMMENT" \
            -f commit_id="$COMMIT" \
            -f path="$FILE" \
            -F line="$START_LINE" \
            -f side="RIGHT" 2>&1)
        RESULT=$?
    else
        # Multi-line comment (range)
        API_ERROR=$(gh api --method POST "/repos/$REPO/pulls/$PR_NUM/comments" \
            -f body="$COMMENT" \
            -f commit_id="$COMMIT" \
            -f path="$FILE" \
            -F start_line="$START_LINE" \
            -F line="$END_LINE" \
            -f start_side="RIGHT" \
            -f side="RIGHT" 2>&1)
        RESULT=$?
    fi

    if [ $RESULT -eq 0 ]; then
        echo "✅ Review comment posted successfully on $FILE:$LINE_DESC"
    else
        echo "❌ Failed to post comment on $FILE:$LINE_DESC"
        echo "   Error: $API_ERROR"
        echo ""
        echo "💡 Common issues:"
        echo "   • Line numbers outside of the diff context"
        echo "   • File not modified in this PR"
        echo "   • Commit SHA mismatch"
        exit 1
    fi
fi