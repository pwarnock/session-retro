# session-retro

A Claude Code plugin that generates structured session retrospectives with hook-driven prompting. Captures work done, decisions made, and learnings that feed back into project memory.

## Features

- **`/retro` skill** — Generate a structured session summary with commits, decisions, open questions, and learnings
- **Stop hook** — Prompts "Run /retro?" when you have 2+ un-retrospected commits before ending a session
- **SessionStart hook** — Advisory reminder at session start if un-retrospected work exists from a previous session

## Installation

```bash
claude plugin add https://github.com/pwarnock/session-retro.git
```

## Per-Project Enable

The plugin only activates in repos that have opted in by creating the output directory:

```bash
mkdir -p docs/session-logs
```

Repos without `docs/session-logs/` will not trigger any hooks or prompts.

## How It Works

### Stop Hook

When Claude finishes a response and is about to stop:

1. Checks if you're in a git repo with `docs/session-logs/`
2. Counts commits since the last retro (or since midnight if no prior retro)
3. If 2+ commits exist, blocks once per session and asks: "Run /retro before wrapping up?"
4. Uses a session marker (`/tmp/claude-retro-{session_id}`) to avoid re-prompting

### SessionStart Hook

When a new Claude session starts:

1. Cleans up stale session markers (>2 hours old)
2. Same repo/commit checks as the Stop hook
3. Prints an advisory message (non-blocking) if un-retrospected work is detected

### /retro Skill

Run `/retro` (or `/retro my-topic-slug`) to generate a retrospective:

1. Finds the commit range since the last retro
2. Reviews conversation context for goals, decisions, and learnings
3. Writes `docs/session-logs/YYYY-MM-DD-<slug>.md`
4. Offers to update CLAUDE.md or project memory with learnings

## License

MIT
