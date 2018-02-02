STACK_NAME=$1
DESCRIBE_TAGS=`aws ec2 describe-tags --filters "Name=key,Values=name" "Name=value,Values='$STACK_NAME'"`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$DESCRIBE_TAGS" > "$DIR/all_resources.json"
