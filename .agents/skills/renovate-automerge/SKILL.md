---
name: renovate-automerge
description: このリポジトリの Renovate PR を調査し、repo 固有ルールに従ってマージする時に使う。
---

# Renovate Automerge

この skill は、`wim-web/dotfiles` で Renovate が作成した open PR を確認し、以下のルールに従ってマージまたは報告する。

## 対象PR

- 作成者が Renovate の open PR のみを対象にする。
- このリポジトリで観測した Renovate author: `app/renovate`
- commit author として観測した Renovate bot: `renovate[bot]`
- base branch は `main` のみ対象にする。
- Dependabot や人間が作成した PR は対象外。

## 必ず確認すること

明らかなブロック条件があっても、そこで早期終了しない。影響範囲調査を完了してから、マージしてよい / マージしてはいけない / 人間確認が必要、のいずれかを判断する。

- PR title/body
- changed files
- update type
- Renovate が PR 本文に載せた release notes / changelog / compatibility notes
- upstream changelog / release notes / migration guide
- 破壊的変更、deprecated API、設定変更、peer dependency 変更、runtime 要件変更の有無
- 影響範囲: runtime dependency / dev dependency / build tool / CI / Docker / infra / deploy / database
- check status
- merge conflict の有無
- requested changes / 未解決の人間 review comment の有無

## 調査手順

対象 PR ごとに、必ずこの順序で調査してから判定する。

1. `gh pr view PR番号 --json title,body,author,baseRefName,headRefName,isDraft,mergeable,reviewDecision,files,statusCheckRollup,commits,reviews,comments,url` で PR metadata を確認する。
2. `gh pr diff PR番号 --patch` で差分を確認する。
3. Renovate PR 本文の release notes / changelog / compatibility notes を読む。
4. upstream 公式 release notes / changelog / upgrade guide / migration guide を読む。PR 本文だけで済ませない。
5. repo 内で変更対象の参照箇所を検索し、この repo での影響範囲を確認する。
6. ここまで完了してから判定する。

## マージしてよいもの

以下をすべて満たす PR だけを自動マージしてよい。

- author が `app/renovate`、base branch が `main`、draft ではなく、`mergeable` が `MERGEABLE`。
- update type が patch または minor。
- 変更ファイルが次のいずれかだけで、manifest 内の version / ref / pinned SHA の 1 行更新に限られる。
  - `private_dot_config/aquaproj-aqua/aqua.yaml`
  - `.github/workflows/renovate_config_validate.yaml`
- `private_dot_config/aquaproj-aqua/aqua.yaml` で許可する対象は、この repo で aqua により管理している CLI または registry の patch / minor 更新だけ。
  - `aquaproj/aqua-registry`
  - `x-motemen/ghq`
  - `peco/peco`
  - `stedolan/jq`
  - `hashicorp/terraform`
  - `golang/go`
  - `cli/cli`
- `.github/workflows/renovate_config_validate.yaml` で許可する対象は、`rinchsan/renovate-config-validator` action の patch 更新だけ。SHA pin と末尾コメントの version が同じ release を指していることを確認する。
- Renovate PR 本文と upstream 公式 changelog / release notes / migration guide の両方を確認し、この dotfiles repo に破壊的変更、設定変更、runtime 要件変更、利用方法変更の影響がないと判断できる。
- repo 内検索で、変更対象が `aqua.yaml` の package pin、Renovate config validate workflow、または README のローカル反映手順以外に強く結合していない。
- failed / pending check がない。
- requested changes や未解決の人間 review comment がない。

## マージしてはいけないもの

以下に該当する PR は自動マージしない。必要に応じて理由を報告し、人間確認に回す。

