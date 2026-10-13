# AGENTS.md — openCODE workspace

## Purpose

This repository is a personal OpenCode configuration and AI-engineering skills workspace. It aggregates reusable agent skills and provides scripts/templates for setting up OpenCode across projects. The root is not itself a normal application; do not assume it has a build, test, or lint command.

## Workspace conventions

- Treat `.agents/skills/` and `skills-lock.json` as the currently selected skill set. Preserve supporting files referenced by each `SKILL.md`; do not copy only the Markdown file when a skill needs scripts, references, templates, or assets.
- `config/opencode.jsonc.example` is the portable template. The active user config lives under `%USERPROFILE%\.config\opencode\` and should not be committed.
- The OpenAgents upstream source is `openagents-repo/.opencode/`. The setup script copies agents, commands, and context to the active global config and adapts the main `openagent.md` context references for the current machine.
- The root `.gitignore` intentionally excludes upstream checkout directories and local global-config snapshots. Do not force-add ignored upstream clones or machine-specific config without checking why they are ignored.
- Before changing plugin/tool code, inspect its API-version requirements and dependencies. Skills are instructions; they do not install the executable tools or third-party packages they mention.
- Never put API keys, OAuth tokens, Telegram tokens, `.env` files, or other credentials in Git. Use environment variables and local ignored files instead.

## Windows environment

PowerShell is the default shell for this workspace. Prefer PowerShell-compatible commands and avoid Bash-only utilities such as `head`, `sed`, or `ls -la` unless explicitly running Git Bash or WSL.

## Safety and validation

- Explain planned changes before editing global OpenCode configuration or replacing user-level agent/command/context folders.
- Back up global config before replacing files.
- After modifying setup scripts, verify the config template parses, run `opencode debug agents`, and test a read-only agent prompt.
- Do not claim an installation succeeded solely because an installer prints a final completion banner; check its installed/failed counts and verify discovery.
