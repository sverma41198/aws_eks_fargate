#!/bin/bash

cd ..

cd terraform/eks_fargate_profile

terraform init -upgrade

terraform apply -lock=false

