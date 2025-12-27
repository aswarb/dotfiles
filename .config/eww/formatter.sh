#!/usr/bin/env bash
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <eww-file>"
    exit 1
fi

EWK_FILE="$1"
INDENT=2
tmpfile=$(mktemp)

depth=0
while IFS= read -r line; do
    trimmed=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$trimmed" ]] && continue
    
    opens=$(echo "$trimmed" | tr -cd '(' | wc -c)
    closes=$(echo "$trimmed" | tr -cd ')' | wc -c)
    
    # If balanced parens on one line, keep as-is
    if [[ $opens -eq $closes && $opens -gt 0 ]]; then
        printf "%*s%s\n" $((depth * INDENT)) "" "$trimmed"
        continue
    fi
    
    # If line has unmatched closing parens, split them off
    if [[ $closes -gt $opens ]]; then
        # Extract content before trailing )s
        content="${trimmed%)*}"
        num_trailing=$((closes - opens))
        
        # Print content if exists
        if [[ -n "$content" ]]; then
            printf "%*s%s\n" $((depth * INDENT)) "" "$content"
            depth=$((depth + opens))
        fi
        
        # Print each unmatched ) on its own line
        for ((i=0; i<num_trailing; i++)); do
            depth=$((depth - 1))
            [[ $depth -lt 0 ]] && depth=0
            printf "%*s)\n" $((depth * INDENT)) ""
        done
        
        [[ $depth -eq 0 ]] && echo
    else
        # Normal line
        if [[ "$trimmed" =~ ^\) ]]; then
            depth=$((depth - closes))
            [[ $depth -lt 0 ]] && depth=0
        fi
        
        printf "%*s%s\n" $((depth * INDENT)) "" "$trimmed"
        
        if [[ ! "$trimmed" =~ ^\) ]]; then
            depth=$((depth + opens - closes))
        else
            depth=$((depth + opens))
        fi
        [[ $depth -lt 0 ]] && depth=0
        
        [[ $depth -eq 0 ]] && echo
    fi
    
done < "$EWK_FILE" > "$tmpfile"

mv "$tmpfile" "$EWK_FILE"
