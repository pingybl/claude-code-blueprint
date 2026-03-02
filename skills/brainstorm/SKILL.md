---
name: brainstorm
description: |-
  Multi-agent brainstorming on complex topics. Explores the subject with the user,
  then spawns specialized sub-agents in parallel for diverse expert perspectives.
  MUST BE USED when user asks: "brainstorm", "explore ideas", "what are the options",
  "how should I approach", "pros and cons", "compare approaches", "what do you think about".
  Combines structured dialogue with parallel expert analysis.
allowed-tools:
  - Agent
  - AskUserQuestion
  - WebSearch
  - WebFetch
  - mcp__fetch__fetch
  - Read
  - Grep
  - Glob
---

# Multi-Agent Brainstorm

## Overview

Structured brainstorming that combines clarifying dialogue with parallel expert sub-agents.
The goal: understand the problem first, then get diverse expert perspectives, then synthesize.

## Process

```
Phase 1: CLARIFY   → Understand the topic (2-3 targeted questions)
Phase 2: MAP       → Select relevant expert agents
Phase 3: EXPLORE   → Spawn agents in parallel
Phase 4: SYNTHESIZE → Combine and present findings
```

## Phase 1: Clarify the Topic

Before spawning any agent, understand what the user actually needs.

**Ask 2-3 targeted questions** (one at a time, prefer multiple choice):

- What is the core problem or goal?
- What constraints exist? (tech stack, budget, timeline, existing code)
- What does success look like?

**Rules:**
- One question per message
- Prefer multiple choice via AskUserQuestion when possible
- Max 3 questions — don't interrogate, get enough context to spawn useful agents
- If the topic is already clear and specific, skip to Phase 2

## Phase 2: Map to Expert Agents

Select **2-4 relevant agents** from this mapping:

| Domain | Agent Type |
|--------|------------|
| TypeScript/React/Next.js | typescript-expert, frontend-developer |
| Python/FastAPI/Django | python-expert, python-development:python-pro |
| React Native/Expo | react-native-expert |
| AI/ML Research | research-synthesizer |
| API/Backend | python-development:fastapi-pro, typescript-expert |
| Architecture/Design | feature-dev:code-architect |
| Content/Social Media | content-creator |
| Medium/Long-form | medium-writer |
| SEO | seo-expert |
| UI/UX Design | ui-ux-designer |
| Midjourney | midjourney-expert |
| AI Image (Kling) | kling-image-expert |
| AI Video (Kling) | kling-video-expert |
| Claude Code/API/MCP | claude-expert |
| Finance/Crypto/Tax | finance-advisor |
| Fitness/Nutrition | fitness-coach |
| Music AI/Noelle Dea | ai-singer-agent |
| Video/FFMPEG | social-media-clip-creator |
| Prompt Engineering | prompt-engineer |
| Code Review | feature-dev:code-reviewer |
| General research | general-purpose |

**Selection criteria:**
- Pick agents that bring **different perspectives** on the topic
- At least one agent should challenge the obvious approach
- For cross-domain topics, pick agents from different domains

## Phase 3: Explore via Parallel Agents

Spawn all selected agents **simultaneously** using the Agent tool.

**Each agent prompt MUST include:**

```
Brainstorm: [topic with context from Phase 1]

Context: [key constraints and goals identified]

Your task:
1. Propose 2-3 approaches from your domain expertise
2. For each approach: trade-offs, risks, and when it works best
3. Justify every recommendation with sources (docs, papers, experience)
4. State confidence level (HIGH/MEDIUM/LOW) for each claim
5. Flag anything you cannot verify
6. Highlight what you'd do differently from the obvious approach
```

**Important:**
- Use `model: "opus"` for complex/architectural topics
- Use `model: "sonnet"` for straightforward domain questions
- All agents run in parallel — never sequential

## Phase 4: Synthesize

After all agents return, present a unified synthesis:

```markdown
## Synthesis: [Topic]

### Consensus
[What multiple agents agree on — strongest signal]

### Divergent Views
[Where agents disagree, with rationale from each side]

### Recommended Approach
[Best path forward, justified by agent findings]
[State which agent perspectives informed this recommendation]

### Trade-offs to Consider
[Key decisions the user still needs to make]

### Sources
[All sources cited by agents, deduplicated]

### Confidence: [LEVEL]
[Based on source agreement and verification quality]
```

## Edge Cases

### Topic too vague
Ask one clarifying question. If still vague after 2 questions, brainstorm at the level of abstraction given.

### No obvious agent match
Use `general-purpose` agents with specific domain prompts. Always spawn at least 2.

### User wants to go deeper
After synthesis, offer to spawn additional agents on specific sub-topics that emerged.

### Quick brainstorm
If user says "quick" or the topic is narrow, skip Phase 1 and spawn 2 agents directly.
