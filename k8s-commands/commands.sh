###POD

#Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
kubectl run nginx --image=nginx --dry-run=client -o yaml 

kubectl run custom-nginx --image=nginx --port=8080

Ex: kubectl run redis --image=redis --dry-run=client -o yaml > redis-pod.yaml
Run: kubectl create -f redis-pod.yaml --namespace=finance

# Create a pod called httpd using the image httpd:alpine in the default namespace. 
# Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80.
kubectl run httpd --image=httpd:alpine
kubectl expose pod httpd --type=ClusterIP --port=80 --name=httpd

# get all info of all deployed pods
kubectl get pods

# apply new change in definition
kubectl replace -f nginx.yaml

# apply new change in definition if want completely delete and recreate objects
kubectl replace --force -f nginx.yaml

# get all object with filter by label
kubectl get all --selector env=prod,bu=finance,tier=frontend

### ReplicaSet #####
kubectl create -f /replicaset-definition.yaml

# get all info of all deployed replicaset
kubectl get replicaset 
kubectl describe replicaset new-replica-set
kubectl describe pod new-replica-set-7r2qw
kubectl delete pod new-replica-set-7r2qw

#check version support replicaset
kubectl explain replicaset

#get the current ReplicaSets deployed
kubectl get rs 

# delete replicaset-1
kubectl delete rs replicaset-1 

#edit replicaset config
kubectl edit rs new-replica-set 

#  check on the state of the all ReplicaSet
kubectl describe rs 

#  check on the state of the specific ReplicaSet
kubectl describe rs/frontend 

# change replicas number
kubectl scale rs new-replica-set --replicas=5 

#edit replicaset config
kubectl edit rs new-replica-set


##### Service#####

# get info svc of namespace
kubectl get svc -n=marketing

# show info of service
kubectl describe service
ex: get describe of service named db-service in namespace marketing 
kubectl describe svc db-service -n=marketing

# get summary service info
kubectl get svc = kube get service

# describe svc kubernetesX
kubectl describe svc kubernetesX

# Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
OR:
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml 
(This will not use the pods labels as selectors, instead it will assume selectors as app=redis. 
You cannot pass in selectors as an option. So it does not work very well if your pod has a different label set. 
So generate the file and modify the selectors before creating the service)


# Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes:

kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml
(This will automatically use the pods labels as selectors, 
but you cannot specify the node port. 
You have to generate a definition file and then add the node port in manually before creating the service with the pod.)

OR:
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml

(This will not use the pods labels as selectors)
Both the above commands have their own challenges. 
While one of it cannot accept a selector the other cannot accept a node port. 
I would recommend going with the kubectl expose command. 
If you need to specify a node port, generate a definition file using the same command and manually 
input the nodeport before creating the service.

### Deployment ####


# create deployment
kubectl create -f /deployment-defi.yaml

#Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml 

Ex2: kubectl create deployment webapp --image=kodekloud/webapp-color -replicas=3
# Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml

# In k8s version 1.19+, we can specify the --replicas option to create a deployment with 4 replicas.
kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml

Ex2: kubectl create deployment redis-deploy --image=redis --replicas=2 --namespace=dev-ns

# Example create deployment httpd.
kubectl create deployment --image=httpd:2.4-alpine httpd-frontend --replicas=3 --dry-run=client -o yaml > /root/httpd-frontend-deployment.yaml
kubectl create -f /root/httpd-frontend-deployment.yaml

# Generate Deployment with 4 Replicas
kubectl create deployment nginx --image=nginx --replicas=4

##### namespace ######

# create namespace

kubectl create namespace dev-ns 
or 
kubectl create ns dev-ns

# get pods in ns
kubectl get pods --namespace=dev/default

# set current context to dev namespace
kubectl config set-context $(kubectl config current-context) --namespace=dev

# get all pods across namespaces

kubectl get pods --all-namespaces


##### NODE ##### 

kubectl get nodes
kubectl describe node controlplane

#####  Taints& Tolerations

kubectl describe node kubemaster | grep Taint

# Create taint on node01
kubectl taint nodes node01 spray=mortein:NoSchedule

# Remove from node 'controlplane' the taint with key 'dedicated' and effect 'NoSchedule' if one exists
kubectl taint node controlplane dedicated:NoSchedule-
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-
