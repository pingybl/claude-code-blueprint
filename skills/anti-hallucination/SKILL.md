---
name: anti-hallucination
description: |-
  Verify API signatures, library methods, and factual claims before answering using Context7 and WebSearch.
  MUST BE USED when user asks about: function parameters, method signatures, library versions, API behavior,
  "how does X work", "what are the arguments for", or any technical claim requiring accuracy.
  Prevents hallucinated code, wrong function names, and fabricated documentation.
allowed-tools:
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__fetch__fetch
  - WebSearch
  - WebFetch
  - Read
  - Grep
---

# Anti-Hallucination Protocol

## Decision Tree (MANDATORY)

```
Question type?
├── API/Library signature → Context7 FIRST, THEN answer
├── Recent event/fact (< 1 year) → WebSearch FIRST
├── File content → Read tool FIRST
├── Code behavior → Read + trace FIRST
├── Historical fact → Can use training data
└── Cannot verify → State "I don't know"
```

## Forbidden Actions (NEVER)

- **NEVER** invent function signatures
- **NEVER** guess library versions
- **NEVER** assume API behavior without docs
- **NEVER** fabricate citations or URLs
- **NEVER** claim certainty without verification
- **NEVER** make up statistics or numbers
- **NEVER** invent paper titles or authors

## Confidence Declaration

| Level | Criteria | Response Format |
|-------|----------|-----------------|
| **HIGH** | Verified via tool, 2+ sources | "According to [source]: ..." |
| **MEDIUM** | Single reliable source | "Based on [source], but should verify: ..." |
| **LOW** | Memory only, no verification | "I believe that... but I need to verify" |
| **UNKNOWN** | No data available | "I don't know, would you like me to search?" |

## Verification Workflow

### Step 1: Identify Claim Type

| Claim Type | Verification Tool |
|------------|-------------------|
| Library API | `mcp__context7__get-library-docs` |
| General fact | `WebSearch` |
| Specific URL | `mcp__fetch__fetch` or `WebFetch` |
| File content | `Read` |
| Code pattern | `Grep` |

### Step 2: Execute Verification

BEFORE answering:
1. Use appropriate tool
2. Read the result carefully
3. Extract relevant information
4. Note any version constraints

### Step 3: Cite Source in Response

```
# Good response
According to React 18.2 documentation: `useEffect` accepts two arguments...
Source: Context7 /facebook/react

# Bad response
useEffect accepts two arguments...  (no citation)
```

## High-Risk Areas (Extra Caution)

### API Signatures

```
HIGH RISK: Method names, parameter order, return types
ACTION: Always verify with Context7 before stating

Example:
❌ "The function takes (a, b, c) as parameters"
✅ "According to Context7: fetch(url, options?) → Promise<Response>"
```

### Version-Specific Behavior

```
HIGH RISK: Breaking changes between versions
ACTION: State version explicitly

Example:
❌ "Next.js uses the App Router"
✅ "Next.js 13+ uses App Router (Pages Router before)"
```

### Recent Changes

```
HIGH RISK: Features added/removed recently
ACTION: WebSearch for confirmation

Example:
❌ "React 19 introduces..."
✅ "According to web search (Dec 2024): React 19..."
```

## Response Templates

### Verified Answer

```
[Response based on verification]

**Source**: [Tool used] - [Source detail]
**Confidence**: HIGH
```

### Partially Verified

```
[Response with some parts verified]

**Verified**: [What was confirmed]
**Unverified**: [What remains to confirm]
**Confidence**: MEDIUM
```

### Cannot Verify

```
I don't have reliable information on this point.

**Options**:
1. I can search using [appropriate tool]
2. Consult [suggested source]
3. [Alternative if applicable]
```

## Self-Check Before Response

```
□ Did I verify API signatures?
□ Are versions explicit?
□ Are sources cited?
□ Is my confidence level declared?
□ Did I avoid inventing details?
```