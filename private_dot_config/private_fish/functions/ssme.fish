function ssme
    argparse 'r/region=' -- $argv
    
    if test -n "$_flag_region"
        set -x AWS_REGION "$_flag_region"
    end
        
    set --local profile (\
        aws configure list-profiles | peco
    )
    set --local id (ave "$profile" aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].{name:Tags[?Key==`Name`].Value | [0], id: InstanceId}' | jq -r '.[] | "\(.id) \(.name)"' | peco | awk '{print $1}')
    ave "$profile" aws ssm start-session --target "$id"
end
