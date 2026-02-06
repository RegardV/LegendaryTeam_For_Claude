# Output Compression Skill

Use compressed output formats to reduce token usage by 40-70%.

## Compressed Formats

### Task Completion (instead of verbose)
```
✅ [agent]:[task] | Files:[count] | Tests:[pass/fail] | Duration:[time]
```

### Error Report
```
❌ [error-type] | File:[path]:[line] | Fix:[suggestion]
```

### Status Update
```
⏳ [task] | Progress:[%] | ETA:[time] | Blockers:[none/list]
```

### Coverage Report
```
📊 Coverage:[%] | Statements:[%] | Branches:[%] | Target:[met/gap]
```

### Review Queue Item
```
🔍 [id]:[task] | Confidence:[%] | Wait:[time] | Plan:[file]
```

## Data Serialization

### JSON to Compact (40-50% savings)
```
# Before (verbose JSON)
{"user":{"id":"123","name":"John","role":"admin"}}

# After (compact)
user:123|John|admin
```

### List to Compact
```
# Before
["item1", "item2", "item3"]

# After
items:item1,item2,item3
```

## Tool Response Format

### File Operations
```
📁 R:[path] | Lines:[count]
📝 W:[path] | +[added]/-[removed]
✏️ E:[path]:[line] | Change:[summary]
```

### Search Results
```
🔍 [pattern] | Matches:[count] | Top:[file1,file2,file3]
```

## Usage Guidelines

1. **Always use compact format** for status updates
2. **Truncate long outputs** to 50 lines max
3. **Summarize JSON** instead of including full objects
4. **Reference files** instead of including content
5. **Use symbols** for quick visual parsing
