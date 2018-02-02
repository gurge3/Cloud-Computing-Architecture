STACK_NAME=$1
DESCRIBE_TAGS=`aws ec2 describe-tags --filters "Name=key,Values=name" "Name=value,Values='$STACK_NAME'"`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$DESCRIBE_TAGS" > "$DIR/all_resources.json"

jq -c -r '.Tags[].ResourceId' "$DIR/all_resources.json" | while read i; do
	if [ -z "${i##*rtb*}" ]; then
		aws ec2 delete-route --route-table-id "$i" --destination-cidr-block 0.0.0.0/0
		if [ "$?" != "0" ]; then
			echo "Couldn't delete route"
			exit 1
		else
			aws ec2 delete-route-table --route-table-id "$i"
			if [ "$?" != "0" ]; then
				echo "Couldn't delete route table"
				exit 1
			fi
		fi
	fi
done

jq -c -r '.Tags[].ResourceId' "$DIR/all_resources.json" | while read i; do
	if [ -z "${i##*igw*}" ]; then
		ATTACHED_VPC_ID=`ec2 describe-internet-gateways --internet-gateway-id "$i"`
		echo "$ATTACHED_VPC_ID" > "$DIR/attached_vpc.json"
		jq -c -r '.InternetGateways[].Attachments[].VpcId' "$DIR/attached_vpc.json" | while read j; do
			aws ec2 detach-internet-gateway --internet-gateway-id "$i" --vpc-id "$j"
			if [ "$?" != "0" ]; then
				echo "Couldn't detach internet gateway"
				exit 1
			fi
		done
		aws ec2 delete-internet-gateway --internet-gateway-id "$i"
		if [ "$?" != "0" ]; then
			echo "Couldn't delete internet gateway"
			exit 1
		fi
	fi
done


jq -c -r '.Tags[].ResourceId' "$DIR/all_resources.json" | while read i; do
	if [ -z "${i##*vpc*}" ]; then
		aws ec2 delete-vpc --vpc-id "$i"
		if [ "$?" != "0" ]; then
			echo "Couldn't delete vpc"
			exit 1
		fi
	fi
done

echo "Job finished."

