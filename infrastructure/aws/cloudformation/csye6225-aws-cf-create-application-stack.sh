#!/bin/bash
STACK_NAME=$1
NETWORK_STACK_NAME=$2
CICD_STACK_NAME=$3
if [[ $NETWORK_STACK_NAME == "" ]]; then
	echo "Please enter network stack name!"
	exit 1
fi
echo "The stack name you entered: $STACK_NAME"
echo "Current directory: $PWD"
DESCRIBE_NETWORK_RESOURCES=`aws cloudformation describe-stack-resources --stack-name $NETWORK_STACK_NAME`
echo "$DESCRIBE_NETWORK_RESOURCES" > "$PWD/stack_network_resources.json"
while IFS= read -r i; do
	j=($i)
	if [[ ${j[0]} == "AWS::EC2::VPC" ]]; then
		VPC_ID=${j[1]}
		export VPC_ID
		echo "Found VPC: $VPC_ID"
	elif [[ ${j[0]} == "AWS::EC2::InternetGateway" ]]; then
		INTERNET_GATEWAY_ID=${j[1]}
		export INTERNET_GATEWAY_ID
		echo "Found Internet Gateway: $INTERNET_GATEWAY_ID"
	fi
done <<< "$(jq -c -r '.StackResources[] | .ResourceType + " " + .PhysicalResourceId' $PWD/stack_network_resources.json)"

DESCRIBE_CICD_RESOURCES=`aws cloudformation describe-stack-resources --stack-name $CICD_STACK_NAME`
echo "$DESCRIBE_CICD_RESOURCES" > "$PWD/stack_cicd_resources.json"
while IFS= read -r i; do
	j=($i)
	if [[ ${j[0]} == *"TravisCodeDeployServiceRole"* ]]; then
		ROLE_ID=${j[1]}
		export ROLE_ID
		echo "Found ROLE_ID: $ROLE_ID"
	fi
done <<< "$(jq -c -r '.StackResources[] | .LogicalResourceId + " " + .PhysicalResourceId' $PWD/stack_cicd_resources.json)"


