function avep
    # pecoでプロファイルを選択し、
    # 選択結果をaveに渡して実行
    set -l profile (
        aws configure list-profiles | peco
    )

    if test -z "$profile"
        return 1
    end

    ave $profile $argv
end
