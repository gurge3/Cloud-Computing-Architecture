STACK_NAME=$1
echo "The stack name you entered: $STACK_NAME"
CREATE_VPC=`aws ec2 create-vpc --cidr-block 10.0.0.0/16`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$CREATE_VPC" > "$DIR/vpc.json"
VPC_ID=`jq ".Vpc.VpcId" "$DIR/vpc.json" -r`
echo "${VPC_ID}"
if [ "$VPC_ID" == "" ]; then
	echo "[error] creating vpc failed!" 1>&2
	exit 1
else
	echo "VPC ${VPC_ID} has been created"
	aws ec2 create-tags --resources $VPC_ID --tags Key=name,Value=$STACK_NAME
	echo "VPC's name is $STACK_NAME"
fi
CREATE_INTERNET_GATEWAY=`aws ec2 create-internet-gateway`
echo "$CREATE_INTERNET_GATEWAY" > "$DIR/internet_gateway.json"
INTERNET_GATEWAY_ID=`jq ".InternetGateway.InternetGatewayId" "$DIR/internet_gateway.json" -r`
if [ "$INTERNET_GATEWAY_ID" == "" ]; then
	echo "[error] creating internet gateway failed!" 1>&2
	exit 1
else
	echo "Internet Gateway ${INTERNET_GATEWAY_ID} has been created"
	aws ec2 create-tags --resources $INTERNET_GATEWAY_ID --tags Key=name,Value=$STACK_NAME
	echo "Internet Gateway's name is $STACK_NAME"
fi
ATTACH_INTERNET_GATEWAY=`aws ec2 attach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_ID}`
echo "VPC and Internet Gateway has been attached"
CREATE_ROUTE_TABLE=`aws ec2 create-route-table --vpc-id ${VPC_ID}`
echo "$CREATE_ROUTE_TABLE" > "$DIR/route_table.json"
ROUTE_TABLE_ID=`jq ".RouteTable.RouteTableId" "$DIR/route_table.json" -r`
if [ "$ROUTE_TABLE_ID" == "" ]; then
	echo "[error] creating route table failed!" 1>&2
	exit 1
else
	echo "Route Table ${ROUTE_TABLE_ID} has been created"
	aws ec2 create-tags --resources $ROUTE_TABLE_ID --tags Key=name,Value=$STACK_NAME
	echo "Route table's name is $STACK_NAME"
fi
CREATE_ROUTE=`aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${INTERNET_GATEWAY_ID}`
echo "Job finished"