#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date+%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

# Create IAM OIDC provider
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster expense-dev \
    --approve
VALIDATE $? "IAM OIDC creation"

# Download IAM policy 
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json
VALIDATE $? "IAM policy installation"

# Create an IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
VALIDATE $? "IAM policy creation"

# Create a IAM role and ServiceAccount
eksctl create iamserviceaccount \
--cluster=expense-dev \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::533267327306:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve
VALIDATE $? "IAM role creation"

# Add the EKS chart repo to helm
helm repo add eks https://aws.github.io/eks-charts
VALIDATE $? "Adding helm repo"

# Install the helm chart
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=expense-dev --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
VALIDATE $? "helm chart installation"
