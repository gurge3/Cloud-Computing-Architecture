STACK_NAME=$1
DESCRIBE_TAGS=`aws ec2 describe-tags --filters "Name=key,Values=name" "Name=value,Values='$STACK_NAME'"`
echo "$DESCRIBE_TAGS" > "$PWD/all_resources.json"

jq -c -r '.Tags[].ResourceId' "$PWD/all_resources.json" | while read i; do
	if [ -z "${i##*rtb*}" ]; then
		aws ec2 delete-route --route-table-id "$i" --destination-cidr-block 0.0.0.0/0
		if [ "$?" != "0" ]; then
			echo "Couldn't delete route"
			exit 77
		else
			aws ec2 delete-route-table --route-table-id "$i"
			if [ "$?" != "0" ]; then
				echo "Couldn't delete route table"
				exit 77
			fi
		fi
	fi
done

jq -c -r '.Tags[].ResourceId' "$PWD/all_resources.json" | while read i; do
	if [ -z "${i##*igw*}" ]; then
		echo "$i"
		ATTACHED_VPC_ID=`aws ec2 describe-internet-gateways --internet-gateway-id "$i"`
		echo "$ATTACHED_VPC_ID" > "$PWD/attached_vpc.json"
		jq -c -r '.InternetGateways[].Attachments[].VpcId' "$PWD/attached_vpc.json" | while read j; do
			aws ec2 detach-internet-gateway --internet-gateway-id "$i" --vpc-id "$j"
			if [ "$?" != "0" ]; then
				echo "Couldn't detach internet gateway"
				exit 77
			fi
		done
		aws ec2 delete-internet-gateway --internet-gateway-id "$i"
		if [ "$?" != "0" ]; then
			echo "Couldn't delete internet gateway"
			exit 77
		fi
	fi
done


jq -c -r '.Tags[].ResourceId' "$PWD/all_resources.json" | while read i; do
	if [ -z "${i##*vpc*}" ]; then
		aws ec2 delete-vpc --vpc-id "$i"
		if [ "$?" != "0" ]; then
			echo "Couldn't delete vpc"
			exit 77
		fi
	fi
done

echo "Job finished."

