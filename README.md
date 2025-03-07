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
![image](https://github.com/user-attachments/assets/9bbe5a06-6c8c-4889-86f3-51972e4fd174)



 <h3> 2.   Install Jenkins. </h3>   
    
Pre-Requisites:

a. Java (JDK)
b. Run the below commands to install Java and Jenkins
c. Install Java

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
![image](https://github.com/user-attachments/assets/b75232a1-0f80-4674-bdf9-c68b98aeb3de)

Note: By default Docker Engine is installed with 2GB memory, however later we may face issues while installing other resources. So we increased the memory to 4GB.
      Resources Advanced You are using the WSL 2 backend, so resource limits are managed by Windows. how to increase memory for Docker desktop. It is manged by wsl
To increase memory for Docker Desktop when using the WSL 2 backend, you need to configure the memory settings in the WSL 2 configuration file. Here’s how you can do it:

Steps to Increase Memory for Docker Desktop:
   1. Open Command Prompt as Administrator:
   
   Right-click on the Start button and select "Windows Terminal (Admin)" or "Command Prompt (Admin)".
   
   2. Create or Edit the WSL 2 Configuration File:
   
   Open the .wslconfig file located in your user profile directory (`C:\Users
   
   \[YourUsername]\.wslconfig`). If the file doesn't exist, create it.
   
   You can use Notepad or any text editor to open or create the file:

  3. Add Memory Configuration: (In my case I had to create a .wslconfig file as it did not exist)
   
   Add the following lines to the .wslconfig file to set the memory limit for WSL 2:
   
   ```
   [wsl2]
   memory=4GB  # Adjust the memory allocation as needed 
   ```

## 5. Install minikube on the laptop. We have installed minikube with docker as a driver here. 

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
    
    ```
    ADMIN@DESKTOP-LOTVTQN MINGW64 ~
    $ winget install Helm.Helm
    Found Helm [Helm.Helm] Version 3.16.4
    This application is licensed to you by its owner.
    Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
    Successfully verified installer hash
    Extracting archive...
    Successfully extracted archive
    Starting package install...
    Path environment variable modified; restart your shell to use the new value.
    Command line alias added: "helm"
    Successfully installed
    ```

## 7. Set up Argo CD using Helm chart.
    Install Argo CD on the Kubernetes cluster.
    Set up a Git repository for Argo CD to track the changes in the Helm charts and Kubernetes manifests.
    Create a Helm chart for the Python application that includes the Kubernetes manifests and Helm values.
    Add the Helm chart to the Git repository that Argo CD is tracking.

Once Minikube setup done, Add the ArgoCD Helm repository to Helm. Run the following command:
   ```
   ADMIN@DESKTOP-LOTVTQN MINGW64 ~/GIT
   $ git clone https://github.com/argoproj/argo-helm.git
   Cloning into 'argo-helm'...
   remote: Enumerating objects: 20791, done.
   remote: Counting objects: 100% (280/280), done.
   remote: Compressing objects: 100% (137/137), done.
   Receiving objects:  14% (3048/20791), 4.07 MiB | 907.00 KiB/s
   Receiving objects:  14% (3094/20791), 6.39 MiB | 1.04 MiB/s
   Receiving objects:  15% (3161/20791), 9.54 MiB | 1.08 MiB/s
   Receiving objects:  16% (3327/20791), 12.17 MiB | 1.16 MiB/s
   remote: Total 20791 (delta 228), reused 147 (delta 143), pack-reused 20511 (from 4)
   Receiving objects: 100% (20791/20791), 44.83 MiB | 1.35 MiB/s, done.
   Resolving deltas: 100% (14484/14484), done.
   Updating files: 100% (308/308), done.
   
   ADMIN@DESKTOP-LOTVTQN MINGW64 ~/GIT
   $ cd argo-helm/charts/argo-cd/
   ```

Just like other Kubernetes tools, ArgoCD requires a namespace with its name. Therefore, we will create a namespace for argocd named myargo
   ```
   ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd (main)
   $ kubectl create ns myargo
   namespace/myargo created
   ```
Update the dependencies in the chart by executing the below command.
   ```
   ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd (main)
   $ helm dependency up
   Hang tight while we grab the latest from your chart repositories...
   ...Successfully got an update from the "dandydeveloper" chart repository
   ...Successfully got an update from the "eks" chart repository
   ...Successfully got an update from the "prometheus-community" chart repository
   Update Complete. ⎈Happy Helming!⎈
   Saving 1 charts
   Downloading redis-ha from repo https://dandydeveloper.github.io/charts/
   Deleting outdated charts
   
   ```
Install argo using helm command ; however faced below error
 ```
$ helm install myargo . -f values.yaml -n myargo
Error: INSTALLATION FAILED: An error occurred while checking for chart dependencies. You may need to run `helm dependency build` to fetch missing dependencies: found in Chart.yaml, but missing in charts/ directory: redis-ha
```

Hence had to perfrom below steps:
```
$ helm repo add dandydeveloper https://dandydeveloper.github.io/charts/
"dandydeveloper" has been added to your repositories![image](https://github.com/user-attachments/assets/f76abaae-11b7-4c63-a38e-37cf26a5506b)

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd (main)
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "dandydeveloper" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd (main)
$ helm dependency build
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "dandydeveloper" chart repository
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading redis-ha from repo https://dandydeveloper.github.io/charts/
Deleting outdated charts

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd (main)
$ cd charts/
l
ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts (main)
$ ls
redis-ha-4.29.4.tgz

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts (main)
$ tar -xzvf redis-ha-4.29.4.tgz
redis-ha/Chart.yaml
redis-ha/values.yaml
redis-ha/templates/NOTES.txt
redis-ha/templates/_configs.tpl
redis-ha/templates/_helpers.tpl
redis-ha/templates/redis-auth-secret.yaml
redis-ha/templates/redis-ha-announce-service.yaml
redis-ha/templates/redis-ha-configmap.yaml
redis-ha/templates/redis-ha-exporter-script-configmap.yaml
redis-ha/templates/redis-ha-health-configmap.yaml
redis-ha/templates/redis-ha-network-policy.yaml
redis-ha/templates/redis-ha-pdb.yaml
redis-ha/templates/redis-ha-prometheus-rule.yaml
redis-ha/templates/redis-ha-role.yaml
redis-ha/templates/redis-ha-rolebinding.yaml
redis-ha/templates/redis-ha-secret.yaml
redis-ha/templates/redis-ha-service.yaml
redis-ha/templates/redis-ha-serviceaccount.yaml
redis-ha/templates/redis-ha-servicemonitor.yaml
redis-ha/templates/redis-ha-statefulset.yaml
redis-ha/templates/redis-haproxy-deployment.yaml
redis-ha/templates/redis-haproxy-network-policy.yaml
redis-ha/templates/redis-haproxy-pdb.yaml
redis-ha/templates/redis-haproxy-role.yaml
redis-ha/templates/redis-haproxy-rolebinding.yaml
redis-ha/templates/redis-haproxy-service.yaml
redis-ha/templates/redis-haproxy-serviceaccount.yaml
redis-ha/templates/redis-haproxy-servicemonitor.yaml
redis-ha/templates/redis-tls-secret.yaml
redis-ha/templates/sentinel-auth-secret.yaml
redis-ha/templates/tests/test-redis-ha-configmap.yaml
redis-ha/templates/tests/test-redis-ha-pod.yaml
redis-ha/.helmignore
redis-ha/README.md

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts (main)
$ ls
redis-ha/  redis-ha-4.29.4.tgz

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts (main)
$ cd redis-ha

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts/redis-ha (main)
$ ls
Chart.yaml  README.md  templates/  values.yaml

ADMIN@DESKTOP-LOTVTQN MINGW64 ~/argo-helm/charts/argo-cd/charts/redis-ha (main)
$ helm install myargo . -f values.yaml -n myargo
NAME: myargo
LAST DEPLOYED: Wed Jan  1 21:04:26 2025
NAMESPACE: myargo
STATUS: deployed
REVISION: 1
NOTES:
Redis can be accessed via port 6379   and Sentinel can be accessed via port 26379    on the following DNS name from within your cluster:
myargo-redis-ha.myargo.svc.cluster.local

To connect to your Redis server:
1. Run a Redis pod that you can use as a client:

   kubectl exec -it myargo-redis-ha-server-0 -n myargo -c redis -- sh

2. Connect using the Redis CLI:

  redis-cli -h myargo-redis-ha.myargo.svc.cluster.local
```

##OR Install ArgoCD manually:

a. Install the operator first.
goto https://operatorhub.io/operator/argocd-operator
And click on 'Install'


b. Install ArgoCd controller
https://operatorhub.io/operator/argocd-operator
Goto ArgoCD PRoject operator > Usage >  Basics
copy paste the deployment file vi argocd.yaml.
Apply this file to install argocd resources in minikube
```
kubectl apply -f argocd.yaml
```
Check using 
```
kubectl get po
```
Check the pods and services.
```
$ kubectl get svc
NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
example-argocd-metrics          ClusterIP   10.99.77.234     <none>        8082/TCP            26m
example-argocd-redis            ClusterIP   10.99.192.14     <none>        6379/TCP            26m
example-argocd-repo-server      ClusterIP   10.103.238.38    <none>        8081/TCP,8084/TCP   26m
example-argocd-server           ClusterIP   10.102.210.196   <none>        80/TCP,443/TCP      36s
example-argocd-server-metrics   ClusterIP   10.103.9.69      <none>        8083/TCP            26m
kubernetes     

```
If you notice above example-argocd-server is of type clusterIp, we will change to to NodePort so that we can access the argocd GUI.
```

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl patch service example-argocd-server -n default --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]'

service/example-argocd-server patched
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl get svc
NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
example-argocd-metrics          ClusterIP   10.99.77.234     <none>        8082/TCP                     38m
example-argocd-redis            ClusterIP   10.99.192.14     <none>        6379/TCP                     38m
example-argocd-repo-server      ClusterIP   10.103.238.38    <none>        8081/TCP,8084/TCP            38m
example-argocd-server           NodePort    10.102.210.196   <none>        80:31188/TCP,443:31388/TCP   12m
example-argocd-server-metrics   ClusterIP   10.103.9.69      <none>        8083/TCP                     38m
kubernetes                    
```

by using below command you can generate URL for the this service argocd-server
```
$ minikube service example-argocd-server

|-----------|-----------------------|-------------|--------------|
| NAMESPACE |         NAME          | TARGET PORT |     URL      |
|-----------|-----------------------|-------------|--------------|
| default   | example-argocd-server |             | No node port |
|-----------|-----------------------|-------------|--------------|
* service default/example-argocd-server has no node port
* Starting tunnel for service example-argocd-server.
|-----------|-----------------------|-------------|------------------------|
| NAMESPACE |         NAME          | TARGET PORT |          URL           |
|-----------|-----------------------|-------------|------------------------|
| default   | example-argocd-server |             | http://127.0.0.1:60750 |
|           |                       |             | http://127.0.0.1:60751 |
|-----------|-----------------------|-------------|------------------------|
[default example-argocd-server  http://127.0.0.1:60750
http://127.0.0.1:60751]
! Because you are using a Docker driver on windows, the terminal needs to be open to run it.


```
Launch ArgoCD GUI
![image](https://github.com/user-attachments/assets/a72adf89-a6c7-422d-846d-ac5a78461f4c)

For password cehck the password stored in secret file

```
C:\Users\ADMIN>kubectl get secrets
NAME                                    TYPE                DATA   AGE
argocd-secret                           Opaque              5      15h
example-argocd-ca                       kubernetes.io/tls   3      15h
example-argocd-cluster                  Opaque              1      15h
example-argocd-default-cluster-config   Opaque              4      15h
example-argocd-redis-initial-password   Opaque              2      15h
example-argocd-tls                      kubernetes.io/tls   2      15h

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$  kubectl get secret example-argocd-cluster -o json
{
    "apiVersion": "v1",
    "data": {
        "admin.password": "Y0lwd250RW1KQzJzTTNkNDZMdUZiMWVPUXh5RFB2a1Y="
    },

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ echo Y0lwd250RW1KQzJzTTNkNDZMdUZiMWVPUXh5RFB2a1Y= | base64 -d
cIpwntEmJC2sM3d46LuFb1eOQxyDPvkV

```
Click on Create Application
![image](https://github.com/user-attachments/assets/abc3e72d-2fdc-4d37-a7b8-a73056dc4aa6)

![image](https://github.com/user-attachments/assets/bac825c8-ee86-4e11-abce-5276217e7e38)

Click on Create 
![image](https://github.com/user-attachments/assets/b62744ef-551c-4804-ab95-5492abe74842)

## 8. Set up Prometheus and Grafana on minikube using Helm chart.

Add helm repo for prometheus
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" already exists with the same configuration, skipping

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

```
install prometheus
```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ helm install prometheus prometheus-community/prometheus
NAME: prometheus
LAST DEPLOYED: Thu Jan  2 17:08:48 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.default.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
prometheus-alertmanager.default.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been disabled by default since    #####
######            it deprecated after k8s 1.25+. use                        #####
######            (index .Values "prometheus-node-exporter" "rbac"          #####
###### .          "pspEnabled") with (index .Values                         #####
######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
######            in case you still need it.                                #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-prometheus-pushgateway.default.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
```
Check the prometheus pods are up and running.
```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl get po
NAME                                                 READY   STATUS              RESTARTS         AGE
example-argocd-application-controller-0              1/1     Running             1 (162m ago)     4h30m
example-argocd-redis-64ffff548d-c6qzw                1/1     Running             1 (162m ago)     5h3m
example-argocd-repo-server-76d55855fc-zjdw9          1/1     Running             8 (162m ago)     16h
example-argocd-server-798575995-gh2v6                1/1     Running             25 (2m39s ago)   16h
prometheus-alertmanager-0                            1/1     Running             0                5m36s
prometheus-kube-state-metrics-575d666cdf-bcwz6       1/1     Running             0                5m40s
prometheus-prometheus-node-exporter-c6jp9            1/1     Running             0                5m38s
prometheus-prometheus-pushgateway-576b8c6cd8-44hj5   1/1     Running             0                5m40s

```
The services attached to prometheus pods are type CLusterIP, inorder to acccess it on GUI change to NodePort.
```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext
service/prometheus-server-ext exposed

$ kubectl get svc
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
example-argocd-metrics                ClusterIP   10.99.77.234     <none>        8082/TCP            17h
example-argocd-redis                  ClusterIP   10.99.192.14     <none>        6379/TCP            17h
example-argocd-repo-server            ClusterIP   10.103.238.38    <none>        8081/TCP,8084/TCP   17h
example-argocd-server                 ClusterIP   10.102.210.196   <none>        80/TCP,443/TCP      16h
example-argocd-server-metrics         ClusterIP   10.103.9.69      <none>        8083/TCP            17h
kubernetes                            ClusterIP   10.96.0.1        <none>        443/TCP             17h
prometheus-alertmanager               ClusterIP   10.100.130.155   <none>        9093/TCP            28m
prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP            28m
prometheus-kube-state-metrics         ClusterIP   10.97.3.158      <none>        8080/TCP            28m
prometheus-prometheus-node-exporter   ClusterIP   10.97.130.111    <none>        9100/TCP            28m
prometheus-prometheus-pushgateway     ClusterIP   10.100.136.5     <none>        9091/TCP            28m
prometheus-server                     ClusterIP   10.102.115.186   <none>        80/TCP              28m
prometheus-server-ext                 NodePort    10.105.7.59      <none>        80:31751/TCP        31s
resume-app-service                    NodePort    10.99.240.165    <none>        80:31882/TCP        68m

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
```
Check minikube IP
```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ minikube ip
192.168.49.2
```
Now perfrom port forward on SVC, and it worked.
Performed below steps:
```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl port-forward svc/prometheus-server 9090:80
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
E0103 17:27:42.904416   14796 portforward.go:381] error copying from remote stream to local connection: readfrom tcp6 [::1]:9090->[::1]:54537: write tcp6 [::1]:9090->[::1]:54537: wsasend: An established connection was aborted by the software in your host machine.
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090

```
![image](https://github.com/user-attachments/assets/20da8fbb-bd1f-465f-8e11-f279dcb23080)


## 9. Install Grafana.
Perform below steps:

Add helm repo of grafana and perfrom helm repo update.
```
$ helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "grafana" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```
Install grafana.

```
$ helm install grafana grafana/grafana
NAME: grafana
LAST DEPLOYED: Mon Jan  6 23:32:34 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.default.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################

$ kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

UA8mLmfRHUMAJkpQPm3VzfpgidpRyy3QMhMXRKIn

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000
error: unable to forward port because pod is not running. Current status=Pending

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")


```
Check the pod, service 
```
$ kubectl get po | grep -i grafana
NAME                                                 READY   STATUS    RESTARTS         AGE
grafana-767f7898d5-gn9fl                             1/1     Running   0                22m

$ kubectl get svc | grep -i grafa
grafana                               ClusterIP   10.98.108.12     <none>        80/TCP              27m

$ kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext
service/grafana-ext exposed

ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl get svc | grep -i grafa
grafana                               ClusterIP   10.98.108.12     <none>        80/TCP              30m
grafana-ext                           NodePort    10.111.201.129   <none>        80:31625/TCP        4s


```
Check target port for grafana pod

```
ADMIN@DESKTOP-LOTVTQN MINGW64 ~
$ kubectl describe po grafana
Name:             grafana-767f7898d5-gn9fl
Namespace:        default
Priority:         0
Service Account:  grafana
Node:             minikube/192.168.49.2
Start Time:       Mon, 06 Jan 2025 23:40:06 +0530
Labels:           app.kubernetes.io/instance=grafana
                  app.kubernetes.io/name=grafana
                  app.kubernetes.io/version=11.4.0
                  helm.sh/chart=grafana-8.8.2
                  pod-template-hash=767f7898d5
Annotations:      checksum/config: 0e9cbd0ea8e24e32f7dfca5bab17a2ba05652642f0a09a4882833ae88e4cc4a3
                  checksum/sc-dashboard-provider-config: e70bf6a851099d385178a76de9757bb0bef8299da6d8443602590e44f05fdf24
                  checksum/secret: 674b445d86ff90dab5348bfa243c6422efdd89f10c1b3f5b8e7df09495973ca5
                  kubectl.kubernetes.io/default-container: grafana
Status:           Running
IP:               10.244.0.254
IPs:
  IP:           10.244.0.254
Controlled By:  ReplicaSet/grafana-767f7898d5
Containers:
  grafana:
    Container ID:    docker://ae9eb225665f4d954389afc2b20d0fc36f62cd643f17a3ecece5f748942cdafd
    Image:           docker.io/grafana/grafana:11.4.0
    Image ID:        docker-pullable://grafana/grafana@sha256:d8ea37798ccc41061a62ab080f2676dda6bf7815558499f901bdb0f533a456fb
    Ports:           3000/TCP, 9094/TCP, 9094/UDP, 6060/TCP

```
Expose
```
kubectl port-forward svc/grafana 6060:80
```

![image](https://github.com/user-attachments/assets/f617a39a-250c-4bc3-b119-dfedd2a21962)

Note:
Ref: https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md
grafana (the first part): This is the release name. It's the name you assign to the deployment of this Helm chart. You can choose any name you like for the release, and it will be used to track and manage the release. In this case, the release name is grafana, which means that the deployed Grafana instance will be referred to by this name in subsequent Helm commands (e.g., upgrading, uninstalling).

grafana/grafana (the second part): This is the chart name in the form of repository/chart-name. It specifies which chart to install. In this case:

grafana: This is the repository name where the chart is hosted. It points to the official Grafana Helm chart repository (https://grafana.github.io/helm-charts).
grafana: This is the chart name itself, referring to the Grafana chart available in the grafana repository.

## 10. Setup Jenking pipeline sourcing Jenkins file from SCM. Jenkins file has all stages writen in it.

A. Configure the Git and Docker hub credentials in Jenkins, so that when pipeline runs it can soure code from GIT and push image to DokcerHub.
![image](https://github.com/user-attachments/assets/d29e5c6d-a4b2-4377-b9fc-e4d97760247d)


Click on "admin" in top right corner > Credentials > Stores scoped for admin, click on User:admin here > Gloabl credentials >

![image](https://github.com/user-attachments/assets/26c5d901-e245-4872-a743-73e84a8c4432)

Goto dashboards> New Pipeline.
Select Item type "Pipeline" > OK
![image](https://github.com/user-attachments/assets/a55e4a6f-3a97-4ceb-ae07-399dfcce10ad)

Scroll down, select "Pipeline script from SCM"
![image](https://github.com/user-attachments/assets/e1c8c3b3-a34a-40f1-9f3b-fda1fad62678)

Click on build now.
![image](https://github.com/user-attachments/assets/d0eb2202-c3cf-4bc6-abba-e20704b895af)

To see the logs, scroll down and select "Console logs"
![image](https://github.com/user-attachments/assets/9d2cb05d-32c9-4d06-bf72-325611b19431)

## Configure Jenkins pipeline to integrate with Argo CD:
   6.1 Add the Argo CD API token to Jenkins credentials.
   6.2 Update the Jenkins pipeline to include the Argo CD deployment stage.

###. Run the Jenkins pipeline:

   7.1 Trigger the Jenkins pipeline to start the CI/CD process for the Python application.
   7.2 Monitor the pipeline stages and fix any issues that arise.
   
## 11. Once the Jenkins Pipeline is successful, it will push the image to docker hub and make changes in version for the image.
## 12. In ArgoCD we have created one project, just perform sync to it.

Pod has target port 800

```ADMIN@DESKTOP-LOTVTQN MINGW64 /
$ kubectl describe po resume-app-59b9597d74-4qnmh
Name:             resume-app-59b9597d74-4qnmh
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Mon, 06 Jan 2025 22:15:47 +0530
Labels:           app=resume-app
                  pod-template-hash=59b9597d74
Annotations:      <none>
Status:           Running
IP:               10.244.0.250
IPs:
  IP:           10.244.0.250
Controlled By:  ReplicaSet/resume-app-59b9597d74
Containers:
  resume-app:
    Container ID:   docker://0164a0cccf7fd42e2e2f9c470ba35d38ffd23d1295fb405713238bc590ed5b39
    Image:          ntatpj/docker-resume-image:2
    Image ID:       docker-pullable://ntatpj/docker-resume-image@sha256:479b68ae9e9ae64688221a0522a344a2afd213b75648b83a7acd56c56974efe3
    Port:           800/TCP
```

And the service is listening on 80 inside the cluster

```
$ kubectl get svc
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
example-argocd-metrics                ClusterIP   10.99.170.152    <none>        8082/TCP            3h23m
example-argocd-redis                  ClusterIP   10.100.216.117   <none>        6379/TCP            3h24m
example-argocd-repo-server            ClusterIP   10.102.224.49    <none>        8081/TCP,8084/TCP   3h24m
example-argocd-server                 ClusterIP   10.98.179.64     <none>        80/TCP,443/TCP      3h24m
example-argocd-server-metrics         ClusterIP   10.102.252.248   <none>        8083/TCP            3h24m
kubernetes                            ClusterIP   10.96.0.1        <none>        443/TCP             4d22h
prometheus-alertmanager               ClusterIP   10.100.130.155   <none>        9093/TCP            4d5h
prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP            4d5h
prometheus-kube-state-metrics         ClusterIP   10.97.3.158      <none>        8080/TCP            4d5h
prometheus-prometheus-node-exporter   ClusterIP   10.97.130.111    <none>        9100/TCP            4d5h
prometheus-prometheus-pushgateway     ClusterIP   10.100.136.5     <none>        9091/TCP            4d5h
prometheus-server                     ClusterIP   10.102.115.186   <none>        80/TCP              4d5h
prometheus-server-ext                 NodePort    10.105.7.59      <none>        80:31751/TCP        4d5h
resume-app-service                    NodePort    10.104.54.38     <none>        80:30656/TCP        43m

```
Hence we perform port forward
```
$ kubectl port-forward svc/resume-app-service 800:80
Forwarding from 127.0.0.1:800 -> 8000
Forwarding from [::1]:800 -> 8000
Handling connection for 800
Handling connection for 800
Handling connection for 800
```
And we are able to launch our application on browser
![image](https://github.com/user-attachments/assets/58984631-4efa-47ce-96b8-247b922d826d)
