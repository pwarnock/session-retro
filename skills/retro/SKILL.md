---
name: retro
description: Generate a session retrospective summarizing work done, decisions made, and learnings. Use when the user says "/retro", "session summary", "what did we do", "retrospective", or at the end of a working session.
user_invocable: true
---

# /retro — Session Retrospective

Generate a structured summary of the current coding session with learnings that feed back into project memory.

## Arguments

- `$ARGUMENTS` — Optional: a short slug or topic name for the filename (e.g., "hono-migration"). If not provided, infer from the session's primary topic.

## Steps

### 1. Gather Session Data

Determine the commit range by finding the most recent retro:

```bash
# Find the last retro commit (if any)
git log --oneline --all --grep="session retrospective" --grep="session retro" --grep="docs/session-logs" -1 --format="%H"
```

If a previous retro commit exists, use it as the baseline:

```bash
git log --oneline <last-retro-hash>..HEAD --no-merges
```

If no previous retro exists, fall back to today's commits:

```bash
git log --oneline --since="midnight" --no-merges
```

If still no commits, fall back to the last 10:

```bash
git log --oneline -10 --no-merges
```

Get files changed across the identified range:

```bash
git diff --stat <baseline>..HEAD
```

### 2. Review Conversation Context

Scan the conversation history for:
- **Goals**: What the user asked for at the start
- **Decisions made**: Choices between alternatives, trade-offs discussed
- **Open questions**: Things deferred, unresolved, or flagged for follow-up
- **Surprises/gotchas**: Unexpected findings during implementation
- **Learnings**: Insights about the codebase, tools, or patterns that future sessions should know

### 3. Determine Output Location

Check if `docs/session-logs/` exists. If not, create it.

Generate filename: `docs/session-logs/YYYY-MM-DD-<slug>.md`

The slug comes from `$ARGUMENTS` if provided, otherwise derive from the primary topic (kebab-case, max 40 chars).

### 4. Write the Retrospective

Create the file with this structure:

```markdown
# Session: <Title>

**Date:** YYYY-MM-DD
**Branch:** <current branch>

## Goal

<1-2 sentence description of what the session set out to accomplish>

## Outcome

<Status emoji + summary>
- Use: ✅ Completed | 🔧 In Progress | 📚 Research Only | 🚧 Blocked | ❌ Abandoned

## Changes

### Commits
<List each commit hash + message>

### Files Modified
<Grouped by category — e.g., "Source", "Config", "Docs", "CI">

## Decisions Made

<Bulleted list of choices made and why. Focus on decisions where alternatives existed.>

## Open Questions

<Things unresolved, deferred, or needing follow-up. Tag with owner if known.>

## Learnings

<Insights about the codebase, tools, or patterns. These are candidates for CLAUDE.md or memory updates.>
```

### 5. Offer Memory Updates

After writing the retro, review the Learnings section and check:
- Does CLAUDE.md already cover these? If not, propose additions.
- Does project memory (`.claude/projects/*/memory/`) need updating?

Ask the user: "Want me to apply any of these learnings to CLAUDE.md or project memory?"

### 6. Confirm

Show the user the file path and a brief summary of what was captured. Do NOT commit automatically — let the user decide when to commit.

## Tips

- Keep the retro concise — aim for a file that can be skimmed in 60 seconds
- Focus on decisions and learnings over blow-by-blow chronology
- If multiple topics were covered in one session, group them under the one with the most impact
- The retro should be useful to someone (including future-you) who wasn't in the session
