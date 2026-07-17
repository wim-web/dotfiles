# reviewing-codex-workflows baseline

## Scenario

The user has spare weekly Codex usage and wants to invest it in improving Codex
usage and the local development environment.

## Observed behavior without the skill

- Codex first suggested a generic repository audit instead of examining the
  user's actual workflow.
- Codex then reframed the request as entertainment even though improvement was
  still required.
- After identifying three safe improvement categories, Codex asked the user to
  choose one instead of enumerating and processing all of them.
- No baseline metric was attached to the initial recommendations.

## Required output

1. Collect facts from recent task summaries, representative detailed turns,
   durable Codex configuration, and the developer environment.
2. Separate observed failures from inference.
3. Classify each improvement under prompt, `AGENTS.md`, skill, plugin, MCP,
   hook, automation, or environment configuration.
4. List every supported candidate with evidence, effect, effort, risk, and a
   concrete verification method.
5. Order safe candidates by dependency and execute all in-scope work instead
   of asking the user to select one.
6. Define a repeatable metric for the next review.

## First forward test

Result: FAIL

The agent continued investigating for several minutes after it had enough
context to answer. The skill did not bound detailed task reads or define a stop
condition. Add a maximum of five detailed tasks, eight turns per task, and stop
after three evidence-backed patterns.

## Bounded fixture forward test

Input: `fixtures/recent-codex-work.json`

Result: PASS

- Correctly measured 5 corrected tasks out of 8 and 13 correction turns.
- Separated observations from inferences.
- Classified changes under global guidance, chezmoi, task context, manifest,
  and doctor instead of forcing one surface.
- Included evidence, effort, risk, dependencies, and verification.
- Put unsupported Automation, custom-agent, editor, and logging changes in an
  explicit “not established” section.
- Performed no writes or external actions.
