# openCODE — OpenCode AI Engineering Workspace

A Windows-first, reusable OpenCode workspace that brings together AI engineering skills, structured agent workflows, and specialist tools for software development, AI/ML, LLM applications, evaluation, and browser automation.

The repository keeps selected skills in `.agents/skills/`, a portable OpenCode configuration template in `config/`, and a PowerShell setup script that downloads the required source repositories and can install OpenAgents agents, commands, and context into the current Windows user's global OpenCode configuration.

> **Important:** Commit `config/opencode.jsonc.example`, not a machine-specific active configuration. The active user configuration is normally `%USERPROFILE%\.config\opencode\opencode.jsonc`. Never commit API keys, `.env` files, tokens, local logs, or other secrets.

## Contents

- [What's included](#whats-included)
- [How plugins, skills, agents, commands, and context differ](#how-the-components-differ)
- [Repository layout](#repository-layout)
- [Quick start on Windows](#quick-start-on-windows)
- [Configuration explained](#configuration-explained)
- [Using the workspace](#using-the-workspace)
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
├── config/
│   ├── README.md
│   └── opencode.jsonc.example     # portable config template
├── scripts/
│   └── setup-opencode.ps1         # Windows setup script
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

The local `config/` folder is tracked documentation/template content. OpenCode does not automatically load `config/opencode.jsonc.example` just because it exists in this repository.

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
.\scripts\setup-opencode.ps1
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

**File:** `config/opencode.jsonc.example`

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

After updating OpenAgents, rerun `scripts/setup-opencode.ps1` if you want its agent, command, and context files copied globally again. Back up and review local changes before refreshing those files.

## Committing this workspace

The outer repository should track your selected skill copies, `skills-lock.json`, documentation, portable config template, and setup script—not the full Git checkouts of upstream projects.

Before committing, review the worktree:

```powershell
git status --short
```

Stage the files that belong in the outer repository explicitly:

```powershell
git add README.md AGENTS.md .gitignore skills-lock.json .agents/skills config/README.md config/opencode.jsonc.example scripts/setup-opencode.ps1
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
