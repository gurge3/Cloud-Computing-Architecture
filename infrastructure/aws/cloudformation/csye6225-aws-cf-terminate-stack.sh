STACK_NAME=$1
echo "Deleting stack $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME"