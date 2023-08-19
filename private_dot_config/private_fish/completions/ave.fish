# AWS プロファイルのリストを取得する関数
function _aws_profiles
    aws-vault list --profiles
end

function _command
    set -l tokens (commandline -poc)
    test (count $tokens) -eq 2
end

function _sub_command
    set -l tokens (commandline -poc)
    test (count $tokens) -gt 2
end

complete -c ave -n '__fish_is_first_arg' -xa '(_aws_profiles)'
complete -c ave -n '_command' -xa '(__fish_complete_command)'
complete -c ave -n '_sub_command' -xa '(__fish_complete_subcommand --fcs-skip=2)'
