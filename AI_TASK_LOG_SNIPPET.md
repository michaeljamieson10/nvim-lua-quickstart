# Task: Fix .log Snippet Duplication Issue

## Problem
The `.log` snippet in `lua/custom/plugins/liquid.lua` (around line 340) sometimes creates duplicate output:
```liquid
{{ {{  | stringifyObj }} | stringifyObj }}
```

## Current Implementation
- Snippet trigger: `.log`
- Expected output: `{{ <clipboard_content> | stringifyObj }}`
- Uses a function_node to read clipboard with `vim.fn.getreg('+')`
- Has error handling but still produces duplicates

## Your Task
Fix the duplication issue. You have full autonomy to:
1. Investigate why duplicates occur (clipboard format? snippet expansion? LuaSnip behavior?)
2. Choose your approach: modify the function_node logic, change to insert_node, add detection/prevention, or redesign entirely
3. Ensure it remains resilient - don't break on empty clipboard
4. Test edge cases: empty clipboard, multiline content, special characters

## Files
- **Main file**: `lua/custom/plugins/liquid.lua` (line ~340, the `.log` snippet)
- **Related**: Other snippets in same file show working patterns you can reference

## Success Criteria
- `.log` expands to clean `{{ value | stringifyObj }}` without duplication
- Clipboard content (when valid) is inserted as the value
- Graceful fallback when clipboard is empty/invalid

Make whatever changes you deem necessary. Commit and push when done.
