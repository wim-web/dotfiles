managed by https://www.chezmoi.io/

## chezmoi

本体は`~/.local/share/chezmoi`にあるので、それ以外の箇所にcloneしている場合で反映したい場合はリモートにpushしてから`chezmoi update`する必要がある

面倒なので`chezmoi cd`で移動してそこで編集するほうが楽

## aqua.yamlの更新をローカルに反映する

```
chezmoi update
```

## Codex個人設定

`dot_codex/AGENTS.md` と `dot_codex/skills/` をchezmoiで管理する。

変更を確認してから反映する。

```sh
chezmoi diff
chezmoi apply ~/.codex/AGENTS.md ~/.codex/skills
```
