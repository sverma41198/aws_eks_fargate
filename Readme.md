
<a name="_hw5yhsicuft0"></a>ASP .Net Application Deployment on EKS Fargate using Terraform and Helm 

# <a name="_hixnfnnzl6pj"></a>Step 1: Create Dockerfile for .Net Application.
- **ASP .Netcore 7 application  Source code at ./app/aspnetapp**

- ` `**Dockerfile for the following source code at ./docker**

![](Aspose.Words.d0a27e65-6b92-4e5a-9a3a-16478d96c81b.001.png)

|FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build<br>WORKDIR /source<br><br>*# copy csproj and restore as distinct layers*<br>COPY aspnetapp/\*.csproj .<br>RUN dotnet restore --use-current-runtime  <br><br>*# copy everything else and build app*<br>COPY aspnetapp/. .<br>RUN dotnet publish --use-current-runtime --self-contained false --no-restore -o /app<br><br><br>*# final stage/image*<br>FROM mcr.microsoft.com/dotnet/aspnet:7.0<br>WORKDIR /app<br>COPY --from=build /app .<br>ENTRYPOINT ["dotnet", "aspnetapp.dll"]|
| :- |


# <a name="_tpq9x6eblmej"></a>Step 2: Create ECR Private Repository for Docker image and Helm Chart
<a name="_m6a1o8l53igi"></a>create-repo.sh <application\_name>    in ./script example: create-repo dotnet-app-testing

- Note: It creates a separate repo in ECR for docker images and helm charts. Keep name as <application\_name>-docker-local and <application\_name>-helm-local.

|*#!/bin/bash*<br><br>echo "Creating ECR repository for docker image"<br>echo -en '\n'<br>aws ecr create-repository '\'<br>--repository-name $1-docker-local \<br>`    `--image-scanning-configuration scanOnPush=true \<br>`    `--region ap-south-1<br>echo " Authenticating your Docker client to your ECR registry"<br>echo -en '\n'<br>aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 028677550726.dkr.ecr.ap-south-1.amazonaws.com<br>echo -en '\n'<br>echo "Creating ECR repository for helm chart"<br>echo -en '\n'<br>aws ecr create-repository \<br>`    `--repository-name $1-helm-local \<br>`    `--image-scanning-configuration scanOnPush=true \<br>`    `--region ap-south-1<br><br>echo " Authenticating your Helm client to your ECR registry"<br>echo -en '\n'<br>aws ecr get-login-password --region ap-south-1 | helm registry login --username AWS --password-stdin 028677550726.dkr.ecr.ap-south-1.amazonaws.com<br>echo -en '\n'|
| :- |

# <a name="_n00uaaeuncf5"></a>Step 3: Build & Push Image to ECR Private Repository
<a name="_glleqrryj07s"></a>docker-build.sh <app\_version> <repo\_name> in ./script     example: docker-build.sh 0.1.0

- ` `Note: it builds the docker image and pushes it to ECR docker repo.

|**#!/bin/bash**<br><br>cd ..<br>cp docker/Dockerfile app/<br>echo "Building Docker Image"<br>echo -en '\n'<br>docker build --no-cache -t  $2  ./app/<br>echo -en '\n'<br>docker tag $2:latest 028677550726.dkr.ecr.ap-south-1.amazonaws.com/$2:$1<br>echo -en '\n'<br>echo "Pushing Images to ECR registry"<br>echo -en '\n'<br>docker push 028677550726.dkr.ecr.ap-south-1.amazonaws.com/$2:$1|
| :- |

# <a name="_dogka4m7xhg6"></a>Step 4:  Build & Push Helm Package to ECR Private Repository
<a name="_sn2nt46z1bkf"></a>helm-package.sh <app\_version> <chart\_version> <repo\_name>   in ./script  example: helm-package.sh 0.1.0 1.0.0   app-helm-local

- Note: it should build the helm package and push it to ECR docker repo.

