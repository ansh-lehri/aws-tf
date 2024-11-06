# AWS-Tf

## AWS

Terraform code within aws directory, accomplishes following task:

    1. Build a 3-tier VPC with public and private subnets in each availability zone and deploy an EKS cluster in the above VPC.

the code is broken into individual modules with parent main.tf at root level calling each module in sequence.

Modules are as follows:
1. vpc : Creates VPC in the region provided in the provider config in parent main.tf

2. subnets: Creates subnets in the above created VPC

3. security groups: Creates security groups.

4. routes: Creates route tables with defined routes and attaches those tables to subnets given as input.

5. nat: Creates nat gateay, taking elastic ip address id created in parent main.tf as a resource block.

6. ig: Creates internet gateway

7. ec2: Creates ec2 instances and bootstrap them. In bootstrap step, We connect with the EC2 instance, clone git repo having shell scripts for bootstrapping and execute the given bootstrap script.
** For connecting to the instance, assumption taken is that machine where Terraform is running will have pem files needed to login, and only path and name of the pem file is taken as input. ** 
Ex: The git repo can have many bootstraping scripts like bastion-bootstrap.sh, kafka-vm-bottstrap.sh etc.

8. eks: creates eks cluster (control pane and node groups). Node groups creation is dependent on creation of control plane.

9. bastion-bootstrap: This module is used to create connection between the bastion VM (present in the public subnet) and target EKS (K8s) clusters. It first whitelists HTTP(S) calls on ports 80 and 443 in security groups attached to cluster, and then uses aws command line (aws eks config) to configure clusters in .kube/config file.


** Assumptions Made for above task: **

1. For connecting to the instance, assumption taken is that machine where Terraform is running will have pem files needed to login, and only path and name of the pem file is taken as input.

2. All scripts for bootstrapping instances in present on Git private repos. Becasue of this, github username and PAT token will be needed to enable tf to fetch those scripts.

3. For reference, [bootstrap-scripts](https://github.com/ansh-lehri/instance-shell-scripts) are present in public repositories, but to test, move these to a private repo.

4. The current structure adapted, is done so, considering that the complete task is to be done in one-go with all components to be created sequentially. Therefor, all state info is maintained in one tfstate file.
Above structure can be improved using Terragrunt, which will enable us to keep multiple statefiles and provide some flexibility in modules path structures.

5. S3 bucket will be used as backend which must already be present on cloud, just provide relevant details.

6. AWS access_key_id and secret_access_key are required to initiate the provider.

7. Tf version will be between 1.0.0 and 2.0.0 and aws provider scope will be harshicorp/aws.

8. AWS' access_key_id, secret_access_key and Github username, PAT token to be passed as environemnt variable using TF_VAR.


Parent main.tf does some data manipulation using locals block, and calls above descibed modules.


## CICD

Code within cicd directory achieves following tasks:

    1. Take any sample hello world application from the internet or build a simple one of your own. 
       Write a dockerfile and package it into a docker image. Build the docker image and push it to the docker hub using terraform.
    
    2. Extend the terraform code or provide an automation solution to 
        Create a k8s namespace - "exercise", 
        Deploy 2 replicas of pods from the above built image in the "exercise" namespace, and 
        Expose the deployment using service type LoadBalancer and share the endpoint.

Uses null_resource blocks cicd and cicd-deploy to build and deploy respectively.


### In cicd block:

1. Connection to the cicd_server is established. here bastion and cicd server are same.
2. triggers are created to trigger build process when ever image version changes or repo name changes.
3. using remote-exec provisioner following commands are run:

    a. Code repo is cloned.
    b. change working dir to repo folder.
    c. perform docker build, docker login, docker push to put image in docker repository.
    d. Come out of repo folder.
    e. Remove the code repo.


** Assumptions made for cicd block **

1. CICD serer IP is available.
2. Server username, and login information i.e. pem file name and path on terraform server is passed as input. (Same assumption as made in above aws/ code blocks.)
3. Git username and PAT token is available to pull code from private repo.
4. User repository exists on DockerHub.
5. Docker username and password is available.
6. Docker's username, password and Github username, PAT token to be passed as environemnt variable using TF_VAR.


### In cicd-deploy block:


1. Connection to the cicd_server is established. here bastion and cicd server are same.
2. triggers are created to trigger build process when ever image version changes or repo name changes.
3. using remote-exec provisioner following commands are run:

    a. Deploy repo is cloned. A repo is deploy repo if it contains application's manifests or helm values.
    b. Change working dir to repo folder.
    c. using sed, update current image version tag to new one.
    d. Apply all manifests using kubectl.
    d. Come out of repo folder.
    e. Remove the deploy repo.
    f. Code is present in a private repo. For reference, [flask-hello-world](https://github.com/ansh-lehri/flask-hello-world) dummy code is present in public repo, but move it to private repo for testing.

** Assumptions made for cicd-deploy block **

1. CICD serer IP is available.
2. Server username, and login information i.e. pem file name and path on terraform server is passed as input. (Same assumption as made in above aws/ code blocks.)
3. Git username and PAT token is available to pull code from private repo.
4. Image is present in dockerhub.
5. Deploy repo nameing syntax is <team-name>-deploy.
Ex: if team name is say rattle-test, then repo name will be rattle-test-deploy.

6. Within a deploy repo, application folders will be there within which manifests will be present.

Ex: Say my application name is flask-hello-world, then my folder structure in repo wil be rattle-test-deploy/flask-hello-world/

7. CICD server has connectivity to target cluster.
8. Cluster context name is passd to set current context in-case of many clusters in kubeconfig (This is not executed in the above tf code block but can be done.)

9. All manifest file are to be deployed.
10. Deploy repo is a private repo.
11. For reference, [rattle-test-deploy](https://github.com/ansh-lehri/rattle-test-deploy) is present in public repo, but move it to private repo for testing.


Public Endpoint for hello world application: [Flask-Hello-World](http://a0fb7d567e17743b59121bef2e3464ca-1807006476.ap-south-1.elb.amazonaws.com/)