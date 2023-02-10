function avl
    set --local p (aws-vault list --profiles | peco)
    if string length -q -- $p
        open -na "Google Chrome" --args --user-data-dir=$HOME/Library/Application\ Support/Google/Chrome/aws-vault/"$p" $(aws-vault login "$p" --stdout)
    end
end
