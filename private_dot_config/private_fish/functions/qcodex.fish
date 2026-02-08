function qcodex
    set s (ghq list -p | peco)
    if test -z "$s"
        return 1
    end
    codex app $s
end