##Procedures for exporting JSON template for creating Intenet Gateway
cat <<EOF > "$PWD/csye6225-cf-application.json"
{"AWSTemplateFormatVersion": "2010-09-09",
 "Resources": {
   "IAMProfile$STACK_NAME": {
		"Type": "AWS::IAM::InstanceProfile",
		"Properties": {
			"Roles": ["$ROLE_ID"]
		}
   },
   "Instance$STACK_NAME": {
     "Type": "AWS::EC2::Instance",
	 "DependsOn": "RDSDBInstance$STACK_NAME",
     "Properties": {
       "ImageId" : "ami-66506c1c",
	   "Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-Instance"}],
	   "InstanceType": "t2.micro",
	   "IamInstanceProfile": {
		  "Ref": "IAMProfile$STACK_NAME" 
	   },
	   "KeyName": "secret",
	   "NetworkInterfaces": [{
			"AssociatePublicIpAddress": "true",
		   "DeviceIndex": "0",
		   "GroupSet": [{"Ref": "EC2SecurityGroup$STACK_NAME"}],
		   "SubnetId": {"Ref": "SubnetWebServer$STACK_NAME"}
	   }],
	   "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
                                "#!/bin/bash -xe \n",
                                "sudo apt-get update \n",
                                "sudo apt-get install openjdk-8-jdk -y \n",
                                "sudo apt-get install ruby -y \n",
                                "sudo apt-get install wget -y \n",
                                "sudo apt-get install python -y \n",
								"sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \n",
								"sudo apt-get install -y nodejs \n",
								"sudo npm install npm@latest -g \n",
								"sudo npm install @angular/cli -g \n",
                                "sudo apt-get update \n",
                                "sudo wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install \n",
                                "sudo chmod +x ./install \n",
                                "sudo ./install auto \n",
                                "sudo service codedeploy-agent start \n",
                                "sudo apt-get install tomcat8 -y \n",
								"sudo export DB_USERNAME=root \n",
								"sudo export DB_PASSWORD= \n",
                                "sudo service tomcat8 restart \n"
                            ]
                        ]
                    }
				},
       "DisableApiTermination" : "false",
       "BlockDeviceMappings" : [{
       	"DeviceName": "/dev/sdm",
       	"Ebs" : {
           "VolumeType": "gp2",
           "VolumeSize": "16"
          }
        }, {
       	"DeviceName" : "/dev/sdk",
       	"NoDevice" : {}
        }]
      }
    },"PrivateRouteTable$STACK_NAME": {
   	  "Type": "AWS::EC2::RouteTable",
   	  "Properties": {
   	  	"VpcId": "$VPC_ID",
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-private-route-table"}]
   	  }
   }, "PublicRouteTable$STACK_NAME": {
   	  "Type": "AWS::EC2::RouteTable",
   	  "Properties": {
   	  	"VpcId": "$VPC_ID",
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-public-route-table"}]
   	  }
   }, "deploymentGroup": {
		"Type": "AWS::CodeDeploy::DeploymentGroup",
		"Properties": {
			"ApplicationName": "CodeDeployApplication$CICD_STACK_NAME",
			"Ec2TagFilters": [
				{
					"Key": "Name",
					"Value": "$STACK_NAME-csye6225-Instance",
					"Type": "KEY_AND_VALUE"
				}
			],
			"DeploymentGroupName": "deploymentGroup",
			"DeploymentConfigName": "CodeDeployDefault.AllAtOnce",
			"ServiceRoleArn": "arn:aws:iam::377915458523:role/$ROLE_ID"
   	    }
	  }, "SubnetWebServer$STACK_NAME": {
   	  "Type": "AWS::EC2::Subnet",
   	  "Properties": {
   	  	"VpcId": "$VPC_ID",
		"CidrBlock": "10.0.0.0/24",
		"AvailabilityZone": "us-east-1a",
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-web-server-subnet-table"}]
   	  }
   }, "SubnetDatabase$STACK_NAME": {
   	  "Type": "AWS::EC2::Subnet",
   	  "Properties": {
   	  	"VpcId": "$VPC_ID",
		"CidrBlock": "10.0.1.0/24",
		"AvailabilityZone": "us-east-1b",
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-database-subnet-table"}]
   	  }
   }, "DBSubnetGroup$STACK_NAME": {
   	  "Type": "AWS::RDS::DBSubnetGroup",
   	  "Properties": {
   	  	"DBSubnetGroupDescription": "DB Subnet",
		"SubnetIds": [
		 	{"Ref": "SubnetWebServer$STACK_NAME"},
			{"Ref": "SubnetDatabase$STACK_NAME"}
		],
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-database-subnet-group"}]
   	  }
   }, "PublicTableAssociation$STACK_NAME": {
   	  "Type": "AWS::EC2::SubnetRouteTableAssociation",
   	  "Properties": {
   	  	"RouteTableId": {"Ref": "PublicRouteTable$STACK_NAME"},
		"SubnetId": {"Ref": "SubnetWebServer$STACK_NAME"}
   	  }
   }, "PrivateTableAssociation$STACK_NAME": {
   	  "Type": "AWS::EC2::SubnetRouteTableAssociation",
   	  "Properties": {
   	  	"RouteTableId": {"Ref": "PrivateRouteTable$STACK_NAME"},
		"SubnetId": {"Ref": "SubnetDatabase$STACK_NAME"}
   	  }
   }, "EC2SecurityGroup$STACK_NAME": {
   	  "Type": "AWS::EC2::SecurityGroup",
   	  "Properties": {
   	  	"GroupDescription": "Allow http to client host",
		"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-EC2SecurityGroup"}],
   	  	"VpcId": "$VPC_ID",
   	  	"SecurityGroupIngress": [{
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "22",
   	  		"ToPort": "22",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}, {
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "80",
   	  		"ToPort": "80",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}, {
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "443",
   	  		"ToPort": "443",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}, {
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "3306",
   	  		"ToPort": "3306",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}, {
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "4200",
   	  		"ToPort": "4200",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}, {
   	  		"IpProtocol": "tcp",
   	  		"FromPort": "8080",
   	  		"ToPort": "8080",
   	  		"CidrIp": "0.0.0.0/0"
   	  	}]
   	  }
   }, "RDSDBSecurityGroup$STACK_NAME": {
   	  "Type": "AWS::RDS::DBSecurityGroup",
   	  "Properties": {
   	  	"EC2VpcId": "$VPC_ID",
		"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-RDSDBSecurityGroup"}],
   	  	"DBSecurityGroupIngress": [{
   	  		"EC2SecurityGroupId": { "Ref": "EC2SecurityGroup$STACK_NAME"}
   	  	}],
   	  	"GroupDescription": "Front end access"
   	  }
   }, "Database$STACK_NAME": {
   	  "Type": "AWS::DynamoDB::Table",
   	  "Properties": {
   	  	"TableName": "csye6225",
		"AttributeDefinitions": [
			{
				"AttributeName": "id",
				"AttributeType": "S"
			}
		],
		"KeySchema": [
			{
				"AttributeName": "id",
				"KeyType": "HASH"
			}
		],
		"ProvisionedThroughput": {
			"ReadCapacityUnits": 5,
			"WriteCapacityUnits": 5
		}
   	  }
   }, "RDSDBInstance$STACK_NAME": {
   	  "Type": "AWS::RDS::DBInstance",
   	  "Properties": {
   	  	"DBName": "csye6225",
		"AllocatedStorage": 100,
   	  	"DBInstanceClass": "db.t2.medium",
   	  	"Engine": "MySQL",
   	  	"EngineVersion": "5.6.37",
   	  	"MasterUsername": "root",
   	  	"MasterUserPassword": "rootroot",
   	  	"DBSubnetGroupName": {"Ref": "DBSubnetGroup$STACK_NAME"},
		"DBSecurityGroups": [
			{"Ref": "RDSDBSecurityGroup$STACK_NAME"}
		],
   	  	"PubliclyAccessible": "false"
   	  }
   }, "Route$STACK_NAME": {
   	  "Type": "AWS::EC2::Route",
   	  "Properties": {
   	  	 "RouteTableId": {"Ref": "PublicRouteTable$STACK_NAME"},
   	  	 "DestinationCidrBlock": "0.0.0.0/0",
   	  	 "GatewayId": "$INTERNET_GATEWAY_ID"
   	  }
   }
  }  
}
EOF

##Procedures for creating cloudformation stack with VPC
echo "Creating stack along with all the resources naming $STACK_NAME"
aws cloudformation create-stack --capabilities "CAPABILITY_IAM" --stack-name "$STACK_NAME" --template-body "file://$PWD/csye6225-cf-application.json"
if [[ $? == "0" ]]; then
	echo "Job Finished"
else
	echo "Job Failed"
fi
