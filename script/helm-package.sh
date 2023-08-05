#!/bin/bash

cd ..
cd helm
pwd 
echo -en '\n'
echo "Creating helm chart......."
echo -en '\n' 
helm create $3

#To remove all the files and folder except Chart.yaml
for res in $3/*;
do
    if [ "$res" = "$3/Chart.yaml" ]
    then
        continue
    fi
    rm -v -rf  $res
done

#coping templates from dotnet to helm chart
cp -r dotnet/* $3

echo -en '\n'
echo "Creating helm package......."
echo -en '\n' 
helm package $3 --version=$1 --app-version=$2

echo -en '\n'
echo "Pushing helm package to Ecr registry......."
echo -en '\n' 

helm push $3-$1.tgz oci://028677550726.dkr.ecr.ap-south-1.amazonaws.com/

