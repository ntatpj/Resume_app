# Resume_app
Here are the step-by-step details to set up an end-to-end Jenkins pipeline for a python application using  Argo CD, Helm, and Kubernetes:
Overview:
 Define the pipeline stages:
    Stage 1: Checkout the source code from Git.
    Stage 2: Build and image from this python code.
    Stage 3: Push the image to manifest Git repo
    Stage 6: Deploy the application to a test environment using Helm.
    Stage 7: Run user acceptance tests on the deployed application.
    Stage 8: Promote the application to a production environment using Argo CD.
![image](https://github.com/user-attachments/assets/450879bc-a101-483e-a8c2-47e8ef50568d)


Prerequisites:

Python Resume application code hosted on a Git repository
Jenkins server - ( Hosted on EC2 )
Kubernetes cluster - (minikube installed on windows11 laptop)
Helm package manager -(installed on windows11 laptop)
Argo CD- (installed with Helm on minikube)


<h3>   1.AWS EC2 Instance </h3>   
 
Create EC2 instance. Select t3.large with security group having inbound allowing port 8080,22,8000.
Go to AWS Console
Instances(running)
Launch instances
![image](https://github.com/user-attachments/assets/94938176-dc0d-44bd-9950-a9769346d193)


 <h3> 2.   Install Jenkins. </h3>   
    
Pre-Requisites:

Java (JDK)
Run the below commands to install Java and Jenkins
Install Java
### Install Jenkins.

Pre-Requisites:
 - Java (JDK)

### Run the below commands to install Java and Jenkins

Install Java

```
sudo apt update
sudo apt install openjdk-17-jre
```

Verify Java is Installed

```
java -version
```

Now, you can proceed with installing Jenkins

```
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```

**Note: ** By default, Jenkins will not be accessible to the external world due to the inbound traffic restriction by AWS. Open port 8080 in the inbound traffic rules as show below.

- EC2 > Instances > Click on <Instance-ID>
- In the bottom tabs -> Click on Security
- Security groups
- Add inbound traffic rules as shown in the image (you can just allow TCP 8080 as well, in my case, I allowed `All traffic`).

<img width="1187" alt="Screenshot 2023-02-01 at 12 42 01 PM" src="https://user-images.githubusercontent.com/43399466/215975712-2fc569cb-9d76-49b4-9345-d8b62187aa22.png">


### Login to Jenkins using the below URL:

http://<ec2-instance-public-ip-address>:8080    [You can get the ec2-instance-public-ip-address from your AWS EC2 console page]

Note: If you are not interested in allowing `All Traffic` to your EC2 instance
      1. Delete the inbound traffic rule for your instance
      2. Edit the inbound traffic rule to only allow custom TCP port `8080`
  
After you login to Jenkins, 
      - Run the command to copy the Jenkins Admin Password - `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
      - Enter the Administrator password
      
<img width="1291" alt="Screenshot 2023-02-01 at 10 56 25 AM" src="https://user-images.githubusercontent.com/43399466/215959008-3ebca431-1f14-4d81-9f12-6bb232bfbee3.png">

### Click on Install suggested plugins

<img width="1291" alt="Screenshot 2023-02-01 at 10 58 40 AM" src="https://user-images.githubusercontent.com/43399466/215959294-047eadef-7e64-4795-bd3b-b1efb0375988.png">

Wait for the Jenkins to Install suggested plugins

<img width="1291" alt="Screenshot 2023-02-01 at 10 59 31 AM" src="https://user-images.githubusercontent.com/43399466/215959398-344b5721-28ec-47a5-8908-b698e435608d.png">

Create First Admin User or Skip the step [If you want to use this Jenkins instance for future use-cases as well, better to create admin user]

<img width="990" alt="Screenshot 2023-02-01 at 11 02 09 AM" src="https://user-images.githubusercontent.com/43399466/215959757-403246c8-e739-4103-9265-6bdab418013e.png">

Jenkins Installation is Successful. You can now starting using the Jenkins 

<img width="990" alt="Screenshot 2023-02-01 at 11 14 13 AM" src="https://user-images.githubusercontent.com/43399466/215961440-3f13f82b-61a2-4117-88bc-0da265a67fa7.png">

## Install the Docker Pipeline plugin in Jenkins:

   - Log in to Jenkins.
   - Go to Manage Jenkins > Manage Plugins.
   - In the Available tab, search for "Docker Pipeline".
   - Select the plugin and click the Install button.
   - Restart Jenkins after the plugin is installed.
   
<img width="1392" alt="Screenshot 2023-02-01 at 12 17 02 PM" src="https://user-images.githubusercontent.com/43399466/215973898-7c366525-15db-4876-bd71-49522ecb267d.png">

Wait for the Jenkins to be restarted.

  
  1. Install the necessary Jenkins plugins:
     Docker Pipeline pulgin
  
  2. Create a new Jenkins pipeline:
     2.1 In Jenkins, create a new pipeline job and configure it with the Git repository URL for the Java application.
     2.2 Add a Jenkinsfile to the Git repository to define the pipeline stages.

## 3. Docker Slave Configuration on EC2 instaance.

Run the below command to Install Docker

```
sudo apt update
sudo apt install docker.io
```
 
### Grant Jenkins user and Ubuntu user permission to docker deamon.

```
sudo su - 
usermod -aG docker jenkins
usermod -aG docker ubuntu
systemctl restart docker
```

Once you are done with the above steps, it is better to restart Jenkins.

```
http://<ec2-instance-public-ip>:8080/restart
```

The docker agent configuration is now successful.

## 4. Set up Docker Engine in windows.
## 5. Install minikube on laptop. We have installed with docker as driver here. 

```
 winget install Kubernetes.minikube
Found an existing package already installed. Trying to upgrade the installed package...
Found Kubernetes - Minikube - A Local Kubernetes Development Environment [Kubernetes.minikube] Version 1.34.0
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://github.com/kubernetes/minikube/releases/download/v1.34.0/minikube-installer.exe
An unexpected error occurred while executing the command:
InternetReadFile() failed.
0x80072ee2 : unknown error

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ minikube start --memory=4098 --driver=docker
* minikube v1.32.0 on Microsoft Windows 11 Home Single Language 10.0.22631.4602 Build 22631.4602
* Using the docker driver based on user configuration
* Using Docker Desktop driver with root privileges
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Creating docker container (CPUs=2, Memory=4098MB) ...
* Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Verifying Kubernetes components...
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

```
## 6. Install helm on windows.
## 7. Set up Argo CD using Helm chart.
    Install Argo CD on the Kubernetes cluster.
    Set up a Git repository for Argo CD to track the changes in the Helm charts and Kubernetes manifests.
    Create a Helm chart for the Python application that includes the Kubernetes manifests and Helm values.
    Add the Helm chart to the Git repository that Argo CD is tracking.

## 8. Set up Prometheus and Grafana on minikube using Helm chart.
## Configure Jenkins pipeline to integrate with Argo CD:
   6.1 Add the Argo CD API token to Jenkins credentials.
   6.2 Update the Jenkins pipeline to include the Argo CD deployment stage.

###. Run the Jenkins pipeline:
   7.1 Trigger the Jenkins pipeline to start the CI/CD process for the Python application.
   7.2 Monitor the pipeline stages and fix any issues that arise.
   
