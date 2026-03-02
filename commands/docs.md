---
description: Search Context7 documentation for a library
argument-hint: <library-name>
---

# Documentation Lookup

Search up-to-date documentation for library: **$ARGUMENTS**

## Process

1. Use `mcp__context7__resolve-library-id` to find the Context7 library ID
2. If found, use `mcp__context7__get-library-docs` to retrieve documentation
3. Present a structured summary

## Expected Output Format

### [Library Name] - Documentation

**Version**: [version found]
**Source**: [Context7 link]

#### Key Points
- [point 1]
- [point 2]
- [point 3]

#### Usage Example
```
[code example from docs]
```

#### Main APIs
- `function1()`: description
- `function2()`: description

#### Useful Links
- Official documentation
- GitHub repository

## Rules

- Always verify the library exists in Context7
- If not found, suggest alternatives or search via web search
- Include practical code examples