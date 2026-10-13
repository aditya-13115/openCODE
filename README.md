# openCODE — Personal OpenCode AI Engineering Workspace

A portable Windows-first workspace for using OpenCode with reusable skills, agent workflows, and specialist tools for software engineering, AI/ML, LLM applications, evaluation, and browser automation.

This repository brings together seven upstream projects. It keeps your selected skills in `.agents/skills`, keeps a portable OpenCode config template under `config/`, and uses a setup script to install OpenAgents agents/commands/context into your user-level OpenCode config on the current machine.

> **Important:** `config/opencode.jsonc.example` is the portable template. The active user-level config belongs at `%USERPROFILE%\.config\opencode\opencode.jsonc`. Do not commit machine-specific global config snapshots, `node_modules`, tokens, or secrets.

## What's included

| Upstream project | What it contributes | How this workspace uses it |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | A development-workflow skill framework: brainstorming, planning, systematic debugging, test-driven development, code review, and related workflows. | Installed as an OpenCode V2 plugin through the `plugins` array. The plugin registers its skills; a separate local clone is not required. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Engineering, architecture, debugging, planning, product-thinking, testing, and writing skills. | The inspected `skills-lock.json` records 38 selected skills installed under `.agents/skills`. |
| [huggingface/skills](https://github.com/huggingface/skills) | Hugging Face Hub, datasets, model training, Spaces, evaluation, inference, and deployment workflows. | The inspected `skills-lock.json` records 25 selected skills under `.agents/skills`. `hf-cli` is a useful starting point. Some workflows require the `hf` CLI, authentication, cloud permissions, or extra Python packages. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Production-oriented engineering workflows: TDD, specification-driven development, incremental implementation, security, performance, observability, documentation, and review. | The repository's `skills/` directory is added as a skill source. The inspected snapshot has 25 skill folders. |
| [mlflow/skills](https://github.com/mlflow/skills) | MLflow onboarding, trace analysis, agent debugging, tracing instrumentation, evaluation/scorers, and metrics. | The repository root is added as a skill source; the inspected snapshot has 13 folders containing `SKILL.md`. Some skills need a working MLflow installation, a reachable tracking server, data, or credentials. |
| [anthropics/skills](https://github.com/anthropics/skills) | Examples for frontend design, web-app testing, MCP building, skill creation, artifacts, and document workflows. | The `skills/` directory is an extra skill source. The inspected snapshot has 19 skill folders. The full source clone is fetched locally by the setup script and intentionally ignored by Git; see the licensing note below. |
| [remcocats/opencode-agents](https://github.com/remcocats/opencode-agents) | A plan-first agent framework: primary agents, specialist subagents, slash commands, context/standards, and optional plugins/tools. | `scripts/setup-opencode.ps1` copies its local `.opencode/agent`, `.opencode/command`, and `.opencode/context` content into the user's global OpenCode config. Optional plugins/tools are not copied automatically because they may need dependency installation or version-specific migration. |

### Extra skill already present

The current `.agents/skills` snapshot also contains `agent-browser` from [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser). The skill is instructions for an AI agent; it is **not** the browser automation executable. To use browser automation itself, install and verify the CLI separately:

```powershell
npm install -g agent-browser
agent-browser install
agent-browser open https://example.com
agent-browser snapshot
agent-browser close
```

## Concepts: plugin vs. skill vs. agent vs. command vs. context

- **Plugin:** executable integration that extends OpenCode at runtime. Example: Superpowers is configured as a plugin.
- **Skill:** reusable instructions and supporting files, usually a folder containing `SKILL.md`. OpenCode can load a skill when relevant or when asked.
- **Agent:** a named persona/workflow with its own prompt and tool permissions. Example: `openagent` or `opencoder`.
- **Command:** a reusable slash-command prompt template. Examples include `/test`, `/commit`, and `/optimize` when those command files are installed and discovered.
- **Context:** supporting standards and workflow documents that agents/commands read during tasks.

Adding a skill directory does not install tools or Python/Node dependencies mentioned in the skill. Install dependencies only when you use the relevant workflow and follow each project's instructions.

## Layout

The relevant tracked layout should look approximately like this:

```text
openCODE/
├── README.md
├── AGENTS.md
├── .gitignore
├── skills-lock.json
├── .agents/
│   └── skills/                    # selected skill copies (Matt Pocock, Hugging Face, Agent Browser)
├── config/
│   ├── README.md
│   └── opencode.jsonc.example     # portable template; no machine-specific paths
├── scripts/
│   └── setup-opencode.ps1         # clones missing source repos and installs global OpenAgents files
├── addyosmani-agent-skills/       # local upstream clone; ignored by Git
├── anthropic-skills/              # local upstream clone; ignored by Git
├── mlflow-skills/                 # local upstream clone; ignored by Git
└── openagents-repo/               # local upstream clone; ignored by Git
```

The four upstream clone folders are created locally by the setup script and are ignored in the outer repository to avoid nested-Git-repository problems and unnecessary redistribution of upstream source. The `.agents/skills` directory and `skills-lock.json` preserve the 64 selected skill folders recorded in the inspected snapshot.

The actual global OpenCode files live outside this repo at:

```text
%USERPROFILE%\.config\opencode\
├── opencode.jsonc
├── agents\
├── commands\
└── context\
```

The local `config/` folder is the tracked config template/documentation area. It is not automatically read by OpenCode just because it exists in this workspace.

## Windows setup

### Prerequisites

- OpenCode installed and working.
- Git for Windows installed and available in PowerShell (`git --version`).
- PowerShell 5.1+ (Windows PowerShell or PowerShell 7).
- Node.js/npm if you need the skills CLI or Agent Browser CLI.

The OpenAgents installer was tried during setup, but it reported **Installed: 0, Failed: 68** after fetching its registry and failing to resolve component paths. For repeatable use, this workspace's script copies the needed files directly from the local clone rather than relying on that failed profile installation.

### 1. Clone this workspace

Replace `<your-github-repo-url>` with the URL of your own repository:

```powershell
git clone <your-github-repo-url> openCODE
cd openCODE
```

### 2. Run the setup script

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\setup-opencode.ps1
```

The script:

1. Clones the Addy Osmani, Anthropic, MLflow, and OpenAgents source repositories if they are missing.
2. Sets the per-user `OPENCODE_WORKSPACE` environment variable to this repo's current location, so skill paths work if the repo is cloned to a different drive/folder later.
3. Creates a timestamped backup of existing global `agents`, `commands`, `context`, and `opencode.jsonc` files before changing them.
4. Copies the OpenAgents agents, commands, and context from the local OpenAgents clone into `%USERPROFILE%\.config\opencode\`.
5. Rewrites the context references in the installed global `openagent.md` to use the current user's global context directory.
6. Asks before replacing the active global `opencode.jsonc` with the portable template. If you answer no, manually merge the template's `plugins` and `skills` keys into your existing active config.

It deliberately does **not** copy OpenAgents' optional `.opencode/plugin` or `.opencode/tool` code. Those components can have runtime dependencies or API-version constraints and should be installed/migrated separately when needed.

### 3. Restart OpenCode and verify

Close and reopen the terminal/OpenCode process so the updated environment variable is available. Then run:

```powershell
opencode debug agents | ConvertFrom-Json |
    Where-Object { $_.id -match 'openagent|opencoder|system-builder' } |
    Select-Object id, name, description |
    Format-Table -Wrap
```

You should see `openagent`, `opencoder`, and `system-builder` among the discovered agents. You can also run a no-write test from any project directory:

```powershell
opencode run --agent openagent "Explain your workflow. Do not modify files or execute commands."
```

Inside the OpenCode TUI, use `/agents` to choose a primary agent and type `/` to inspect available commands. Specialist subagents (for example reviewer/tester) are generally delegated to by the main agent rather than selected as primary agents.

## OpenCode JSONC configuration

OpenCode reads your active user-level configuration from this file on Windows:

```text
%USERPROFILE%\.config\opencode\opencode.jsonc
```

To manually configure the same setup used on the original machine, open that file and add the following keys. If the file already contains settings, **merge these keys into the existing JSONC**—do not replace unrelated settings or create duplicate `plugins` or `skills` keys.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],
  "skills": [
    "D:/CODIN PLAYGROUND/openCODE/.agents/skills",
    "D:/CODIN PLAYGROUND/openCODE/addyosmani-agent-skills/skills",
    "D:/CODIN PLAYGROUND/openCODE/mlflow-skills",
    "D:/CODIN PLAYGROUND/openCODE/anthropic-skills/skills"
  ]
}
```

**Important:** Those four skill paths are absolute paths for the original Windows machine. If your workspace is in a different location, update each path to match it. The source-clone directories (`addyosmani-agent-skills`, `mlflow-skills`, and `anthropic-skills`) must exist locally and contain skill folders with `SKILL.md` files.

### Portable configuration for GitHub

The tracked template is [`config/opencode.jsonc.example`](config/opencode.jsonc.example). It uses `{env:OPENCODE_WORKSPACE}` instead of hard-coding a specific drive or Windows username. The setup script sets `OPENCODE_WORKSPACE` for the current user and can install the template into the active global config after you approve it.

The key distinction in the configuration is:

- `plugins` enables the Superpowers integration for OpenCode V2.
- `skills` adds the selected skill directories as discovery sources.
- OpenAgents agents/commands/context are discovered from the global config folders installed by the setup script; they are not listed as skills.

OpenCode V2 supports `opencode.json` and `opencode.jsonc`, global configuration at `~/.config/opencode/`, and additional skill source directories. See the official [configuration docs](https://dev.opencode.ai/v2/docs/config/) and [skills docs](https://dev.opencode.ai/v2/docs/skills/). Superpowers' V2 instructions are in its [OpenCode install guide](https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md).

## How to use it day to day

### Skills

Ask OpenCode naturally, and name the skill when you want to be explicit:

- `Use the brainstorming skill to help refine this feature before coding.`
- `Use the systematic-debugging skill. Reproduce the issue before proposing a fix.`
- `Use the huggingface-llm-trainer skill to plan fine-tuning; inspect the hardware and dataset first.`
- `Use the agent-evaluation skill to design an evaluation dataset and scorer plan for my agent.`
- `Use the frontend-ui-engineering skill to review this UI for layout, accessibility, and responsiveness.`

You can ask OpenCode to use the native skill tool to list available skills or load a named skill. Skill selection remains model-driven; installed skills are discoverable but not all loaded into every prompt at once.

### Agents

```powershell
# Start an interactive session in the current project
opencode .

# Ask the plan-first main agent a read-only question
opencode run --agent openagent "Map the project architecture. Do not modify files."

# Ask the coding-focused agent for review only
opencode run --agent opencoder "Review the architecture and list concrete improvements. Do not modify files."
```

For implementation tasks, OpenAgent's intended pattern is: inspect relevant context/standards → propose a plan → wait for approval → implement incrementally → validate → report results. Still review agent plans and tool permissions; do not assume a prompt alone is a security boundary.

### Slash commands

Once the global command files have been installed, test commands inside the OpenCode TUI by typing `/` and selecting a discovered command. The source snapshot contains commands such as `/test`, `/commit`, `/context`, `/optimize`, `/validate-repo`, and `/build-context-system`; specific commands may rely on project files or optional tools.

### Updating skill copies

The checked-in `skills-lock.json` records the source and hash for the selected skill copies. From the workspace root, you can check/update installed project skills with:

```powershell
npx skills update --project --yes
```

Review the Git diff afterwards. To browse or add a skill from a source repo:

```powershell
npx skills add mattpocock/skills --list
npx skills add huggingface/skills --list
npx skills add addyosmani/agent-skills --list
```

Add selected skills with `--skill <name>` rather than installing everything blindly. Preserve support files referenced by a skill, not only `SKILL.md`.

To update a source clone manually:

```powershell
git -C .\addyosmani-agent-skills pull --ff-only
git -C .\mlflow-skills pull --ff-only
git -C .\anthropic-skills pull --ff-only
git -C .\openagents-repo pull --ff-only
```

After updating OpenAgents, rerun `scripts/setup-opencode.ps1` to refresh the global copies; back up and review your local changes first.

## Committing this workspace to your Git repository

This workspace is set up so the outer repository tracks your selected skill copies, lock file, documentation, portable config template, and setup script—**not the full working checkouts of each upstream project**. The source clone folders are ignored and recreated by the setup script. This avoids accidentally nesting Git repositories inside the outer repo.

Before committing, run:

```powershell
git status --short
```

Then add the files you intend to track explicitly:

```powershell
git add README.md AGENTS.md .gitignore skills-lock.json .agents/skills config/README.md config/opencode.jsonc.example scripts/setup-opencode.ps1
git status --short
git commit -m "Document portable OpenCode workspace"
```

If you already staged the cloned upstream folders or the exported global `config/agents`, `config/commands`, `config/context`, unstage them before committing. If you made a fix inside an ignored source clone (especially an OpenAgents plugin fix), it will **not** be saved by the outer repository. Push that change to a fork you control or keep a reviewed patch under a tracked `patches/` folder.

## GitHub hygiene, licenses, and security

- Keep API keys, `.env` files, model credentials, Telegram tokens, local logs, `node_modules`, and the active machine-specific `config/opencode.jsonc` out of Git. Use `config/opencode.jsonc.example` as the portable template.
- The supplied global-config archive includes hard-coded paths under `C:/Users/adity/.config/opencode/`. Those paths are machine-specific and should not be committed as a reusable config. The setup script regenerates the runtime copy from upstream source and rewrites the necessary runtime reference for the current account.
- The root `.gitignore` excludes source clone folders (`addyosmani-agent-skills`, `anthropic-skills`, `mlflow-skills`, `openagents-repo`) because each is its own upstream Git repository and they can be cloned by the setup script. This avoids accidentally adding embedded Git repositories into your main repository.
- If you already ran `git add` on a nested clone before adding `.gitignore`, `.gitignore` will not untrack it automatically. Check `git status` and, if necessary, unstage/remove it from the index carefully (for example, `git rm -r --cached -- <folder>` keeps the local files but removes that folder from the outer repository's index).
- **Anthropic document skills:** The upstream repository identifies `docx`, `pdf`, `pptx`, and `xlsx` as source-available rather than open-source; their individual license files impose additional restrictions on copying and redistribution. This workspace ignores the upstream clone so those files are not distributed from your public repo. Review the upstream terms before storing or redistributing any of those files.
- OpenAgents' optional plugins/tools and skill scripts can execute code. Read their source, install their dependencies deliberately, and don't put API keys directly in Markdown, JSONC, or Git history.
- The attached ZIP snapshot still showed the older V1-style `agent-validator.ts` import (`@opencode-ai/plugin`) and V1-style notification-plugin exports, even though a later fix was reported in chat. The setup script intentionally does not install optional plugin/tool code. Before relying on that plugin on another machine, verify that the fixed version is present; preserve your fix in your own fork or as a patch because the `openagents-repo/` clone is ignored by the outer Git repository.

## Troubleshooting

| Symptom | What to check |
|---|---|
| `/agents` shows only `build` and `plan` | Restart OpenCode; run `opencode debug agents`; confirm `openagent.md` and `opencoder.md` exist in `%USERPROFILE%\.config\opencode\agents`. |
| Skills are missing | Check `OPENCODE_WORKSPACE` in a new terminal (`$env:OPENCODE_WORKSPACE`), then check each configured path exists and contains folders with `SKILL.md`. Ask OpenCode to use its skill tool to list discovered skills. |
| Superpowers skills are missing | Confirm the V2 `plugins` entry is present and the plugin loaded; restart the OpenCode service/session. See the [Superpowers install guide](https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md). |
| OpenAgents installer reports `Installed: 0` | Don't treat a final “Installation complete” banner as success. This workspace uses the local-copy script because the Advanced installer attempt in the inspected setup failed all 68 components. |
| `head`, `ls -la`, or other Unix command syntax fails | You are in PowerShell. Ask the agent to use PowerShell-compatible commands, or run OpenCode from Git Bash/WSL if that is your intended shell. |
| A skill needs an unavailable Python/Node tool or API | Read its `SKILL.md` and referenced docs; install the actual runtime/tool separately and configure credentials via environment variables. |

## Upstream sources

- [obra/superpowers](https://github.com/obra/superpowers)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [huggingface/skills](https://github.com/huggingface/skills)
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
- [mlflow/skills](https://github.com/mlflow/skills)
- [anthropics/skills](https://github.com/anthropics/skills)
- [remcocats/opencode-agents](https://github.com/remcocats/opencode-agents)
- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) (extra skill/tool, separate from the seven repositories above)
