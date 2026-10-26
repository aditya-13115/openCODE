# openCODE — OpenCode AI Engineering Workspace

A Windows-first, reusable OpenCode workspace that brings together AI engineering skills, structured agent workflows, and specialist tools for software development, AI/ML, LLM applications, evaluation, and browser automation.

The repository keeps selected skills in `.agents/skills/`, a portable OpenCode configuration template (`opencode.jsonc.example`), and PowerShell setup scripts at the repository root that download the required source repositories and can install OpenAgents agents, commands, and context into the current Windows user's global OpenCode configuration.

> **Important:** Commit `opencode.jsonc.example`, not a machine-specific active configuration. The active user configuration is normally `%USERPROFILE%\.config\opencode\opencode.jsonc`. Never commit API keys, `.env` files, tokens, local logs, or other secrets.

## Contents

- [What's included](#whats-included)
- [How plugins, skills, agents, commands, and context differ](#how-the-components-differ)
- [Repository layout](#repository-layout)
- [Quick start on Windows](#quick-start-on-windows)
- [Configuration explained](#configuration-explained)
- [Using the workspace](#using-the-workspace)
- [Using the same setup in Claude Code](#using-the-same-setup-in-claude-code)
- [Updating skills and source repositories](#updating-skills-and-source-repositories)
- [Troubleshooting](#troubleshooting)
- [Security and licensing notes](#security-and-licensing-notes)
- [Upstream projects](#upstream-projects)

## What's included

| Project | What it provides | How this workspace uses it |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | Development workflows such as brainstorming, planning, systematic debugging, test-driven development, and code review. | Loaded as an OpenCode V2 plugin through the `plugins` array. OpenCode manages the Git-backed plugin installation; a separate local clone is not required. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Engineering, architecture, debugging, planning, product thinking, testing, and writing skills. | Selected skill copies are stored under `.agents/skills/` and tracked with `skills-lock.json`. |
| [huggingface/skills](https://github.com/huggingface/skills) | Hugging Face Hub, datasets, model training, Spaces, evaluation, inference, and deployment workflows. | Selected skill copies are stored under `.agents/skills/`. Some workflows require the `hf` CLI, authentication, cloud permissions, or extra Python packages. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Production-oriented engineering workflows for TDD, specification-driven development, security, performance, observability, documentation, and review. | Cloned locally by the setup script; its `skills/` folder is configured as an additional skill source. |
| [mlflow/skills](https://github.com/mlflow/skills) | MLflow onboarding, trace analysis, agent debugging, tracing instrumentation, evaluation/scorers, and metrics. | Cloned locally by the setup script; the repository root is configured as a skill source. Some workflows require MLflow, a reachable tracking server, data, or credentials. |
| [anthropics/skills](https://github.com/anthropics/skills) | Examples for frontend design, web-app testing, MCP building, skill creation, and document workflows. | Cloned locally by the setup script; its `skills/` folder is configured as an additional skill source. Review individual upstream license terms before redistributing files. |
| [remcocats/opencode-agents](https://github.com/remcocats/opencode-agents) | Primary agents, specialist subagents, slash commands, context/standards, and optional plugins/tools. | Cloned locally by the setup script. The script can copy `.opencode/agent`, `.opencode/command`, and `.opencode/context` into the user's global OpenCode configuration. Optional plugins and tools are not installed automatically. |

### Additional skill/tool: Agent Browser

The selected `.agents/skills/` snapshot also includes the `agent-browser` skill from [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser). The skill contains instructions for an AI agent; it is **not** the browser automation executable.

To use the CLI, install it separately:

```powershell
npm install -g agent-browser
agent-browser install
agent-browser open https://example.com
agent-browser snapshot
agent-browser close
```

The snapshot recorded in this workspace included 38 selected Matt Pocock skills, 25 selected Hugging Face skills, and the Agent Browser skill under `.agents/skills/`. Counts can change as skills are added or removed; check `skills-lock.json` for the current selected-skill inventory.

## How the components differ

- **Plugin:** Runtime integration that extends OpenCode. Example: Superpowers.
- **Skill:** Reusable instructions and supporting files, usually stored in a directory containing `SKILL.md`.
- **Agent:** A named workflow/persona with instructions and tool permissions. Examples in the OpenAgents snapshot include `openagent` and `opencoder`.
- **Command:** A reusable slash-command prompt template, such as `/test` or `/commit`, when that command exists and is discovered by OpenCode.
- **Context:** Standards and workflow documents that agents or commands can reference.

Adding a skill source does not install the tools, Python packages, Node packages, credentials, or cloud access mentioned by a skill. Install those dependencies only when you need the corresponding workflow.

## Repository layout

After setup, the workspace should look approximately like this:

```text
openCODE/
├── README.md
├── AGENTS.md
├── .gitignore
├── skills-lock.json
├── .agents/
│   └── skills/                    # selected skill copies
├── opencode.jsonc.example         # portable OpenCode config template
├── setup-opencode.ps1             # OpenCode setup script
├── setup-claude-code.ps1          # mirrors this setup into global Claude Code
├── docs/engineering/              # agent work/error logs
├── addyosmani-agent-skills/       # local upstream clone; ignored by Git
├── anthropic-skills/              # local upstream clone; ignored by Git
├── mlflow-skills/                 # local upstream clone; ignored by Git
└── openagents-repo/               # local upstream clone; ignored by Git
```

The four source-clone folders are created locally by the setup script and should be ignored by the outer repository. This prevents accidentally nesting separate Git repositories or redistributing whole upstream checkouts. The selected skill copies, lock file, documentation, configuration template, and setup script are the reusable workspace assets.

The active global OpenCode configuration and OpenAgents files live outside the repository, normally here on Windows:

```text
%USERPROFILE%\.config\opencode\
├── opencode.jsonc
├── agents\
├── commands\
└── context\
```

The tracked `opencode.jsonc.example` is a template only. OpenCode does not automatically load it just because it exists in this repository.

## Quick start on Windows

### Prerequisites

- OpenCode installed and working. This setup targets **OpenCode V2**; the Superpowers V2 plugin configuration requires OpenCode 2.0.4 or later.
- Git for Windows installed and available in PowerShell (`git --version`).
- Windows PowerShell 5.1+ or PowerShell 7.
- Node.js/npm only if you need the Agent Browser CLI or the skills CLI.

### 1. Clone this repository

Replace the placeholder with the URL of your own GitHub repository:

```powershell
git clone <YOUR_REPOSITORY_URL> openCODE
Set-Location .\openCODE
```

### 2. Run the setup script

Run this from the cloned repository root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\setup-opencode.ps1
```

The script performs these steps:

1. Clones the Addy Osmani, Anthropic, MLflow, and OpenAgents repositories if their local folders do not exist. It does not automatically pull updates into existing clones.
2. Sets the per-user `OPENCODE_WORKSPACE` environment variable to the workspace path, using forward slashes so it can be safely substituted into JSONC on Windows.
3. Asks whether to install OpenAgents agents, commands, and context globally. If approved, it backs up existing global folders and the active `opencode.jsonc`, then copies the OpenAgents files into the global configuration directory.
4. If the first prompt is approved, asks separately whether to replace the active global `opencode.jsonc` with the template. The active config is backed up before replacement.

**Pay attention to the two prompts:**

- For a new setup, type `YES` at the OpenAgents prompt. At the config prompt, type `YES` only if you are comfortable replacing the active config with the template.
- If you already have a config with model/provider settings or other custom options, type `YES` at the OpenAgents prompt and `NO` at the config replacement prompt. Then merge the template's `plugins` and `skills` entries into your existing configuration manually.
- If you type `NO` at the **first** prompt, the script returns early. It will have cloned the repositories and set `OPENCODE_WORKSPACE`, but it will not install the OpenAgents files or reach the config-replacement prompt. Run the script again and approve the first prompt when ready.

The script deliberately does **not** install OpenAgents' optional `.opencode/plugin` or `.opencode/tool` code. Those components may require additional dependencies or migration between OpenCode API versions.

### 3. Restart and verify

Restart OpenCode after setup so the active configuration, plugin, and environment are reloaded. Open a new PowerShell window and check the workspace variable and configured directories:

```powershell
$env:OPENCODE_WORKSPACE
Test-Path "$env:OPENCODE_WORKSPACE\.agents\skills"
Test-Path "$env:OPENCODE_WORKSPACE\addyosmani-agent-skills\skills"
Test-Path "$env:OPENCODE_WORKSPACE\mlflow-skills"
Test-Path "$env:OPENCODE_WORKSPACE\anthropic-skills\skills"
```

Each check should return `True`. Then inspect discovered agents:

```powershell
opencode debug agents
```

If the source snapshot contains them and the global installation succeeded, look for `openagent`, `opencoder`, and `system-builder`. You can test the main agent without requesting file changes:

```powershell
opencode run --agent openagent "Explain your workflow. Do not modify files or execute commands."
```

Inside the OpenCode TUI, use `/agents` to inspect/select available agents and type `/` to browse discovered commands.

## Configuration explained

There are two distinct configuration files.

### A. Portable template — tracked in Git

**File:** `opencode.jsonc.example`

This is the reusable template for GitHub. Do not put your personal drive, folder, or Windows username in it. The setup script creates the `OPENCODE_WORKSPACE` environment variable for the current clone location.

The template should contain:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],
  "skills": [
    "{env:OPENCODE_WORKSPACE}/.agents/skills",
    "{env:OPENCODE_WORKSPACE}/addyosmani-agent-skills/skills",
    "{env:OPENCODE_WORKSPACE}/mlflow-skills",
    "{env:OPENCODE_WORKSPACE}/anthropic-skills/skills"
  ]
}
```

What each entry does:

| Configuration entry | Type | What it loads |
|---|---|---|
| `plugins` → `superpowers@git+https://github.com/obra/superpowers.git` | Plugin | Installs/loads Superpowers through OpenCode's Git-backed plugin manager. Superpowers registers its own skills. |
| `{env:OPENCODE_WORKSPACE}/.agents/skills` | Skill source | Selected copies from Matt Pocock and Hugging Face, plus the Agent Browser skill. |
| `{env:OPENCODE_WORKSPACE}/addyosmani-agent-skills/skills` | Skill source | Skills from the local Addy Osmani repository clone. |
| `{env:OPENCODE_WORKSPACE}/mlflow-skills` | Skill source | Skill folders from the local MLflow repository clone. |
| `{env:OPENCODE_WORKSPACE}/anthropic-skills/skills` | Skill source | Skills from the local Anthropic repository clone. Review upstream terms before redistributing content. |

The setup script stores `OPENCODE_WORKSPACE` with forward slashes (for example, `D:/Dev/openCODE`) to avoid Windows backslash-escaping problems during environment-variable substitution in the JSONC file.

### B. Active global configuration — loaded by OpenCode

**File on Windows:** `%USERPROFILE%\.config\opencode\opencode.jsonc`

This is the live configuration file for your user account. The setup script can install the portable template here after prompting. If you already have a working config, do not blindly replace it; merge the `plugins` and `skills` keys, preserving your other settings. Do not create duplicate keys with the same names.

If you set the variable manually instead of running the setup script, from the workspace root use:

```powershell
$workspace = (Resolve-Path .).Path.Replace('\', '/')
[Environment]::SetEnvironmentVariable('OPENCODE_WORKSPACE', $workspace, 'User')
$env:OPENCODE_WORKSPACE = $workspace
```

Then reopen/restart OpenCode and confirm the paths exist. Do not put a raw Windows path such as `D:\Users\name\...` into the tracked example. Keep the template portable by using `{env:OPENCODE_WORKSPACE}`.

### OpenAgents agents, commands, and context are separate

OpenAgents is **not** loaded through the `skills` array. If the setup script's first prompt is approved, it copies these folders from the local `openagents-repo` clone into the global OpenCode directory:

| Source in this repository | Global destination | Purpose |
|---|---|---|
| `openagents-repo/.opencode/agent/` | `%USERPROFILE%\.config\opencode\agents\` | Primary agents and specialist subagents. |
| `openagents-repo/.opencode/command/` | `%USERPROFILE%\.config\opencode\commands\` | Slash-command prompt templates; available commands depend on the source snapshot. |
| `openagents-repo/.opencode/context/` | `%USERPROFILE%\.config\opencode\context\` | Standards and workflow context referenced by agents and commands. |

The script also rewrites the context reference in the installed global `openagent.md` to point at the installed global context directory. The local `openagents-repo` is ignored by the outer Git repository, so any changes made inside that clone are not preserved by a commit to this workspace. Keep important fixes in a fork or as a reviewed patch in a tracked directory.

For version-specific configuration behavior, consult the official [OpenCode V2 configuration docs](https://dev.opencode.ai/v2/docs/config/), [OpenCode V2 skills docs](https://dev.opencode.ai/v2/docs/skills/), and [Superpowers OpenCode installation guide](https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md). OpenCode V1 uses a different Superpowers configuration key (`plugin`, singular); this template uses the V2 key (`plugins`, plural).

## Using the workspace

### Skills

Ask OpenCode to use a skill by describing the workflow, or name the skill directly. Examples:

- `Use the brainstorming skill to refine this feature before coding.`
- `Use the systematic-debugging skill. Reproduce the issue before proposing a fix.`
- `Use the huggingface-llm-trainer skill to plan fine-tuning; inspect the hardware and dataset first.`
- `Use the agent-evaluation skill to design an evaluation dataset and scorer plan for my agent.`
- `Use the frontend-ui-engineering skill to review this UI for layout, accessibility, and responsiveness.`

You can ask OpenCode to use its native skill tool to list discovered skills or load a named skill. Skill instructions are loaded on demand; not every skill is inserted into every prompt automatically.

### Agents

```powershell
# Start an interactive OpenCode session in the current project
opencode .

# Ask the plan-first agent for a read-only architecture map
opencode run --agent openagent "Map the project architecture. Do not modify files."

# Ask the coding-focused agent for a review only
opencode run --agent opencoder "Review the architecture and list concrete improvements. Do not modify files."
```

For implementation tasks, the intended OpenAgent workflow is to inspect relevant context, propose a plan, wait for approval, implement incrementally, validate, and report results. Review plans and tool permissions yourself; a prompt alone is not a security boundary.

### Slash commands

After the global command files have been installed, open the OpenCode TUI and type `/` to browse discovered commands. The source snapshot contains commands such as `/test`, `/commit`, `/context`, `/optimize`, `/validate-repo`, and `/build-context-system`, but availability depends on which files are present and whether a command's dependencies are installed.

## Using the same setup in Claude Code

The same skills, plugin, MCP servers, rules, agents, and commands are also available in [Claude Code](https://docs.claude.com/en/docs/claude-code) at the **global (user) level**, so they work in every project.

### Which script to run

There are no `.bat` files. Both setup scripts are PowerShell scripts:

| Script | What it sets up | When to run it |
|---|---|---|
| `setup-opencode.ps1` | OpenCode: clones the upstream repos, sets `OPENCODE_WORKSPACE`, installs OpenAgents agents/commands/context into `%USERPROFILE%\.config\opencode\` | First time, and after pulling `openagents-repo` |
| `setup-claude-code.ps1` | Claude Code: links the skills, adds the MCP servers, installs Superpowers, creates `CLAUDE.md`, converts agents, and copies commands into `%USERPROFILE%\.claude\` | After `setup-opencode.ps1`, and whenever you add a new skill folder, agent, command, or MCP server |

Run them in that order from the workspace root. `setup-claude-code.ps1` reads the clones and the installed OpenCode agents/commands, so it needs OpenCode set up first:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\setup-claude-code.ps1
```

`setup-claude-code.ps1` requires the `claude` CLI on `PATH`. It doesn't need admin rights, because junctions don't.

**Safety behavior:** the script first backs up `~/.claude/settings.json`, `~/.claude.json`, `CLAUDE.md`, `agents/`, and `commands/` to `~/.claude/backups/openCODE-<timestamp>/`. It **never deletes or overwrites** anything. Items that already exist are reported as "already present" and left alone, so it is safe to re-run. Each run creates a new backup folder, and old ones can be deleted.

### What gets installed where

| OpenCode (`opencode.jsonc` / `~/.config/opencode`) | Claude Code (`~/.claude`, `~/.claude.json`) | How it is linked |
|---|---|---|
| `plugins` → Superpowers | Plugin `superpowers@claude-plugins-official` (user scope) | Installed separately. Each tool manages its own copy |
| `mcp.servers` → `skill-issue`, `context7` | User MCP servers in `~/.claude.json` | Configured separately |
| `skills` (the four folders) | `~/.claude/skills/<name>` → a **junction** to the skill folder in this repo | **Shared files**: both tools read the same folder |
| `AGENTS.md` | `~/.claude/CLAUDE.md` contains `@C:/Users/<you>/.config/opencode/AGENTS.md` | **Shared file**, imported by Claude Code |
| `agents/` (OpenAgents) | `~/.claude/agents/*.md` (flattened, frontmatter converted) | **Copy**, converted once |
| `commands/` (OpenAgents) | `~/.claude/commands/` (`context.md` → `oa-context.md`) | **Copy** |
| `context/` (OpenAgents) | Not copied. Agents that reference it read it from `~/.config/opencode/context/` | Shared, read in place |

Deliberately **not** linked:

- `.agents/skills/code-review`: its name would shadow Claude Code's built-in `/code-review`.
- `anthropic-skills/skills/{claude-api,docx,pdf,pptx,xlsx,skill-creator}`: Claude accounts already get these as `anthropic-skills:*`.
- The MLflow, Addy Osmani, and Anthropic **plugins**. Only their skill folders are linked, which avoids the MLflow plugin's Python hook that runs on every prompt.

### How each part behaves in Claude Code

| Part | How to use it |
|---|---|
| **Skills** | Claude loads one automatically when your request matches its description. You can also call one directly as a slash command (`/tdd`, `/grilling`, `/huggingface-llm-trainer`) or say "use the `<name>` skill". `/skills` lists them all. |
| **Superpowers** | Its skills carry the plugin prefix: `/superpowers:brainstorming`, `/superpowers:systematic-debugging`, `/superpowers:writing-plans`, … |
| **Commands** | `/commit`, `/test`, `/oa-context`, `/optimize`, `/clean`, `/worktrees`, `/validate-repo`, `/build-context-system`, `/prompt-engineering:prompt-enhancer`. **Note:** `/commit` commits *and pushes* without asking. |
| **Subagents** | `reviewer`, `tester`, `coder-agent`, `build-agent`, `task-manager`, `documentation`, `codebase-pattern-analyst`, … Ask for one by name ("use the reviewer agent on my last commit") or pick it with `@`. `/agents` lists and edits them. |
| **Primary agents** | `openagent`, `opencoder`, `system-builder` were "main mode" agents in OpenCode. Start a session as one with `claude --agent openagent`, or set `"agent": "openagent"` in `~/.claude/settings.json` to make it the default. |
| **MCP servers** | They're available in every session. Ask naturally, for example "How do I configure Next.js 15 middleware? use context7". `/mcp` shows status and handles sign-in. |
| **Global rules** | `AGENTS.md` applies to every project. `/memory` shows the loaded `CLAUDE.md`. A project's own `CLAUDE.md` or `.claude/` folder adds to the global one or overrides it. |

Differences from OpenCode:

- OpenCode agent `permissions`, `temperature`, and `mode` have no per-agent equivalent in Claude Code, so they are dropped. Those deny rules (for example, edits to `.env` files) are **not enforced** for the converted agents. Use Claude Code's permission settings if you need them.
- Agents whose OpenCode tools were custom (for example, `image-specialist`'s Gemini tools) only keep the built-in tools.

### Updating: what syncs automatically and what doesn't

| You change… | OpenCode | Claude Code | What to do |
|---|---|---|---|
| A skill's files in this repo (edit, or `git pull` in a clone, or `npx skills update`) | ✅ | ✅ (junction) | Nothing. Restart the session |
| `~/.config/opencode/AGENTS.md` | ✅ | ✅ (import) | Nothing. Edit **that** file for both tools. The repo's `AGENTS.md` is a separate copy |
| A **new** skill folder added to one of the four sources | ✅ | ❌ | Re-run `setup-claude-code.ps1` |
| A skill folder removed or renamed | ✅ | ⚠ broken junction | Delete the stale `~/.claude/skills/<name>` junction (this removes only the link, not the repo folder), then re-run |
| OpenAgents agents/commands (after `git pull` in `openagents-repo`) | Re-run `setup-opencode.ps1` | ❌ copies are not refreshed | Re-run `setup-opencode.ps1`. Then delete or rename the outdated file in `~/.claude/agents/` or `~/.claude/commands/` and re-run `setup-claude-code.ps1`. Existing files are never overwritten |
| A new OpenAgents agent/command file | Re-run `setup-opencode.ps1` | ❌ | Re-run `setup-opencode.ps1`, then `setup-claude-code.ps1` |
| An MCP server added to `opencode.jsonc` | ✅ | ❌ | Add it to `$mcpServers` in `setup-claude-code.ps1` and re-run, or run `claude mcp add --scope user --transport http <name> <url>` |
| The Superpowers version | OpenCode plugin manager | ❌ separate | `claude plugin update superpowers@claude-plugins-official`, then restart |
| A plugin added to `opencode.jsonc` | ✅ | ❌ | `claude plugin install <name>@<marketplace> --scope user` if a Claude Code version exists |

**Rule of thumb:** edit skills in this repo and rules in `~/.config/opencode/AGENTS.md`, and both tools pick up the change. Anything added *new* (skills, agents, commands, MCP servers, plugins) needs `setup-claude-code.ps1` re-run, or a `claude` CLI command.

### Verify

```powershell
claude mcp list        # skill-issue and context7: Connected
claude plugin list     # superpowers@claude-plugins-official: enabled
(Get-ChildItem "$env:USERPROFILE\.claude\skills" | Where-Object LinkType -eq Junction).Count
```

In a new `claude` session, run `/skills`, `/agents`, and `/memory`, and type `/` to browse commands.

## Updating skills and source repositories

The tracked `skills-lock.json` records the selected skill sources and hashes. From the workspace root, inspect changes after updating selected skills:

```powershell
npx skills update --project --yes
git status --short
```

To browse skills available from upstream sources:

```powershell
npx skills add mattpocock/skills --list
npx skills add huggingface/skills --list
npx skills add addyosmani/agent-skills --list
```

Add only the skills you need, rather than installing every skill blindly. Preserve supporting files referenced by a skill, not just `SKILL.md`.

The setup script clones missing repositories but does not pull updates into existing clones. To update a clone manually:

```powershell
git -C .\addyosmani-agent-skills pull --ff-only
git -C .\mlflow-skills pull --ff-only
git -C .\anthropic-skills pull --ff-only
git -C .\openagents-repo pull --ff-only
```

After updating OpenAgents, rerun `setup-opencode.ps1` if you want its agent, command, and context files copied globally again. Back up and review local changes before refreshing those files.

## Committing this workspace

The outer repository should track your selected skill copies, `skills-lock.json`, documentation, portable config template, and setup script—not the full Git checkouts of upstream projects.

Before committing, review the worktree:

```powershell
git status --short
```

Stage the files that belong in the outer repository explicitly:

```powershell
git add README.md AGENTS.md .gitignore skills-lock.json .agents/skills opencode.jsonc.example setup-opencode.ps1 setup-claude-code.ps1 docs/engineering
git status --short
git commit -m "docs: improve portable OpenCode workspace setup"
```

Adjust the `git add` command if your repository's tracked file layout differs. Do not stage ignored source clones or an exported copy of your global configuration. If a nested clone was already added to the outer repository's index before `.gitignore` was updated, inspect `git status` and carefully remove it from the index with `git rm -r --cached -- <folder>`; this keeps local files on disk.

## Troubleshooting

| Symptom | What to check |
|---|---|
| Skills are missing | In a new PowerShell window, check `$env:OPENCODE_WORKSPACE`; confirm each configured path exists and contains skill folders with `SKILL.md`. Ask OpenCode to list skills using its native skill tool. |
| Superpowers skills are missing | Verify OpenCode V2 is in use, the `plugins` entry is present, and the plugin loaded. Restart OpenCode. Follow the [Superpowers install guide](https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md). |
| `openagent` or `opencoder` is missing | Rerun the setup script and approve the first OpenAgents installation prompt. Confirm the files exist under `%USERPROFILE%\.config\opencode\agents\`, then restart OpenCode and run `opencode debug agents`. |
| The script finished but agents were not installed | If you answered `NO` to the first prompt, the script exited before copying the global files. Rerun it and type `YES` at that prompt. |
| A source clone folder exists but setup errors | Inspect the folder and its expected subdirectories. The script does not delete or repair an existing folder whose expected paths are missing. Rename/repair it manually, then rerun setup. |
| A skill requires a missing Python/Node tool, API, or cloud resource | Read its `SKILL.md` and linked documentation, install the required runtime separately, and configure credentials through environment variables. |
| Unix commands such as `ls -la` or `head` fail | You are likely using PowerShell. Use PowerShell-compatible commands or run OpenCode from Git Bash/WSL if that is your preferred shell. |
| Superpowers Git-based installation fails on Windows | See the Windows-specific workaround in the upstream [Superpowers install guide](https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md). |

## Security and licensing notes

- Never commit API keys, `.env` files, model credentials, tokens, private logs, or the live machine-specific `opencode.jsonc`.
- The source-clone folders (`addyosmani-agent-skills`, `anthropic-skills`, `mlflow-skills`, and `openagents-repo`) should remain ignored by the outer Git repository. They are fetched locally by the setup script.
- Review the license terms in each upstream repository before redistributing copied skill content. Some repositories or individual skill folders may have additional restrictions.
- OpenAgents optional plugins/tools and skill scripts may execute code. Inspect source code and install dependencies deliberately. Do not put secrets directly in Markdown, JSONC, or Git history.
- Keep fixes made inside ignored source clones in a fork you control or in a reviewed patch under a tracked directory; otherwise those changes will not be included in commits to this workspace.

## Upstream projects

- [obra/superpowers](https://github.com/obra/superpowers)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [huggingface/skills](https://github.com/huggingface/skills)
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
- [mlflow/skills](https://github.com/mlflow/skills)
- [anthropics/skills](https://github.com/anthropics/skills)
- [remcocats/opencode-agents](https://github.com/remcocats/opencode-agents)
- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) — additional skill/tool, separate from the seven core projects above
