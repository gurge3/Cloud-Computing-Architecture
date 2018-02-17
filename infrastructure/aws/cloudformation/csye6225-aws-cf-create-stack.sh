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
       "Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-InternetGateway"}]
     }
   }
  ,"VPC$STACK_NAME": {
     "Type": "AWS::EC2::VPC", 
     "Properties": {
       "CidrBlock": "10.0.0.0/16",
       "Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-vpc"}]
     }
   },"AttachedGateway$STACK_NAME": {
   	  "Type": "AWS::EC2::VPCGatewayAttachment",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
   	  	"InternetGatewayId": {"Ref": "InternetGateway$STACK_NAME"}
   	  }
   }, "PrivateRouteTable$STACK_NAME": {
   	  "Type": "AWS::EC2::RouteTable",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
   	  	"Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-private-route-table"}]
   	  }
   }, "PublicRouteTable$STACK_NAME": {
   	  "Type": "AWS::EC2::RouteTable",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
   	  	"Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-public-route-table"}]
   	  }
   }, "SubnetWebServer$STACK_NAME": {
   	  "Type": "AWS::EC2::Subnet",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
		"CidrBlock": "10.0.0.0/24",
		"AvailabilityZone": "us-east-1a",
   	  	"Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-web-server-subnet-table"}]
   	  }
   }, "SubnetDatabase$STACK_NAME": {
   	  "Type": "AWS::EC2::Subnet",
   	  "Properties": {
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
		"CidrBlock": "10.0.1.0/24",
		"AvailabilityZone": "us-east-1b",
   	  	"Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-database-subnet-table"}]
   	  }
   }, "DBSubnetGroup$STACK_NAME": {
   	  "Type": "AWS::RDS::DBSubnetGroup",
   	  "Properties": {
   	  	"DBSubnetGroupDescription": "DB Subnet",
		"SubnetIds": [
		 	{"Ref": "SubnetWebServer$STACK_NAME"},
			{"Ref": "SubnetDatabase$STACK_NAME"}
		],
   	  	"Tags": [{"Key": "name", "Value": "$STACK_NAME-csye6225-database-subnet-group"}]
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
   	  	"VpcId": {"Ref": "VPC$STACK_NAME"},
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
   	  	}]
   	  }
   }, "RDSDBSecurityGroup$STACK_NAME": {
   	  "Type": "AWS::RDS::DBSecurityGroup",
   	  "Properties": {
   	  	"EC2VpcId": {"Ref": "VPC$STACK_NAME"},
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
   	  	"MasterUsername": "csye6225master",
   	  	"MasterUserPassword": "csye6225password",
   	  	"DBSubnetGroupName": {"Ref": "DBSubnetGroup$STACK_NAME"},
   	  	"PubliclyAccessible": "false"
   	  }
   }, "Route$STACK_NAME": {
   	  "Type": "AWS::EC2::Route",
   	  "Properties": {
   	  	 "RouteTableId": {"Ref": "PublicRouteTable$STACK_NAME"},
   	  	 "DestinationCidrBlock": "0.0.0.0/0",
   	  	 "GatewayId": {"Ref": "InternetGateway$STACK_NAME"}
   	  }
   }
  }  
}
EOF

##Procedures for creating cloudformation stack with VPC
echo "Creating stack along with all the resources naming $STACK_NAME"
aws cloudformation create-stack --stack-name "$STACK_NAME" --template-body "file://$PWD/resources.json"
echo "Job Finished"
