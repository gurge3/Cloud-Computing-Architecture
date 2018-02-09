STACK_NAME=$1
echo "The stack name you entered: $STACK_NAME"
echo "Current directory: $PWD"

##Procedures for exporting JSON template for creating Intenet Gateway
cat <<EOF > "$PWD/csye6225-cf-application.json"
{"AWSTemplateFormatVersion": "2010-09-09",
 "Resources": {
   "Instance$STACK_NAME": {
     "Type": "AWS::EC2::Instance", 
     "Properties": {
       "ImageId" : "ami-66506c1c",
       "DisableApiTermination" : "false",
       "BlockDeviceMappings" : [{
       	"DeviceName": "/dev/sdm",
       	"Ebs" : {
           "VolumeType": "gp2",
           "VolumeSize": "20"
          }
        }, {
       	"DeviceName" : "/dev/sdk",
       	"NoDevice" : {}
        }]
      }
    }
  }  
}
EOF

##Procedures for creating cloudformation stack with VPC
echo "Creating stack along with all the resources naming $STACK_NAME"
aws cloudformation create-stack --stack-name "$STACK_NAME" --template-body "file://$PWD/csye6225-cf-application.json"
echo "Job Finished"