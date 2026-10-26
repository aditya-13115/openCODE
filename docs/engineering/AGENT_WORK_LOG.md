# Agent Work Log

## [2026-10-26 12:19] Task: Mirror the OpenCode config into global Claude Code config

- **User request / acceptance criteria:** Use the same plugins, MCP servers and skills as `opencode.jsonc` in Claude Code, configured globally, with skills sourced from this repo. The user then approved: skills via junctions, plus the global AGENTS.md rules and the OpenAgents agents and commands.
- **Starting state:** `main`, clean tree. `~/.claude/settings.json` had only theme and autoUpdates. No user MCP servers, no plugins. Claude Code 2.1.310. Python not installed (Store alias only).
- **Investigation:** Read `opencode.jsonc.example`, the live `~/.config/opencode/opencode.jsonc`, `setup-opencode.ps1` and `README.md`, plus `~/.config/opencode/{agents,commands}`. Found that the addyosmani, anthropic and mlflow clones ship `.claude-plugin` manifests, and that the mlflow plugin has a Python UserPromptSubmit hook, so it would fail without Python. The official marketplace already lists `superpowers` and `context7`. No skill-name clashes across the four sources. `.agents/skills/code-review` clashes with the built-in `/code-review`, and the OpenAgents `context.md` command clashes with the built-in `/context`.
- **Plan:** A new idempotent `setup-claude-code.ps1` that backs up first, then creates the junctions, the CLAUDE.md import, the converted agents, the copied commands, `claude mcp add --scope user` ×2 and `claude plugin install superpowers@claude-plugins-official --scope user`. Plan file: `~/.claude/plans/see-go-through-this-parallel-riddle.md`. Approved by the user via plan mode.
- **Changes made:**
  - `setup-claude-code.ps1`: new setup script.
  - `README.md`: added a "Using the same setup in Claude Code" section.
  - Outside the repo (made by running the script): 114 junctions in `~/.claude/skills`, `~/.claude/CLAUDE.md`, 17 files in `~/.claude/agents`, 12 in `~/.claude/commands`, 2 user MCP servers in `~/.claude.json`, and Superpowers 7.0.0 enabled at user scope. Backup at `~/.claude/backups/openCODE-20261026-121807`.
- **Checks run:**
  - `.\setup-claude-code.ps1`: PASS. Added 147, skipped 7 (all expected).
  - `.\setup-claude-code.ps1` (second run): PASS. Added 0, already present 147, so it is idempotent.
  - `claude mcp list`: PASS. skill-issue and context7 connected.
  - `claude plugin list`: PASS. superpowers@claude-plugins-official enabled, user scope.
  - Junction count = 114, and `~/.claude/skills/tdd/SKILL.md` resolves: PASS.
  - Frontmatter check on all 17 agents (name and description present): PASS.
  - Live session skill listing showed the new skills and commands (e.g. tdd, oa-context, prompt-engineering:*): PASS.
  - `/agents` in a fresh interactive session: NOT RUN. `claude agents` lists background sessions, not subagent definitions.
- **Errors:** None encountered.
- **Remaining risks / unverified behavior:** The agent conversion is lossy (OpenCode permission rules are not enforced, and custom tools such as image-specialist's are dropped). The `/commit` command tells the agent to push without asking. The second script run created an extra backup folder. Some skills need external tools (hf CLI, agent-browser, MLflow, Python).
- **Outcome:** COMPLETE

## [2026-10-26] Task: Document Claude Code behavior and update flow in README (time unavailable)

- **User request / acceptance criteria:** The README should explain how the Claude Code setup behaves, how updating one tool affects the other, and which script to run.
- **Starting state:** `main`, uncommitted changes from the previous task (README section, `setup-claude-code.ps1`, `docs/`).
- **Investigation:** Confirmed what is shared and what is copied from the earlier implementation: skills are junctions, `CLAUDE.md` imports `~/.config/opencode/AGENTS.md`, agents and commands are copies that are never overwritten, and MCP servers and plugins are configured separately. Confirmed that `claude plugin update` exists. Confirmed there are no `.bat` files, and that the repo `AGENTS.md` is currently identical to `~/.config/opencode/AGENTS.md` but is a separate file.
- **Changes made:**
  - `README.md`: expanded "Using the same setup in Claude Code" with which-script, install-mapping, behavior, sync/update matrix and verify subsections. Added a Contents entry and a layout-tree entry.
- **Checks run:** `git diff --check`: PASS (no whitespace errors). Docs only, so no runtime checks.
- **Errors:** None encountered.
- **Remaining risks / unverified behavior:** Pre-existing and not changed: `setup-opencode.ps1` resolves the workspace as `$PSScriptRoot\..` and the template as `config\opencode.jsonc.example`, but both files sit at the repo root, so running it from the current layout will fail. The README's layout tree still describes `config/` and `scripts/` folders that don't exist.
- **Outcome:** COMPLETE

## [2026-10-26] Task: Fix setup-opencode.ps1 paths and the inactive gitignore (time unavailable)

- **User request / acceptance criteria:** The user approved "fix paths in place" and "rename + untrack" via AskUserQuestion.
- **Starting state:** `main`, with the uncommitted changes from the previous two tasks.
- **Investigation:** `setup-opencode.ps1` resolved the workspace as `$PSScriptRoot\..` and the template as `config\opencode.jsonc.example`, but both sit at the repo root. The ignore file was named `gitignore` without the leading dot, so Git ignored it and 1049 files of upstream clones were tracked, contrary to the README.
- **Changes made:**
  - `setup-opencode.ps1`: workspace = `$PSScriptRoot`, template = `opencode.jsonc.example`, and two prompt/warning strings updated to match.
  - `README.md`: replaced the `config/` and `scripts/` references with the root paths (intro, important note, layout tree, quick start, template section, update note, `git add` example).
  - `gitignore` → `.gitignore` (via `git mv`, so the rename is staged).
  - `git rm -r --cached` on addyosmani-agent-skills, anthropic-skills, mlflow-skills and openagents-repo. 1049 index deletions are staged, and the files remain on disk.
- **Checks run:**
  - PowerShell parser on both setup scripts: PASS, 0 errors.
  - Resolved the workspace, template and the four clone check-paths the way the fixed script does: PASS, all exist. The script itself was NOT RUN, because it prompts and modifies global config.
  - `git check-ignore anthropic-skills/README.md`: PASS, now ignored.
  - Clone folders still on disk: PASS. The Claude skill junctions are unaffected.
- **Errors:** None (one sed escaping miss on a single line was corrected with Edit).
- **Remaining risks / unverified behavior:** The index removal and the rename are staged but not committed. After the next commit, a fresh clone of this repo needs `setup-opencode.ps1` to fetch the upstream repos. `.gitignore` also ignores `**/build/`, `**/dist/` and `*.log`, but already-tracked `.agents` files are unaffected.
- **Outcome:** COMPLETE
