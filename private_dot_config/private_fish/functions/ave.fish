function ave
    # SSO一時クレデンシャルを取得し、
    # aws-vault exec と同じく子プロセスの環境へ注入して実行
    set -l profile $argv[1]
    set -l cmd $argv[2..-1]

    if test -z "$profile"; or test (count $cmd) -eq 0
        echo "usage: ave <profile> <command...>" 1>&2
        return 1
    end

    # 既存のSSOキャッシュからexportを試し、
    # 失効していれば sso login で更新して再取得
    set -l creds (aws configure export-credentials --profile "$profile" --format env 2>/dev/null)
    if test $status -ne 0; or test (count $creds) -eq 0
        aws sso login --profile "$profile" >/dev/null
        or return $status
        set creds (aws configure export-credentials --profile "$profile" --format env)
        or return $status
    end

    # `export KEY=VALUE` の行を `env` に渡せる
    # "KEY=VALUE" 配列へ整形
    set -l envvars
    for line in $creds
        set -l clean (string replace -r '^export ' '' -- $line)
        set envvars $envvars $clean
    end

    # aws-vault互換の環境変数を追加
    # - AWS_SECURITY_TOKEN: 一部SDKが参照する旧名トークン
    # - AWS_VAULT/AWS_PROFILE: 実行元プロファイルの明示
    set -l session_line (string match -r '^export AWS_SESSION_TOKEN=.*' -- $creds)
    if test -n "$session_line"
        set -l session_token (string replace -r '^export AWS_SESSION_TOKEN=' '' -- $session_line)
        set envvars $envvars "AWS_SECURITY_TOKEN=$session_token"
    end

    set envvars $envvars "AWS_VAULT=$profile" "AWS_PROFILE=$profile"

    # profileのregionを注入（CLI/SDKが明示値を優先するため）
    set -l region (aws configure get region --profile "$profile" 2>/dev/null)
    if test -n "$region"
        set envvars $envvars "AWS_REGION=$region" "AWS_DEFAULT_REGION=$region"
    end

    # envに渡して対象コマンドだけへ限定的に注入
    command env $envvars $cmd
end
