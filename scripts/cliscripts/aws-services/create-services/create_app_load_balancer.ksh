#!/bin/ksh

echo "Start...Creating application load balancer"

response=`aws elbv2 create-load-balancer --name app-load-balancer --scheme internet-facing \
        --subnets ${publicsubnetid} ${publicsubnetid1} \
        --security-groups ${security_grp_id} \
        --tags Key=Name,Value=ShellScript \
        --type application \
        --ip-address-type ipv4` 

loadBalanceArn=`echo $response | jq '.LoadBalancers[].LoadBalancerArn' | tr -d '"'`

echo "Done...Creating application load balancer - ${loadBalanceArn}"


echo "Start...Associating load balancer with target group"

response=`aws elbv2 create-listener --load-balancer-arn ${loadBalanceArn} \
        --protocol HTTP --port 80  \
        --default-actions Type=forward,TargetGroupArn=${targetGroupArn}`

echo "Done...Associating load balancer with target group"
