#!/bin/bash

cd ..

cd terraform/helm_release

terraform init -upgrade

terraform apply  -lock=false
