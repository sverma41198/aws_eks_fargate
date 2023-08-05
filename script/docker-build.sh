#!/bin/bash

cd ..
cp docker/Dockerfile source/
echo "Building Docker Image"
echo -en '\n'
docker build --no-cache -t  $2  ./source/
echo -en '\n'
docker tag app-docker-local:latest 028677550726.dkr.ecr.ap-south-1.amazonaws.com/$2:$1
echo -en '\n'
echo "Pushing Images to ECR registry"
echo -en '\n'
docker push 028677550726.dkr.ecr.ap-south-1.amazonaws.com/$2:$1




















