#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Mirrors the OpenCode setup (opencode.jsonc + OpenAgents files) into the user's
# global Claude Code config (~/.claude). Never deletes; skips anything that exists.

$workspace = (Resolve-Path $PSScriptRoot).Path
$claudeHome = Join-Path $env:USERPROFILE '.claude'
$opencodeHome = Join-Path $env:USERPROFILE '.config\opencode'

Write-Host "Workspace: $workspace"
Write-Host "Global Claude Code config: $claudeHome"

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    throw 'The claude CLI was not found on PATH.'
}

# Same sources as the "skills" array in opencode.jsonc.example.
$skillSources = @(
    '.agents\skills',
    'addyosmani-agent-skills\skills',
    'mlflow-skills',
    'anthropic-skills\skills'
)
# Already provided to the account as synced anthropic-skills:* skills.
$skipSkills = @('claude-api', 'docx', 'pdf', 'pptx', 'xlsx', 'skill-creator')
# Would shadow Claude Code built-ins (/code-review).
$builtinSkillNames = @('code-review')

$summary = [ordered]@{ Linked = @(); Present = @(); Skipped = @() }

# --- Backup -------------------------------------------------------------------
$backup = Join-Path $claudeHome ("backups\openCODE-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup | Out-Null
foreach ($path in @(
        (Join-Path $claudeHome 'settings.json'),
        (Join-Path $env:USERPROFILE '.claude.json'),
        (Join-Path $claudeHome 'CLAUDE.md'),
        (Join-Path $claudeHome 'agents'),
        (Join-Path $claudeHome 'commands'))) {
    if (Test-Path $path) {
        Copy-Item -Path $path -Destination (Join-Path $backup (Split-Path $path -Leaf)) -Recurse -Force
    }
}
Write-Host "Backups saved to: $backup"

# --- Skills (junctions back into this workspace) ------------------------------
$skillsDir = Join-Path $claudeHome 'skills'
New-Item -ItemType Directory -Force $skillsDir | Out-Null

foreach ($source in $skillSources) {
    $sourceDir = Join-Path $workspace $source
    if (-not (Test-Path $sourceDir)) {
        Write-Warning "Skill source missing, skipped: $sourceDir (run setup-opencode.ps1 to clone it)"
        continue
    }
    foreach ($dir in Get-ChildItem -Path $sourceDir -Directory) {
        if (-not (Test-Path (Join-Path $dir.FullName 'SKILL.md'))) { continue }
        if ($skipSkills -contains $dir.Name -and $source -eq 'anthropic-skills\skills') {
            $summary.Skipped += "skill $($dir.Name) (already synced as anthropic-skills:$($dir.Name))"
            continue
        }
        if ($builtinSkillNames -contains $dir.Name) {
            $summary.Skipped += "skill $($dir.Name) from $source (would shadow the built-in /$($dir.Name))"
            continue
        }
        $target = Join-Path $skillsDir $dir.Name
        if (Test-Path $target) {
            $item = Get-Item $target -Force
            if ($item.LinkType -eq 'Junction' -and ($item.Target -replace '\\$', '') -eq $dir.FullName) {
                $summary.Present += "skill $($dir.Name)"
            } else {
                $summary.Skipped += "skill $($dir.Name) (target already exists and is not this junction)"
            }
            continue
        }
        New-Item -ItemType Junction -Path $target -Target $dir.FullName | Out-Null
        $summary.Linked += "skill $($dir.Name)"
    }
}

# --- Global rules (CLAUDE.md imports the OpenCode AGENTS.md) ------------------
$agentsMd = Join-Path $opencodeHome 'AGENTS.md'
$claudeMd = Join-Path $claudeHome 'CLAUDE.md'
$importLine = '@' + $agentsMd.Replace('\', '/')
if (-not (Test-Path $agentsMd)) {
    $summary.Skipped += "CLAUDE.md ($agentsMd not found)"
} elseif ((Test-Path $claudeMd) -and ((Get-Content -Path $claudeMd -Raw) -match [regex]::Escape($importLine))) {
    $summary.Present += 'CLAUDE.md import'
} else {
    $block = "# Global engineering rules (shared with OpenCode)`n$importLine`n"
    if (Test-Path $claudeMd) {
        Add-Content -Path $claudeMd -Value "`n$block" -Encoding UTF8
    } else {
        [System.IO.File]::WriteAllText($claudeMd, $block, [System.Text.UTF8Encoding]::new($false))
    }
    $summary.Linked += 'CLAUDE.md import'
}

# --- OpenAgents agents -> Claude Code subagents --------------------------------
# OpenCode frontmatter (mode/temperature/tools map/permissions) is converted to
# Claude's name/description/tools; permission rules have no per-agent equivalent.
$toolMap = @{
    read = 'Read'; write = 'Write'; edit = 'Edit'; patch = 'Edit'; grep = 'Grep'
    glob = 'Glob'; bash = 'Bash'; task = 'Agent'; webfetch = 'WebFetch'
}

function Convert-OpenCodeAgent([string]$text, [string]$name) {
    $match = [regex]::Match($text, '(?s)\A---\r?\n(.*?)\r?\n---\r?\n?(.*)\z')
    if (-not $match.Success) { return $null }
    $frontmatter = $match.Groups[1].Value -split '\r?\n'
    $body = $match.Groups[2].Value

    $description = $null
    $tools = @()
    $inTools = $false
    foreach ($line in $frontmatter) {
        if ($line -match '^description:\s*(.+)$') { $description = $Matches[1].Trim(); $inTools = $false; continue }
        if ($line -match '^tools:\s*$') { $inTools = $true; continue }
        if ($line -match '^\S') { $inTools = $false; continue }
        if ($inTools -and $line -match '^\s+(\w+):\s*true\s*$') {
            $mapped = $toolMap[$Matches[1].ToLower()]
            if ($mapped -and $tools -notcontains $mapped) { $tools += $mapped }
        }
    }
    if (-not $description) { return $null }

    $out = "---`nname: $name`ndescription: $description`n"
    if ($tools.Count -gt 0) { $out += "tools: $($tools -join ', ')`n" }
    $out += "---`n`n<!-- Converted from OpenCode by setup-claude-code.ps1. OpenCode mode/temperature/permission rules are not enforced here. -->`n`n"
    return $out + $body.TrimStart("`r", "`n")
}

$agentsSrc = Join-Path $opencodeHome 'agents'
$agentsDst = Join-Path $claudeHome 'agents'
if (Test-Path $agentsSrc) {
    New-Item -ItemType Directory -Force $agentsDst | Out-Null
    foreach ($file in Get-ChildItem -Path $agentsSrc -Filter '*.md' -Recurse -File) {
        if ($file.Name -eq 'AGENT.md') { continue }  # readme, not an agent
        $name = $file.BaseName
        $target = Join-Path $agentsDst $file.Name
        if (Test-Path $target) { $summary.Present += "agent $name"; continue }
        $converted = Convert-OpenCodeAgent (Get-Content -Path $file.FullName -Raw) $name
        if (-not $converted) { $summary.Skipped += "agent $name (no parsable frontmatter)"; continue }
        [System.IO.File]::WriteAllText($target, $converted, [System.Text.UTF8Encoding]::new($false))
        $summary.Linked += "agent $name"
    }
} else {
    $summary.Skipped += "agents ($agentsSrc not found)"
}

# --- OpenAgents commands -------------------------------------------------------
# Copied as-is; context.md is renamed because /context is a Claude Code built-in.
$commandRenames = @{ 'context.md' = 'oa-context.md' }
$commandsSrc = Join-Path $opencodeHome 'commands'
$commandsDst = Join-Path $claudeHome 'commands'
if (Test-Path $commandsSrc) {
    foreach ($file in Get-ChildItem -Path $commandsSrc -Filter '*.md' -Recurse -File) {
        $relative = $file.FullName.Substring($commandsSrc.Length + 1)
        if ($relative -notmatch '\\' -and $commandRenames.ContainsKey($file.Name)) { $relative = $commandRenames[$file.Name] }
        $target = Join-Path $commandsDst $relative
        if (Test-Path $target) { $summary.Present += "command $relative"; continue }
        New-Item -ItemType Directory -Force (Split-Path $target -Parent) | Out-Null
        Copy-Item -Path $file.FullName -Destination $target
        $summary.Linked += "command $relative"
    }
} else {
    $summary.Skipped += "commands ($commandsSrc not found)"
}

# --- MCP servers (same as opencode.jsonc "mcp.servers") -----------------------
$mcpServers = [ordered]@{
    'skill-issue' = 'https://skill-issue.in/api/mcp'
    'context7'    = 'https://mcp.context7.com/mcp'
}
foreach ($name in $mcpServers.Keys) {
    & claude mcp get $name *> $null
    if ($LASTEXITCODE -eq 0) { $summary.Present += "mcp $name"; continue }
    & claude mcp add --scope user --transport http $name $mcpServers[$name]
    if ($LASTEXITCODE -ne 0) { throw "claude mcp add failed for $name" }
    $summary.Linked += "mcp $name"
}

# --- Plugins (same as opencode.jsonc "plugins") --------------------------------
$plugin = 'superpowers@claude-plugins-official'
$installed = (& claude plugin list 2>$null) -join "`n"
if ($installed -match [regex]::Escape($plugin)) {
    $summary.Present += "plugin $plugin"
} else {
    & claude plugin install $plugin --scope user
    if ($LASTEXITCODE -ne 0) { throw "claude plugin install failed for $plugin" }
    $summary.Linked += "plugin $plugin"
}

# --- Summary -------------------------------------------------------------------
Write-Host ''
Write-Host "Added: $($summary.Linked.Count)  Already present: $($summary.Present.Count)  Skipped: $($summary.Skipped.Count)"
foreach ($entry in $summary.Skipped) { Write-Host "  skipped: $entry" }
Write-Host ''
Write-Host 'Restart Claude Code, then verify with: claude mcp list; claude plugin list; /agents; /skills'