- author が `app/renovate` ではない、または base branch が `main` ではない。
- draft、merge conflict あり、`mergeable` が `MERGEABLE` ではない。
- major update。
- `renovate.json`、`.github/workflows/renovate_config_validate.yaml` 以外の workflow、`install.sh`、fish 設定、git 設定、README、source code、migration、database、infra、deploy、Docker、Terraform 設定そのものを変更する PR。
- `private_dot_config/aquaproj-aqua/aqua.yaml` に新しい package を追加する PR、既存 package を削除する PR、registry type を変更する PR。
- `hashicorp/terraform` の minor 更新で、upstream release notes / upgrade notes に backend、state、provider install、plan/apply、environment variable、CLI output 互換性への影響があり、この repo の利用に無関係だと判断できないもの。
- `cli/cli` の minor 更新で、telemetry、auth、extension / skill、config、command behavior の変更があり、利用影響を判断できないもの。
- `golang/go`、`x-motemen/ghq`、`peco/peco`、`stedolan/jq` の更新で、runtime 要件変更、設定形式変更、CLI 互換性変更、deprecated API、破壊的変更の可能性が残るもの。
- GitHub Actions 更新で、Node runtime 要件、permissions、token scope、workflow trigger、action input/output、SHA pin の整合性に疑問が残るもの。
- Renovate PR 本文または upstream 公式 changelog / release notes / migration guide を確認できず、影響範囲を判断できないもの。
- breaking changes / peer dependency 変更 / runtime 要件変更 / 設定変更の可能性が残るもの。
- failed / pending / 必要な check の missing があるもの。
- requested changes や未解決の人間 review comment があるもの。

## check の扱い

- この repo の `main` は確認時点で branch protection がなく、required check も観測されていない。
- `statusCheckRollup` が空であることだけを理由に禁止しない。
- check が存在する場合、すべて成功していることを確認する。failed / pending / cancelled / timed out は禁止。
- GitHub 側に required check が設定された場合、required check の missing は禁止。

## マージ方法

- `gh pr merge PR番号 --squash` で squash merge する。
- squash commit の title は PR title と同じ内容にし、既存履歴と同じく PR 番号が残る GitHub の標準形式に任せる。
- PR branch は Renovate 管理 branch なので、手動で commit / push しない。
- merge 後の branch 削除は GitHub / Renovate の通常挙動に任せる。手動で branch を削除しない。

## post-merge action

- マージ対象の Renovate PR をすべて処理した後に、最後に 1 回だけ repository root で `chezmoi update` を実行する。
- `chezmoi update` の成功条件は exit code 0。
- `chezmoi update` が失敗した場合、追加 action はそこで止め、失敗した command、exit code、主要な stderr / stdout を報告する。
- Renovate PR を 1 件もマージしなかった場合は `chezmoi update` を実行しない。
- release / deploy / `chezmoi update` 以外の local tool update / GitHub comment など、ここに明記していない post-merge action は実行しない。

## 報告

- マージした PR 番号、title、変更対象、update type、確認した upstream 情報を報告する。
- マージしなかったが対応が必要な PR は、PR 番号、title、理由、人間確認ポイントを報告する。
- マージ対象の Renovate PR がない場合は、「対象なし」と報告する。
- `chezmoi update` を実行した場合は、成功 / 失敗を報告する。

## PR コメント

- 自動マージしなかった PR には、次のすべてを満たす場合だけ GitHub comment を残す。
  - 人間確認が必要な具体理由がある。
  - 同じ理由の comment がまだない。
  - コメントがユーザーの代わりに判断を迫る内容ではなく、調査結果と確認ポイントの記録になっている。
- コメントには、確認した release notes / changelog、影響範囲、マージしない理由、人間が見るべき点を簡潔に含める。
- 単に check が pending、ネットワークエラーで upstream を確認できない、一時的に mergeable が unknown、というだけの場合はコメントせず報告に留める。

## 禁止操作

- Renovate branch に commit や push をしない。
- PR を close しない。
- この skill に明記されていない条件の PR はマージしない。
- release、deploy、tag 作成、local tool install、workflow dispatch は実行しない。
