STACK_NAME=$1
echo "The stack name you entered: $STACK_NAME"
echo "Current directory: $PWD"

##Procedures for exporting JSON template for creating Intenet Gateway
cat <<EOF > "$PWD/resources.json"
{"AWSTemplateFormatVersion": "2010-09-09",
 "Resources": {
   "InternetGateway$STACK_NAME": {
     "Type": "AWS::EC2::InternetGateway", 
     "Properties": {
       "Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-InternetGateway"}]
     }
   }
  ,"VPC$STACK_NAME": {
     "Type": "AWS::EC2::VPC", 
     "Properties": {
       "CidrBlock": "10.0.0.0/16",
       "Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-vpc"}]
     }
   },"AttachedGateway$STACK_NAME": {
   	  "Type": "AWS::EC2::VPCGatewayAttachment",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
   	  	"InternetGatewayId": {"Ref": "InternetGateway$STACK_NAME"}
   	  }
   }
  }  
}
EOF

##Procedures for creating cloudformation stack with VPC
echo "Creating stack along with all the resources naming $STACK_NAME"
aws cloudformation create-stack --stack-name "$STACK_NAME" --template-body "file://$PWD/resources.json"
echo "Job Finished"
