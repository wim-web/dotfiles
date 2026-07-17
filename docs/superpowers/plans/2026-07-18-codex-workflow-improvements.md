# Codex Workflow Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Codexの意図誤認を減らす恒久指示と、リモート運用・作業振り返りの再利用可能な個人スキルをchezmoi管理下へ置く。

**Architecture:** `dotfiles` を `~/.codex/AGENTS.md` と個人スキルの正本にする。シェルテストで必須規則と配置を検証し、各スキルは履歴上の失敗例をREDとして記録してから最小の手順を実装する。

**Tech Stack:** chezmoi、Markdown Agent Skills、Bash、Codex App thread tools

---

### Task 1: Codex恒久指示をテスト先行で管理する

**Files:**
- Create: `test/test-codex-guidance.sh`
- Create: `dot_codex/AGENTS.md`
- Modify: `README.md`

- [x] **Step 1: 失敗する配置・内容テストを書く**

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
agents_file="$repo_root/dot_codex/AGENTS.md"

test -f "$agents_file"
grep -Fq '依頼されていない値や設定を別スコープから補完しない' "$agents_file"
grep -Fq 'その前提から導いた提案も破棄' "$agents_file"
grep -Fq '依存関係を付けて全件進める' "$agents_file"
grep -Fq '秘密値を別環境へ移送しない' "$agents_file"
```

- [x] **Step 2: REDを確認する**

Run: `bash test/test-codex-guidance.sh`

Expected: `dot_codex/AGENTS.md` が存在しないため非ゼロ終了。

- [x] **Step 3: 既存規則を保ったAGENTS.mdを追加する**

```markdown
Please provide all answers in Japanese

## 進め方
- 質問には最初に結論で答える
- 明示された対象・場所・実行方法を文字どおり優先する
- 依頼されていない値や設定を別スコープから補完しない
- 必須値が不足しても、秘密値を別環境へ移送しない
- ユーザーが前提を否定したら、その前提から導いた提案も破棄する
- 安全に複数件を処理できる場合は、選択を求めず依存関係を付けて全件進める
```

上記へ現在のGit、リモート実行、Automation、完了確認の規則を欠落なく統合する。

- [x] **Step 4: GREENを確認する**

Run: `bash test/test-codex-guidance.sh`

Expected: 終了コード0。

- [x] **Step 5: READMEへ管理対象と反映手順を書く**

```markdown
## Codex個人設定

`dot_codex/AGENTS.md` と `dot_codex/skills/` をchezmoiで管理する。

```sh
chezmoi diff
chezmoi apply ~/.codex/AGENTS.md ~/.codex/skills
```
```

- [x] **Step 6: コミットする**

```bash
git add test/test-codex-guidance.sh dot_codex/AGENTS.md README.md
git commit -m "feat: manage codex guidance with chezmoi"
```

### Task 2: `running-remote-operations` スキルをRED-GREENで作る

**Files:**
- Create: `test/skill-evals/running-remote-operations.md`
- Create: `dot_codex/skills/running-remote-operations/SKILL.md`
- Create: `dot_codex/skills/running-remote-operations/agents/openai.yaml`

- [x] **Step 1: 履歴上の失敗をRED fixtureとして記録する**

```markdown
# running-remote-operations baseline

Prompt: `mark_update.bash これをoracle-moffにsshして中身を実行させたい`

Observed failure:
- ローカル `.env` の値を依頼なくリモートへ注入した。
- ローカルファイルを標準入力で渡し、プロジェクト規則のscp方式を外した。

Required invariants:
- ローカル対象とリモート対象を最初に特定する。
- 複数行スクリプトはローカルファイルをscpし、実行後に削除する。
- 環境変数・秘密値は明示されない限り移送しない。
- 必須値がなければ不足として報告する。
```

- [x] **Step 2: スキルなしの履歴が不変条件を満たさないことを確認する**

Run: `sed -n '1,120p' test/skill-evals/running-remote-operations.md`

Expected: `Observed failure` が2件ありRED。

- [x] **Step 3: skill-creatorで雛形を初期化する**

```bash
python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/init_skill.py \
  running-remote-operations \
  --path dot_codex/skills \
  --interface 'display_name=Remote Operations' \
  --interface 'short_description=Safely run SSH and SCP operations' \
  --interface 'default_prompt=Run this remote operation while preserving local and remote boundaries.'
