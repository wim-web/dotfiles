---
name: reviewing-codex-workflows
description: Use when reviewing recent Codex tasks for repeated misunderstandings, rework, scope drift, environment friction, missing automation, or durable workflow improvements.
---

# Reviewing Codex Workflows

## Core Principle

Turn observed friction into the smallest durable change, then measure whether
the friction decreases. Usage consumption is never the success metric.

## Evidence Pass

1. List up to 20 recent Codex tasks. Use titles, previews, status, duration, and
   project first.
2. Select at most five representative tasks only when they show corrections,
   repeated attempts, long diagnosis, incomplete outcomes, or repeated work.
3. Read at most eight turns from each representative task and omit command
   output by default. Stop expanding the sample after three evidence-backed
   patterns are established. Exclude unrelated private content.
4. Inspect durable context relevant to the finding: `AGENTS.md`, safe Codex
   configuration keys, personal skills, plugins, MCP servers, automations,
   dotfiles, and tool ownership.
5. Label every statement as observed evidence or inference. Do not count a
   single anecdote as a recurring pattern.

## Improvement Pass

Map each finding to the smallest suitable surface:

| Scope | Surface |
|---|---|
| One task | Prompt or task context |
| Repository convention | Nested or repository `AGENTS.md` |
| Personal cross-project judgment | Global `AGENTS.md` |
| Reusable multi-step workflow | Skill |
| Mechanical enforcement | Hook or deterministic script |
| Scheduled stable check | Automation |
| Live private service data/action | Plugin or MCP connector |
| PATH, runtime, bootstrap, editor | Environment configuration |

List all supported candidates. For each include evidence, observed frequency,
expected effect, implementation effort, regression risk, dependency, and one
command or procedure that verifies the result.

If the user requests implementation, order non-destructive in-scope candidates
by dependency and complete all of them. Do not ask the user to choose among
safe independent improvements. Keep destructive, externally publishing, or
unsupported changes explicitly separate.

## Metrics

Capture a baseline and compare it at the next review:

- correction turns caused by misunderstood intent;
- unrequested scope expansions;
- tasks that rediscover a tool's manager or executable path;
- repeated manual procedures that lack a skill or automation;
- incomplete tasks and recurring environment doctor failures.

Report both the count and sample size. A lower rate matters more than raw Codex
usage.

Finish with bounded evidence. Do not keep searching merely to make the review
exhaustive; unresolved candidates belong in a separate “not established” list.

## Common Mistakes

- Recommending generic audits before reading recent work.
- Treating entertainment or token burn as improvement.
- Asking the user to select one item when all safe items can be processed.
- Moving every rule into global guidance instead of choosing the narrowest
  surface.
- Auto-editing from a scheduled retrospective instead of producing reviewable
  evidence and recommendations.
