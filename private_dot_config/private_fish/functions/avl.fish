function avl
    # SSO一時クレデンシャルでAWSコンソールを開く
    # aws-vault login と同じ federation API フローを再現
    if not type -q jq; or not type -q curl
        echo "avl requires jq and curl" 1>&2
        return 1
    end

    set -l profile (aws configure list-profiles | peco)
    if test -z "$profile"
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

    # exportされた3値を抽出
    # - AccessKeyId
    # - SecretAccessKey
    # - SessionToken
    set -l access_key
    set -l secret_key
    set -l session_token
    for line in $creds
        set -l clean (string replace -r '^export ' '' -- $line)
        set -l parts (string split -m 1 '=' -- $clean)
        if test (count $parts) -ge 2
            switch $parts[1]
                case AWS_ACCESS_KEY_ID
                    set access_key $parts[2]
                case AWS_SECRET_ACCESS_KEY
                    set secret_key $parts[2]
                case AWS_SESSION_TOKEN
                    set session_token $parts[2]
            end
        end
    end

    if test -z "$access_key"; or test -z "$secret_key"; or test -z "$session_token"
        return 1
    end

    # federation APIのgetSigninTokenに渡す
    # Session JSONをURLエンコードし、返却されたSigninTokenで
    # コンソール向けログインURLを組み立て
    set -l session_json (jq -n --arg ak "$access_key" --arg sk "$secret_key" --arg st "$session_token" '{sessionId:$ak,sessionKey:$sk,sessionToken:$st}')
    set -l session_enc (printf '%s' $session_json | jq -sRr @uri)
    set -l token_json (curl -s "https://signin.aws.amazon.com/federation?Action=getSigninToken&SessionDuration=43200&Session=$session_enc")
    set -l signin_token (printf '%s' $token_json | jq -r .SigninToken)
    if test -z "$signin_token"; or test "$signin_token" = "null"
        return 1
    end

    set -l destination (printf '%s' 'https://console.aws.amazon.com/' | jq -sRr @uri)
    set -l token_enc (printf '%s' $signin_token | jq -sRr @uri)
    set -l login_url "https://signin.aws.amazon.com/federation?Action=login&Destination=$destination&SigninToken=$token_enc"

    # プロファイル毎にChromeのユーザーデータを分けて起動
    open -na "Google Chrome" --args --user-data-dir="$HOME/Library/Application Support/Google/Chrome/aws-vault/$profile" "$login_url"
end
