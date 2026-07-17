---
name: running-remote-operations
description: Use when a task runs commands or scripts through SSH or SCP on named remote hosts, especially when local files, remote files, environment variables, secrets, or cleanup boundaries could be confused.
---

# Running Remote Operations

## Core Principle

Keep local state, transferred artifacts, remote state, and secrets as four
separate scopes. Perform only the transfers the user requested.

## Workflow

1. Resolve the target before changing anything.
   - Identify the host, local path, remote path, interpreter, and expected side
     effects.
   - Check local paths locally and remote paths with a read-only SSH command.
   - If wording is ambiguous, prefer the literal named location; do not invent
     a second source.
2. Check prerequisites in their execution scope.
   - Check remote commands and remote environment on the remote host.
   - Treat missing variables, config, and credentials as missing. Never source
     them from local `.env`, shell state, keychains, or other hosts unless the
     user explicitly requests that transfer.
3. Transfer multi-line code as a file.
   - Create or reuse one exact local file.
   - Create the remote temporary path atomically with `mktemp` on the remote host
     and capture the exact returned path. Never guess, reuse, or replace a
     pre-existing remote path.
   - Use `scp` to that newly created path, then execute it with `ssh`.
   - Capture the remote exit status and relevant bounded output before cleanup.
   - Do not pipe script bodies, use heredocs over SSH, or embed script text in
     a remote shell command.
4. Remove only the transferred temporary file.
   - Run cleanup as a finally-style step after `mktemp` succeeds, whether copy,
     execution, output capture, or a later check fails or is interrupted.
   - Verify the cleanup target equals the resolved temporary path.
   - Remove only the exact path returned by that `mktemp` command.
   - Report whether cleanup succeeded. Do not remove pre-existing user files.
5. Verify the requested effect.
   - Evaluate the captured exit status and output after cleanup is attempted.
   - Verify the actual effect separately when exit zero does not prove it.
   - Continue independent checks after one failure and aggregate results.

## Quick Reference

| Situation | Action |
|---|---|
| Local script, remote execution | Inspect locally → `scp` → execute remotely → remove transferred copy |
| Script already remote | Inspect and execute that remote path; do not transfer a local namesake |
| Remote prerequisite missing | Report the missing prerequisite; do not import a local substitute |
| Secret transfer explicitly requested | Use the narrowest non-logging channel and state its lifetime |
| Exit code is zero but outcome is external | Verify the external outcome before claiming completion |

## Example

For “run local `mark_update.bash` on `oracle-moff`,” first confirm the local
file and remote prerequisites. If `WEBHOOK_URL` is absent remotely, report that
fact. Do not read a local `.env`. Once prerequisites are satisfied, copy the
script to a validated temporary remote path, execute it, verify the effect, and
remove only that copy.

## Common Mistakes

- Streaming a local script through SSH because it is shorter.
- Treating a same-named local and remote file as interchangeable.
- Moving environment values to make a command succeed without authorization.
- Calling an HTTP redirect or exit zero proof of the requested business effect.
- Hiding partial failures after other hosts or checks succeed.
