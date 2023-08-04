#!/bin/bash
#!/bin/bash

echo "Creating ECR repository for docker image"

aws ecr create-repository \
    --repository-name $1-docker-local \
    --image-scanning-configuration scanOnPush=true \
    --region ap-south-1

echo "Creating ECR repository for helm chart"

aws ecr create-repository \
    --repository-name $1-helm-local \
    --image-scanning-configuration scanOnPush=true \
    --region ap-south-1


