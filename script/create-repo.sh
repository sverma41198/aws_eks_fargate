#!/bin/bash

echo "Creating ECR repository for docker image"
echo -en '\n'
aws ecr create-repository \
    --repository-name $1-docker-local \
    --image-scanning-configuration scanOnPush=true \
    --region ap-south-1
echo " Authenticateing your Docker client to your ECR registry"
echo -en '\n'
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 028677550726.dkr.ecr.ap-south-1.amazonaws.com
echo -en '\n'
echo "Creating ECR repository for helm chart"
echo -en '\n'
aws ecr create-repository \
    --repository-name $1-helm-local \
    --image-scanning-configuration scanOnPush=true \
    --region ap-south-1

echo " Authenticateing your Helm client to your ECR registry"
echo -en '\n'
aws ecr get-login-password --region ap-south-1 | helm registry login --username AWS --password-stdin 028677550726.dkr.ecr.ap-south-1.amazonaws.com
echo -en '\n'