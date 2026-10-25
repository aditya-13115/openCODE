
## Automatic Skill and Agent Selection

### Skills

- Before specialized work, consider the available skills and select those relevant to the user's task.
- Use the native skill tool to load relevant `SKILL.md` instructions before following a specialized workflow.
- Prefer skills whose descriptions closely match the task. Use multiple skills when their workflows complement each other.
- Do not load every available skill or read unrelated skill files. Load skills on demand.
- Follow the selected skill's instructions, including its referenced scripts, documentation, templates, and other supporting files when needed.
- Do not force the use of a skill when it does not add value. If no relevant skill exists, proceed using the normal workflow.
- Check applicable permissions and project instructions before using skill-provided tools or scripts.

### Agents and Delegation

- Consider delegating specialized or independent subtasks to the most relevant available subagent when doing so improves quality, efficiency, or review coverage.
- Select subagents based on their descriptions, expertise, and applicable permissions.
- Use the appropriate available delegation tool; do not assume a particular subagent exists without checking what is available.
- Prefer focused subtasks with clear inputs and expected outputs. Review delegated results before relying on them.
- Avoid unnecessary delegation for simple tasks or work that is easier to complete directly.
- Follow the main agent's safety, validation, and approval requirements when coordinating subagents.

### Reporting and Verification

- Do not claim that a skill was loaded, an agent was invoked, or a tool was used unless it actually happened.
- Do not claim that tests or validation passed unless they were actually run and the results were checked.
- When a task requires a specialized workflow, briefly identify the relevant skill or agent when useful to explain the approach.
