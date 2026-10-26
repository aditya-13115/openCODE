#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$workspace = (Resolve-Path $PSScriptRoot).Path
$workspaceForConfig = $workspace.Replace('\', '/')
$globalConfig = Join-Path $env:USERPROFILE '.config\opencode'
$template = Join-Path $workspace 'opencode.jsonc.example'

Write-Host "Workspace: $workspace"
Write-Host "Global OpenCode config: $globalConfig"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows and ensure git.exe is on PATH.'
}
if (-not (Test-Path $template)) {
    throw "Missing config template: $template"
}

# Fetch source repositories only when absent. Existing directories are never deleted.
$clones = @(
    @{ Name = 'addyosmani-agent-skills'; Url = 'https://github.com/addyosmani/agent-skills.git'; Check = 'skills' },
    @{ Name = 'anthropic-skills'; Url = 'https://github.com/anthropics/skills.git'; Check = 'skills' },
    @{ Name = 'mlflow-skills'; Url = 'https://github.com/mlflow/skills.git'; Check = 'mlflow-onboarding' },
    @{ Name = 'openagents-repo'; Url = 'https://github.com/remcocats/opencode-agents.git'; Check = '.opencode' }
)

foreach ($item in $clones) {
    $target = Join-Path $workspace $item.Name
    $expected = Join-Path $target $item.Check

    if (-not (Test-Path $target)) {
        Write-Host "Cloning $($item.Name)..."
        & git clone $item.Url $target
        if ($LASTEXITCODE -ne 0) { throw "git clone failed for $($item.Name)" }
    }

    if (-not (Test-Path $expected)) {
        throw "Folder '$target' exists but the expected path '$expected' is missing. Inspect/rename it manually; the script will not delete it."
    }
}

# Set a portable root variable for the config's {env:OPENCODE_WORKSPACE} skill paths.
[Environment]::SetEnvironmentVariable('OPENCODE_WORKSPACE', $workspaceForConfig, 'User')
$env:OPENCODE_WORKSPACE = $workspaceForConfig

$sourceRoot = Join-Path $workspace 'openagents-repo\.opencode'
$sourceMap = @(
    @{ Source = (Join-Path $sourceRoot 'agent'); DestName = 'agents' },
    @{ Source = (Join-Path $sourceRoot 'command'); DestName = 'commands' },
    @{ Source = (Join-Path $sourceRoot 'context'); DestName = 'context' }
)

foreach ($item in $sourceMap) {
    if (-not (Test-Path $item.Source)) {
        throw "OpenAgents source folder missing: $($item.Source)"
    }
}

$replaceConfig = Read-Host 'Install OpenAgents agents/commands/context globally? Existing folders will be backed up first. Type YES to continue'
if ($replaceConfig -cne 'YES') {
    Write-Host 'No global files were copied. OPENCODE_WORKSPACE was set for this user. Re-run the script and type YES to install the OpenAgents files.'
    return
}

New-Item -ItemType Directory -Force $globalConfig | Out-Null
$backup = Join-Path $globalConfig ("backups\openCODE-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup | Out-Null

foreach ($name in @('agents', 'commands', 'context')) {
    $existing = Join-Path $globalConfig $name
    if (Test-Path $existing) {
        Copy-Item -Path $existing -Destination (Join-Path $backup $name) -Recurse -Force
    }
}
$activeConfig = Join-Path $globalConfig 'opencode.jsonc'
if (Test-Path $activeConfig) {
    Copy-Item -Path $activeConfig -Destination (Join-Path $backup 'opencode.jsonc') -Force
}
Write-Host "Backups saved to: $backup"

foreach ($item in $sourceMap) {
    $destination = Join-Path $globalConfig $item.DestName
    New-Item -ItemType Directory -Force $destination | Out-Null
    Copy-Item -Path (Join-Path $item.Source '*') -Destination $destination -Recurse -Force
}

# In the global OpenAgent, references to .opencode/context are intended to resolve
# to the globally-installed context standards. Leave system-builder and commands
# unchanged because those also discuss creating/validating project-local contexts.
$openAgent = Join-Path $globalConfig 'agents\openagent.md'
if (Test-Path $openAgent) {
    $globalContext = (Join-Path $globalConfig 'context').Replace('\', '/')
    $oldText = Get-Content -Path $openAgent -Raw
    $newText = $oldText.Replace('.opencode/context/', "$globalContext/")
    if ($newText -ne $oldText) {
        [System.IO.File]::WriteAllText($openAgent, $newText, [System.Text.UTF8Encoding]::new($false))
    }
}

$replaceJson = Read-Host 'Replace the active global opencode.jsonc with opencode.jsonc.example? This replaces its settings after backup. Type YES to continue'
if ($replaceJson -ceq 'YES') {
    Copy-Item -Path $template -Destination $activeConfig -Force
    Write-Host 'Installed the portable OpenCode config template.'
} else {
    Write-Warning 'The active opencode.jsonc was not changed. Merge the plugins and skills keys from opencode.jsonc.example manually.'
}

Write-Host ''
Write-Host 'Setup finished.'
Write-Host 'Restart your terminal/OpenCode before testing so the user environment variable is available.'
Write-Host 'Verify agents with: opencode debug agents'
Write-Host 'Verify the workspace variable in a new PowerShell window with: $env:OPENCODE_WORKSPACE'
