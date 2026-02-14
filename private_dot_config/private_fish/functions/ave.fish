function ave
    # SSO一時クレデンシャルを取得し、
    # 子プロセスの環境へ注入して実行
    set -l profile $argv[1]
    set -l cmd $argv[2..-1]

    if test -z "$profile"; or test (count $cmd) -eq 0
        echo "usage: ave <profile> <command...>" 1>&2
        return 1
    end

    # 既存のSSOキャッシュからexportを試し、
    # 失効していれば sso login で更新して再取得
    set -l creds (aws configure export-credentials --profile "$profile" --format fish 2>/dev/null)
    if test $status -ne 0; or test (count $creds) -eq 0
        aws sso login --profile "$profile" >/dev/null
        or return $status
        set creds (aws configure export-credentials --profile "$profile" --format fish)
        or return $status
    end

    # `set -gx KEY "VALUE"` の行を `env` に渡せる
    # "KEY=VALUE" 配列へ整形
    set -l envvars
    for line in $creds
        set -l parts (string match -r --groups-only '^set -gx ([^ ]+) "(.*)"$' -- $line)
        if test (count $parts) -eq 2
            set envvars $envvars "$parts[1]=$parts[2]"
        end
    end

    set envvars $envvars "AWS_PROFILE=$profile"

    # profileのregionを注入（CLI/SDKが明示値を優先するため）
    set -l region (aws configure get region --profile "$profile" 2>/dev/null)
    if test -n "$region"
        set envvars $envvars "AWS_REGION=$region" "AWS_DEFAULT_REGION=$region"
    end

    # envに渡して対象コマンドだけへ限定的に注入
    command env $envvars $cmd
end
