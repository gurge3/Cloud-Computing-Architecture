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
   "LaunchConfiguration$STACK_NAME": {
     "Type": "AWS::AutoScaling::LaunchConfiguration",
     "Properties": {
       "ImageId" : "ami-66506c1c",
	   "AssociatePublicIpAddress": true,
	   "InstanceType": "t2.micro",
	   "IamInstanceProfile": {
		  "Ref": "IAMProfile$STACK_NAME" 
	   },
	   "SecurityGroups": [{
		   "Ref":"EC2SecurityGroup$STACK_NAME"
	   }],
	   "KeyName": "secret",
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
								"sudo touch /tmp/awslogs.conf \n",
                                "sudo echo '[general]' > /tmp/awslogs.conf \n",
                                "sudo echo 'state_file = /var/awslogs/agent-state' >> /tmp/awslogs.conf \n",
                                "sudo echo '[logstream1]' >> /tmp/awslogs.conf \n",
                                "sudo echo 'file = /var/lib/tomcat8/logs/catalina.out' >> /tmp/awslogs.conf \n",
                                "sudo echo 'log_group_name = csye6225-webapp' >> /tmp/awslogs.conf \n",
                                "sudo echo 'log_stream_name = csye6225-webapp' >> /tmp/awslogs.conf \n",
                                "sudo echo 'datetime_format = %d/%b/%Y:%H:%M:%S' >> /tmp/awslogs.conf \n",
                                "sudo curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O \n",
								"sudo python ./awslogs-agent-setup.py -n -r us-east-1 -c /tmp/awslogs.conf || error_exit 'Failed to run CloudWatch Logs agent setup' \n",
								"cd /etc/systemd/system \n",
                                "sudo touch awslogs.service \n",
                                "sudo echo '[Unit]' >> awslogs.service \n",
                                "sudo echo 'Description=Service for CloudWatch Logs agent' >> awslogs.service \n",
                                "sudo echo 'After=rc-local.service' >> awslogs.service \n",
                                "sudo echo '[Service]' >> awslogs.service \n",
                                "sudo echo 'Type=simple' >> awslogs.service \n",
                                "sudo echo 'Restart=always' >> awslogs.service \n",
                                "sudo echo 'KillMode=process' >> awslogs.service \n",
                                "sudo echo 'TimeoutSec=infinity' >> awslogs.service \n",
                                "sudo echo 'PIDFile=/var/awslogs/state/awslogs.pid' >> awslogs.service \n",
                                "sudo echo 'ExecStart=/var/awslogs/bin/awslogs-agent-launcher.sh --start --background --pidfile $PIDFILE --user awslogs --chuid awslogs &amp;' >> awslogs.service \n",
                                "sudo echo '[Install]' >> awslogs.service \n",
                                "sudo echo 'WantedBy=multi-user.target' >> awslogs.service \n",
                                "sudo systemctl start awslogs.service \n",
								"sudo systemctl enable awslogs.service \n",
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
				}
      }
    }, "AutoScalingGroup$STACK_NAME": {
   	  "Type": "AWS::AutoScaling::AutoScalingGroup",
   	  "Properties": {
		 "VPCZoneIdentifier": [{
			"Ref": "SubnetWebServer$STACK_NAME"
		 }],
   	  	 "Cooldown": "60",
		 "LaunchConfigurationName": {
			 "Ref": "LaunchConfiguration$STACK_NAME"
		 },
		 "MinSize": "3",
		 "MaxSize": "7",
		 "DesiredCapacity": "3",
		 "AutoScalingGroupName": "AutoScalingGroup",
		 "Tags": [{
			"Key" : "Name",
			"Value" : "EC2-1",
			"PropagateAtLaunch" : "true"
      	  }, {
			"Key" : "Name2",
			"Value" : "EC2-2",
			"PropagateAtLaunch" : "true"
      	  },
		  {
			"Key" : "Name3",
			"Value" : "EC2-3",
			"PropagateAtLaunch" : "true"
      	  },
		  {
			"Key" : "Name4",
			"Value" : "EC2-4",
			"PropagateAtLaunch" : "true"
      	  },
		  {
			"Key" : "Name5",
			"Value" : "EC2-5",
			"PropagateAtLaunch" : "true"
      	  },
		  {
			"Key" : "Name6",
			"Value" : "EC2-6",
			"PropagateAtLaunch" : "true"
      	  },
		  {
			"Key" : "Name7",
			"Value" : "EC2-7",
			"PropagateAtLaunch" : "true"
      	  }]
	   }
   }, "WebServerScaleUpPolicy$STACK_NAME": {
   	  "Type": "AWS::AutoScaling::ScalingPolicy",
   	  "Properties": {
   	  	"AdjustmentType": "ChangeInCapacity",
      	"AutoScalingGroupName": {
          "Ref": "AutoScalingGroup$STACK_NAME"
      	},
      	"Cooldown": "60",
      	"ScalingAdjustment": "1"
   	  }
   }, "WebServerScaleDownPolicy$STACK_NAME": {
   	  "Type": "AWS::AutoScaling::ScalingPolicy",
   	  "Properties": {
   	  	"AdjustmentType": "ChangeInCapacity",
      	"AutoScalingGroupName": {
          "Ref": "AutoScalingGroup$STACK_NAME"
      	},
      	"Cooldown": "60",
      	"ScalingAdjustment": "-1"
   	  }
   }, "CPUAlarmHigh$STACK_NAME": {
   	  "Type": "AWS::CloudWatch::Alarm",
   	  "Properties": {
   	  	"AlarmDescription": "Scale-up if CPU > 90% for 10 minutes",
      	"MetricName": "CPUUtilization",
      	"Namespace": "AWS/EC2",
      	"Statistic": "Average",
      	"Period": "300",
      	"EvaluationPeriods": "2",
      	"Threshold": "90",
      	"AlarmActions": [
        	{
          		"Ref": "WebServerScaleUpPolicy$STACK_NAME"
        	}
      	],
		"Dimensions": [
		  {
			"Name": "AutoScalingGroupName",
			"Value": {
				"Ref": "AutoScalingGroup$STACK_NAME"
			}
		  }
		],
      	"ComparisonOperator": "GreaterThanThreshold"
   	  }
   }, "CPUAlarmLow$STACK_NAME": {
   	  "Type": "AWS::CloudWatch::Alarm",
   	  "Properties": {
   	  	"AlarmDescription": "Scale-up if CPU < 70% for 10 minutes",
      	"MetricName": "CPUUtilization",
      	"Namespace": "AWS/EC2",
      	"Statistic": "Average",
      	"Period": "300",
      	"EvaluationPeriods": "2",
      	"Threshold": "70",
      	"AlarmActions": [
        	{
          		"Ref": "WebServerScaleDownPolicy$STACK_NAME"
        	}
      	],
		"Dimensions": [
		  {
			"Name": "AutoScalingGroupName",
			"Value": {
				"Ref": "AutoScalingGroup$STACK_NAME"
			}
		  }
		],
      	"ComparisonOperator": "LessThanThreshold"
   	  }
   }, "deploymentGroup": {
		"Type": "AWS::CodeDeploy::DeploymentGroup",
		"Properties": {
			"ApplicationName": "CodeDeployApplicationAssignment6CICD",
			"Ec2TagFilters": [
				{
					"Key": "Name",
					"Value": "EC2-1",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name2",
					"Value": "EC2-2",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name3",
					"Value": "EC2-3",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name4",
					"Value": "EC2-4",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name5",
					"Value": "EC2-5",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name6",
					"Value": "EC2-6",
					"Type": "KEY_AND_VALUE"
				},
				{
					"Key": "Name7",
					"Value": "EC2-7",
					"Type": "KEY_AND_VALUE"
				}
			],
			"DeploymentGroupName": "deploymentGroup",
			"DeploymentConfigName": "CodeDeployDefault.AllAtOnce",
			"ServiceRoleArn": "arn:aws:iam::377915458523:role/Assignment6CICD-TravisCodeDeployServiceRoleAssignm-AFCMY8S3TJ1M"
   	    }
	  }, "PrivateRouteTable$STACK_NAME": {
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
   }, "LoadBalancer$STACK_NAME": {
   	  "Type": "AWS::ElasticLoadBalancing::LoadBalancer",
   	  "Properties": {
		"Subnets": [
				{
					"Ref": "SubnetWebServer$STACK_NAME"
				}
		],
		"Listeners" : [{
			"LoadBalancerPort" : "80",
			"InstancePort" : "80",
			"Protocol" : "HTTP"
		}, {
			"LoadBalancerPort" : "4200",
			"InstancePort" : "4200",
			"Protocol" : "TCP"
		}, {
			"LoadBalancerPort" : "8080",
			"InstancePort" : "8080",
			"Protocol" : "TCP"
		}, {
			"LoadBalancerPort" : "443",
			"InstancePort" : "443",
			"Protocol" : "TCP"
		}]
   	  }
   }, "PublicRouteTable$STACK_NAME": {
   	  "Type": "AWS::EC2::RouteTable",
   	  "Properties": {
   	  	"VpcId": "$VPC_ID",
   	  	"Tags": [{"Key": "Name", "Value": "$STACK_NAME-csye6225-public-route-table"}]
   	  }
   }, "DNSRoute53$STACK_NAME": {
		"Type": "AWS::Route53::RecordSetGroup",
		"Properties": {
			"HostedZoneName" : "csye6225-spring2018-wux.me.",
          	"Comment" : "Zone apex alias targeted to myELB LoadBalancer.",
			"RecordSets" : [
				{
					"Name" : "csye6225-spring2018-wux.me.",
					"Type" : "A",
					"AliasTarget" : {
						"HostedZoneId" : { "Fn::GetAtt" : ["LoadBalancer$STACK_NAME", "CanonicalHostedZoneNameID"] },
						"DNSName" : { "Fn::GetAtt" : ["LoadBalancer$STACK_NAME","DNSName"] }
					}
				}
			]
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