|**#!/bin/bash**<br><br>cd ..<br>cd helm<br>pwd<br>echo -en '\n'<br>echo "Creating helm chart......."<br>echo -en '\n'<br>helm create $3<br><br>*#To remove all the files and folder except Chart.yaml*<br>**for** res **in** $3/\*;<br>**do**<br>`    `**if** [ "$res" = "$3/Chart.yaml" ]<br>`    `**then**<br>`        `continue<br>`    `**fi**<br>`    `rm -v -rf  $res<br>**done**<br>#coping templates from dotnet to helm chart<br>cp -r dotnet/\* $3<br><br>echo -en '\n'<br>echo "Creating helm package......."<br>echo -en '\n'<br>helm package $3 --version=$1 --app-version=$2<br><br>echo -en '\n'<br>echo "Pushing helm package to Ecr registry......."<br>echo -en '\n'<br><br>helm push $3-$1.tgz oci://028677550726.dkr.ecr.ap-south-1.amazonaws.com/|
| :- |

<a name="_s53jtqyey9t0"></a>Terraform Modules and script to spin up infrastructure

# <a name="_6zs9w2o4rv0b"></a>Step 1: Set Up a Remote Backend for Terraform State File
1. <a name="_2i11az468imk"></a>Create an S3 bucket

|aws s3api create-bucket --bucket <my-terraform-state-bucket> --region <region> --create-bucket-configuration LocationConstraint=<region>|
| :- |



1. <a name="_tpxc0dekb5x1"></a>Create an S3 bucket policy

**Next, we need to create an S3 bucket policy that allows Terraform to read and write to the S3 bucket.**

1. <a name="_v6kg8l652n4w"></a>Configure the backend in /terraform/backen\_config/main.tf

# <a name="_un6yi0ywhfox"></a>Step 2: Creating VPC with 2 public and 2 private subnet
![](Aspose.Words.d0a27e65-6b92-4e5a-9a3a-16478d96c81b.002.png)
# <a name="_17kuicyy9b18"></a>Step 3: Creating eks-cluster-profile module and helm release module in ./terraform directory

- **Create separate terraform module to provision AWS EKS Fargate Profile & Fargate** 

**Cluster.**

- **Create a separate terraform module to deploy a helm chart for .Net Application.**
- **Deployed Kubernetes application should be configured with Load Balancer(ALB). Added necessary  code to terraform eks module for alb deployment. 12.**
- ` `**Deployed Kubernetes application should be configured with a horizontal pod autoscaler(HPA).**
# <a name="_r401as5gqq5"></a>Step 4: Creating eks-deploy.sh script to deploy required infrastructure in aws 
<a name="_e3mh4e8jc1bg"></a>eks-deploy.sh - create and deploy eks cluster in aws.   

- ` `**Note: it should run terraform code to create eks fargate cluster, fargate profile, alb controller, metrics server in aws.** 


|**#!/bin/bash<br><br>cd ..<br><br>cd terraform/eks\_fargate\_profile<br><br>terraform init -upgrade<br><br>terraform apply -lock=false**|
| :- |

# <a name="_l5bdjle3h12e"></a>Step 5: Configure aws eks cluster




|***aws* *eks* *update*-*kubeconfig* --*name* *<cluster-name>* --*region* *<region>***|
| :- |
#
# <a name="_1at172kenbxe"></a><a name="_oy30lv7zelx3"></a>Step 6: Creating helm-release.sh to deploy the .Net application in the fargate cluster using terraform code
<a name="_ifk4h5fzxi70"></a>helm-release.sh <chart\_version> - create helm release and deploy into eks cluster in aws.    example: helm-release.sh 1.0.0    

- **Note: it should deploy the helm package version into eks cluster.**


|**#!/bin/bash**<br><br>cd ..<br><br>cd terraform/helm\_release<br><br>terraform init -upgrade<br><br>terraform apply  -lock=false|
| :- |


<a name="_j3xrhb3ikuy5"></a>Results:

## <a name="_5kxyknrl1z62"></a>**Website  accessible using load balancer cname or url.![](Aspose.Words.d0a27e65-6b92-4e5a-9a3a-16478d96c81b.003.png)**


