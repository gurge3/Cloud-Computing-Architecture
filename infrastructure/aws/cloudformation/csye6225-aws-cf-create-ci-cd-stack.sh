#!/bin/bash
STACK_NAME=$1
echo "The stack name you entered: $STACK_NAME"
echo "Current directory: $PWD"

##Procedures for exporting JSON template for creating Intenet Gateway
cat <<EOF > "$PWD/cs6225-aws-cf-create-ci-cd.json"
{"AWSTemplateFormatVersion": "2010-09-09",
 "Resources": {
   "IAMPolicyForEC2CodeDeploy$STACK_NAME": {
     "Type": "AWS::IAM::Policy", 
     "Properties": {
       "PolicyName": "IAMPolicyForEC2CodeDeploy$STACK_NAME",
       "Roles": [{
           "Ref": "CodeDeployEC2ServiceRole$STACK_NAME"
       }],
       "PolicyDocument": {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Action": [
                       "s3:*",
                       "ec2:*",
                       "codedeploy:*"
                   ],
                   "Effect": "Allow",
                   "Resource": "arn:aws:codedeploy:us-east-1:377915458523:application:S3BuildArtifactBucket$STACK_NAME"
               }
           ]
       }
     }
   } ,"IAMPolicyForS3Travis$STACK_NAME": {
     "Type": "AWS::IAM::Policy", 
     "Properties": {
       "PolicyName": "IAMPolicyForS3Travis$STACK_NAME",
       "Roles": [{
           "Ref": "TravisCodeDeployServiceRole$STACK_NAME"
       }],
       "PolicyDocument": {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": [
                       "s3:*",
                       "codedeploy:*",
                       "ec2:*"
                   ],
                   "Resource": [
                       "arn:aws:codedeploy:us-east-1:377915458523:application:S3BuildArtifactBucket$STACK_NAME"
                   ]
               }
           ]
       }
     }
   },"TravisCodeDeployPolicy$STACK_NAME": {
   	  "Type": "AWS::IAM::Policy",
   	  "Properties": {
   	  	"PolicyName": "TravisCodeDeployPolicy$STACK_NAME",
        "Roles": [{
            "Ref": "TravisCodeDeployServiceRole$STACK_NAME"
        }],
        "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:*",
                        "ec2:*",
                        "codedeploy:*"
                    ],
                    "Resource": [
                        "*"
                    ]
                }
            ]
        }
      }
   	}, "CodeDeployEC2ServiceRole$STACK_NAME": {
           "Type": "AWS::IAM::Role",
           "Properties": {
               "AssumeRolePolicyDocument": {
                   "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": [
                                "sts:AssumeRole"
                            ],
                            "Effect": "Allow",
                            "Principal": {
                                "Service": [
                                    "s3.amazonaws.com",
                                    "ec2.amazonaws.com",
                                    "codedeploy.amazonaws.com"
                                ]
                            }
                        }
                    ]
               },
               "RoleName": "CodeDeployEC2ServiceRole$STACK_NAME"
           }
    }, "TravisCodeDeployServiceRole$STACK_NAME": {
        "Type": "AWS::IAM::Role",
        "Properties": {
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": [
                                "codedeploy.amazonaws.com",
                                "ec2.amazonaws.com"
                            ]
                        },
                        "Action": [
                            "sts:AssumeRole"
                        ]
                    }
                ] 
            }
        }
    }, "S3BuildArtifactBucket$STACK_NAME": {
        "Type": "AWS::S3::Bucket",
        "Properties": {
            "BucketName": "code-deploy.csye6225-spring2018-wux.tld"
        }
    }, "CodeDeployApplication$STACK_NAME": {
        "Type": "AWS::CodeDeploy::Application",
        "Properties": {
            "ApplicationName": "CodeDeployApplication$STACK_NAME"
        }
    }
  }
}
EOF

##Procedures for creating cloudformation stack with VPC
echo "Creating stack along with all the resources naming $STACK_NAME"
aws cloudformation create-stack --capabilities "CAPABILITY_NAMED_IAM" --stack-name "$STACK_NAME" --template-body "file://$PWD/cs6225-aws-cf-create-ci-cd.json"
if [[ $? == "0" ]]; then
	echo "Job Finished"
else
	echo "Job Failed"
fi