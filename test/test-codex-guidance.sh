#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
agents_file="$repo_root/dot_codex/AGENTS.md"
remote_skill_agent="$repo_root/dot_codex/skills/running-remote-operations/agents/openai.yaml"
review_skill_agent="$repo_root/dot_codex/skills/reviewing-codex-workflows/agents/openai.yaml"
remote_skill="$repo_root/dot_codex/skills/running-remote-operations/SKILL.md"
review_skill="$repo_root/dot_codex/skills/reviewing-codex-workflows/SKILL.md"

assert_contains() {
    local expected="$1"
    grep -Fq "$expected" "$agents_file"
}

test -f "$agents_file"
assert_contains '依頼されていない値や設定を別スコープから補完しない'
assert_contains 'その前提から導いた提案も破棄'
assert_contains '依存関係を付けて全件進める'
assert_contains '秘密値を別環境へ移送しない'
assert_contains '質問されたら、まず質問に即答してから作業を続ける'
assert_contains 'ssh 越しに複数行スクリプトを heredoc で渡さない'
assert_contains '/Users/wim/.codex/bin/automation-log.sh <automation-id>'

grep -Fq '$running-remote-operations' "$remote_skill_agent"
grep -Fq '$reviewing-codex-workflows' "$review_skill_agent"
grep -Fq 'Create the remote temporary path atomically with `mktemp` on the remote host' "$remote_skill"
grep -Fq 'Remove only the exact path returned by that `mktemp` command' "$remote_skill"
grep -Fq 'Never retrieve or display secret contents' "$review_skill"

managed_paths="$(chezmoi -S "$repo_root" managed)"
[[ "$managed_paths" == *'.codex/AGENTS.md'* ]]
[[ "$managed_paths" == *'.codex/skills/running-remote-operations/SKILL.md'* ]]
[[ "$managed_paths" == *'.codex/skills/reviewing-codex-workflows/SKILL.md'* ]]
! grep -Eq '^(\.github|README\.md|install\.sh|renovate\.json|docs|test)(/|$)' <<< "$managed_paths"
