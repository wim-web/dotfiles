managed by https://www.chezmoi.io/

## chezmoi

本体は`~/.local/share/chezmoi`にあるので、それ以外の箇所にcloneしている場合で反映したい場合はリモートにpushしてから`chezmoi update`する必要がある

面倒なので`chezmoi cd`で移動してそこで編集するほうが楽

## aqua.yamlの更新をローカルに反映する

```
chezmoi update
```
