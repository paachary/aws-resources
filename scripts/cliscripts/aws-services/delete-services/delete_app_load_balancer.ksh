#!/bin/ksh


echo "Start...Deleting application load balancers"

response=`aws elbv2 describe-load-balancers --name app-load-balancer 2> /dev/null`

if [[ $? == 0 ]]
then
    loadBalanceArn=`echo $response | jq '.LoadBalancers[].LoadBalancerArn' | tr -d '"'`        
    response=`aws elbv2 delete-load-balancer --load-balancer-arn ${loadBalanceArn}`
fi

echo "Done...Deleting application load balancers"

