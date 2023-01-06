
- [EC2 Instance Management Overview](#ec2-instance-management-overview)
  - [Running and Terminating Instances](#running-and-terminating-instances)
- [Setting up load on an EC2](#setting-up-load-on-an-ec2)
- [EC2 and CloudWatch Unified Agent Metrics CLI](#ec2-and-cloudwatch-unified-agent-metrics-cli)
- [EC2 and Scaling with ASG and Load Balancers](#ec2-and-scaling-with-asg-and-load-balancers)
  - [create auto scaling group](#create-auto-scaling-group)
  - [create load balancer, create listener, and attach to TG1 to ASG2](#create-load-balancer-create-listener-and-attach-to-tg1-to-asg2)
  - [delete ASG2 and ALB2](#delete-asg2-and-alb2)
- [EC2 User Data Guide](#ec2-user-data-guide)
  - [How to check EC2 User Data on an instance](#how-to-check-ec2-user-data-on-an-instance)
  - [EC2 User Data Samples](#ec2-user-data-samples)
    - [Setup Apache on EC2 Linux Instance](#setup-apache-on-ec2-linux-instance)
    - [Setup Apache and update the Index.html with the region from Metadata](#setup-apache-and-update-the-indexhtml-with-the-region-from-metadata)
    - [Setup apache with host name](#setup-apache-with-host-name)
    - [Setup Apache using a random name file from S3](#setup-apache-using-a-random-name-file-from-s3)
- [EC2 Instance Profile Management](#ec2-instance-profile-management)



# EC2 Instance Management Overview 

## Running and Terminating Instances

```bash
# run an instance
aws ec2 run-instances --image-id ami-55ef662f --instance-type t2.micro --key-name MyKeyPair1
```

# Setting up load on an EC2  

This has less to do with the AWS CLI and more to do with the Linux CLI on Linux AMIs.  Still useful. 

```bash 
sudo amazon-linux-extras install epel -y sudo yum install stress -y
stress -c 8
```

or 

```bash
## Install stress
sudo amazon-linux-extras install epel -y
sudo yum install stress-ng -y
stress-ng -c 20 -t 60m -v
```
and yet another

```bash
## Install stress
sudo amazon-linux-extras install epel -y
sudo yum install stress-ng -y
stress-ng --vm 15 --vm-bytes 80% --vm-method all --verify -t 60m -v
stress-ng --vm 10 -c 10 --vm-bytes 80% --vm-method all --verify -t 60m -v
```
# EC2 and CloudWatch Unified Agent Metrics CLI

Basic Syntax 

```bash
aws cloudwatch put-metric-data --metric-name MyBytes --namespace MyNameSpace --unit Bytes --value 231434333 --dimensions InstanceId=1-23456789,InstanceType=m1.small

```

```bash
USEDMEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')
 aws cloudwatch put-metric-data --metric-name memory-usage --dimensions Instance=i-0542ea1e32c310c93  --namespace "EC2-Mem" --value $USEDMEMORY
```

# EC2 and Scaling with ASG and Load Balancers


## create auto scaling group

aws autoscaling create-auto-scaling-group --auto-scaling-group-name ASG2 --launch-template "LaunchTemplateName=MyEC2WebApp" --min-size 1 --max-size 3 --desired-capacity 2 --availability-zones "us-east-1a" "us-east-1b" --vpc-zone-identifier "subnet-02a94e365a7db9848, subnet-00fcec5c9dcd1077d"

## create load balancer, create listener, and attach to TG1 to ASG2

aws elbv2 create-load-balancer --name ALB2 --subnets subnet-02a94e365a7db9848 subnet-00fcec5c9dcd1077d --security-groups sg-018ef94c41893157d

aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:821711655051:loadbalancer/app/ALB2/c3276fdb62a22113 --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:821711655051:targetgroup/TG1/e47504d36c5b8a7f

aws autoscaling attach-load-balancer-target-groups --auto-scaling-group-name ASG2 --target-group-arns arn:aws:elasticloadbalancing:us-east-1:821711655051:targetgroup/TG1/e47504d36c5b8a7f

## delete ASG2 and ALB2

aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:821711655051:loadbalancer/app/ALB2/c3276fdb62a22113

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ASG2 --force-delete

# EC2 User Data Guide 

This document serves to provide data about EC2 User Data. 


## How to check EC2 User Data on an instance 

This command will query the Metadata service.

```bash
# Test with this command:
curl http://169.254.169.254/latest/user-data
# for those that prefer Wget to Curl
wget https://s3.amazonaws.com/ec2metadata/ec2-metadata chmod u+x ec2-metadata
ec2-metadata -help
```


## EC2 User Data Samples 

This section will include helpful examples to setup the user data. 

### Setup Apache on EC2 Linux Instance 

```bash 
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
echo "This is a test page running on Apache on EC2 in the AWS Cloud" > index.html
```

### Setup Apache and update the Index.html with the region from Metadata

```bash
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
aws s3 cp s3://dctlabs/index.txt ./
EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) 
sed "s/INSTANCE/the EC2 instance in $EC2AZ/" index.txt > index.html
```

### Setup apache with host name

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
```

### Setup Apache using a random name file from S3

This UserData file does the usual update, but it uses an instance profile to read a file from S3 and then copy it to the machine.   From there, it randomly sorts the file to come up with a name for the machine like Betty or Josephine.  

```bash
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
aws s3 cp s3://dctlabs/names.csv ./
aws s3 cp s3://dctlabs/index.txt ./
EC2NAME=`cat ./names.csv|sort -R|head -n 1|xargs` 
sed "s/INSTANCE/$EC2NAME/" index.txt > index.html
```


# EC2 Instance Profile Management 

This is an A to Z how to setup an instance profile including setting up the policy and the user. 

```bash 
# Step 1 - if you didn't do the previous lab, run these commands, otherwise go to step 2
# Create user
aws iam create-user --user-name jack
# Create access keys and record access keys for later use
aws iam create-access-key --user-name jack
# Configure CLI with profile for Jack
aws configure --profile jack

# Step 2 - Execute commands using your own Admin account
# Create policy
aws iam create-policy --policy-name jack-ec2 --policy-document file://jack-ec2.json
# Attach policy
aws iam attach-user-policy --user-name jack --policy-arn "arn:aws:iam::ACCOUNT_A_ID:policy/jack-ec2"
# List policies attached to Jack
aws iam list-attached-user-policies --user-name jack

# Step 3 - Now we start using Jack's profile to execute commands
# Create instance profile
aws iam create-instance-profile --instance-profile-name mytestinstanceprofile --profile jack
    # base syntax
    aws iam create-instance-profile --instance-profile-name mytestinstanceprofile
# Add role to instance profile
aws iam add-role-to-instance-profile --role-name S3ReadOnly --instance-profile-name mytestinstanceprofile --profile jack
    # Add role to instance profile
    aws iam add-role-to-instance-profile --role-name S3ReadOnly --instance-profile-name mytestinstanceprofile
# Associate instance profile with EC2 instance
aws ec2 associate-iam-instance-profile --instance-id YOUR_EC2_INSTANCE_ID --iam-instance-profile Name=mytestinstanceprofile --profile jack

# Step 4 Cleanup (optional)
# Remove role from instance profile
aws iam remove-role-from-instance-profile --role-name S3ReadOnly --instance-profile-name mytestinstanceprofile --profile jack
    # Remove role from instance profile
    aws iam remove-role-from-instance-profile --role-name S3ReadOnly --instance-profile-name mytestinstanceprofile
# Delete instance profile
aws iam delete-instance-profile --instance-profile-name mytestinstanceprofile --profile jack
    # Delete instance profile
    aws iam delete-instance-profile --instance-profile-name mytestinstanceprofile

```

Copy of the policy json from above

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "ec2:AssociateIamInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```