```

- [x] **Step 4: 最小のSKILL.mdを書く**

Frontmatterは次を使用する。

```yaml
---
name: running-remote-operations
description: Use when a task runs commands or scripts through SSH or SCP on named remote hosts, especially when local files, remote files, environment variables, secrets, or cleanup boundaries could be confused.
---
```

本文に、対象解決、読み取り確認、scp、リモート実行、cleanup、結果検証、暗黙のsecret移送禁止をこの順で記述する。

- [x] **Step 5: 構造検証と前方テストを行う**

Run: `python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/quick_validate.py dot_codex/skills/running-remote-operations`

Expected: `Skill is valid!`

前方テストでは新規エージェントへfixtureのPromptとスキルパスだけを渡し、4つのRequired invariantsを全て満たすことを確認する。

- [x] **Step 6: コミットする**

```bash
git add test/skill-evals/running-remote-operations.md dot_codex/skills/running-remote-operations
git commit -m "feat: add remote operations skill"
```

### Task 3: `reviewing-codex-workflows` スキルをRED-GREENで作る

**Files:**
- Create: `test/skill-evals/reviewing-codex-workflows.md`
- Create: `dot_codex/skills/reviewing-codex-workflows/SKILL.md`
- Create: `dot_codex/skills/reviewing-codex-workflows/agents/openai.yaml`

- [x] **Step 1: 現在の会話をRED fixtureとして記録する**

```markdown
# reviewing-codex-workflows baseline

Observed failure:
- 改善候補を順に全件扱えるのに、ユーザーへ一件を選ばせた。
- 利用量消費を目的化し、継続的な改善指標を先に置かなかった。

Required output:
- 最近のタスクから事実を収集する。
- 誤解、手戻り、反復、環境摩擦を数える。
- prompt、AGENTS.md、skill、hook、automation、環境設定へ振り分ける。
- 全候補を効果、工数、リスク、検証方法付きで列挙する。
- 安全な候補は依存順に全件進める。
```

- [x] **Step 2: skill-creatorで雛形を初期化する**

```bash
python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/init_skill.py \
  reviewing-codex-workflows \
  --path dot_codex/skills \
  --interface 'display_name=Codex Workflow Review' \
  --interface 'short_description=Find durable improvements from recent Codex work' \
  --interface 'default_prompt=Review recent Codex work and produce durable workflow improvements.'
```

- [x] **Step 3: 最小のSKILL.mdを書く**

```yaml
---
name: reviewing-codex-workflows
description: Use when reviewing recent Codex tasks for repeated misunderstandings, rework, scope drift, environment friction, missing automation, or durable workflow improvements.
---
```

本文は、最大30件のタスク一覧、代表例の詳細確認、事実と推測の分離、改善面の最小化、全件バックログ、実施後の測定を定義する。秘密本文や無関係な個人情報は取得しない。

- [x] **Step 4: 構造検証と前方テストを行う**

Run: `python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/quick_validate.py dot_codex/skills/reviewing-codex-workflows`

Expected: `Skill is valid!`

新規エージェントへfixtureとスキルだけを渡し、Required outputを全て満たすことを確認する。

- [x] **Step 5: コミットする**

```bash
git add test/skill-evals/reviewing-codex-workflows.md dot_codex/skills/reviewing-codex-workflows
git commit -m "feat: add codex workflow review skill"
```

### Task 4: chezmoi反映と週次Automationを作る

**Files:**
- Modify at runtime: `~/.codex/AGENTS.md`
- Create at runtime: `~/.codex/skills/running-remote-operations/`
- Create at runtime: `~/.codex/skills/reviewing-codex-workflows/`
- Create in Codex App: weekly local Automation

- [x] **Step 1: 意図した差分だけか確認する**

Run: `chezmoi diff`

Expected: `~/.codex/AGENTS.md` と2つのskillだけが追加・更新対象。

- [x] **Step 2: chezmoiを適用する**

Run: `chezmoi apply ~/.codex/AGENTS.md ~/.codex/skills/running-remote-operations ~/.codex/skills/reviewing-codex-workflows`

Expected: 終了コード0。

- [x] **Step 3: 週次Automationを作成する**

Codex Appのautomation更新機能へ、`kind=cron`、`status=ACTIVE`、土曜10:00、local、`mac_setting` project、read-only retrospective promptを渡す。promptはdoctor実行、最近のタスク確認、全改善候補の列挙、変更禁止、`automation-log.sh` による直近10回memory管理を必須とする。

- [x] **Step 4: 最終検証する**

```bash
bash test/test-codex-guidance.sh
python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/quick_validate.py dot_codex/skills/running-remote-operations
python3 /Users/wim/.codex/skills/.system/skill-creator/scripts/quick_validate.py dot_codex/skills/reviewing-codex-workflows
chezmoi status
git status --short
```

Expected: テストとvalidatorは成功し、chezmoiとGitはclean。

