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

# to edit pod(but you cannot edit the environment variables, service accounts, resource limits (all of which we will discuss later) of a running pod. )
kubectl edit pod <pod name>
=> 1. A copy of the file and saved in a temporary location
kubectl get pod webapp -o yaml > my-new-pod.yaml
2. Then make the changes to the exported file using an editor (vi editor). Save the changes
vi my-new-pod.yaml
3. Then delete the existing pod
kubectl delete pod webapp
4. Then create a new pod with the edited file
kubectl create -f my-new-pod.yaml


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

# add label to node01
kubectl label nodes node01 color=blue

#####  Taints& Tolerations #####

kubectl describe node kubemaster | grep Taint

# Create taint on node01
kubectl taint nodes node01 spray=mortein:NoSchedule

# Remove from node 'controlplane' the taint with key 'dedicated' and effect 'NoSchedule' if one exists
kubectl taint node controlplane dedicated:NoSchedule-
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

<<<<<<< Updated upstream
###### rolling update/ roll backs #####

k get deployments
kubectl edit deployment frontend
=======

##### DaemonSets

kubectl get daemonsets
kubectl describe daemonsets monitoring-daemon

# check across namespaces
kubectl get daemonsets --all-namespaces

# create daemonsets yaml from deployment and remove some unuse param.
kubectl create deployment elasticsearch --image=registry.k8s.io/fluentd-elasticsearch:1.20 -n kube-system --dry-run=client -o yaml > fluentd.yaml


#### static pods

# check the directory holding the static pod definition files
ps -aux | grep kubelet
find: --config=/var/lib/kubelet/config.yaml


##### drain/cordon #####

# Gracefully terminates pods and marks the node unschedulable. (lưu ý, những pod không thuộc quản lý của replicaset sẽ không tự deploy sang node khác)
k drain node01

# Marks the node unschedulable without terminating pods.
k cordon noed01

# Marks the node schedulable again.
k uncordon node01

##### upgrade cluster

# get current node version
k get nodes

# How many nodes can host workloads in this cluster? (Inspect the applications and taints set on the nodes.)
k describe node <node_name>
k get pods -o wide

# How many applications are hosted on the cluster? (Count the number of deployments in the default namespace.)
k get deployments

# What is the latest version available for an upgrade with the current version of the kubeadm tool installed?
kubeadm upgrade plan

# On the controlplane node, upgrade kubeadm first. (do plan bước trên thấy chưa support ver 1.28 -> 1.29(mới có 1.28.11)
vim /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
root@controlplane:~# apt update
root@controlplane:~# apt-cache madison kubeadm
root@controlplane:~# apt-get install kubeadm=1.29.0-1.1

# Recheck kubeadm upgrade plan v1.29.0 (khi cần nâng version to 1.29.0)
kubeadm upgrade plan v1.29.0

# upgrade the Kubernetes cluster
kubeadm upgrade apply v1.29.0

# upgrade the version and restart Kubelet. Also, mark the node (in this case, the "controlplane" node) as schedulable.
root@controlplane:~# apt-get install kubelet=1.29.0-1.1
root@controlplane:~# systemctl daemon-reload
root@controlplane:~# systemctl restart kubelet
root@controlplane:~# kubectl uncordon controlplane

# next step is upgrade worker(Upgrade the worker node to the exact version v1.29.0)
#Drain the worker node of the workloads and mark it UnSchedulable
k cordon node01

# ssh to node
ssh node01

# upgrade kubeadm
vim /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
root@node01:~# apt update
root@node01:~# apt-cache madison kubeadm
root@node01:~# apt-get install kubeadm=1.29.0-1.1

# Upgrade the node 
root@node01:~# kubeadm upgrade node

# upgrade the version and restart Kubelet.
root@node01:~# apt-get install kubelet=1.29.0-1.1
root@node01:~# systemctl daemon-reload
root@node01:~# systemctl restart kubelet

# uncordon to SchedulingDisabled -> normal
k uncordon node01

##### backup / Restore cluster #####
https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

# ssh to node controlplane(master node)
ssh controlplane

# check how many deployments
k get deployments

# version of etcd running on the cluster
C1. kubectl -n kube-system logs etcd-controlplane | grep -i 'etcd-version'
C2. kubectl -n kube-system describe pod etcd-controlplane | grep Image:

# Check address can you reach the ETCD cluster from the controlplane node
kubectl -n kube-system describe pod etcd-controlplane | grep listen-client-urls

# Check where is the ETCD server certificate file located
kubectl -n kube-system describe pod etcd-controlplane | grep '\--cert-file'
ouput: --cert-file=/etc/kubernetes/pki/etcd/server.crt

# Check where is the ETCD CA Certificate file located?
kubectl -n kube-system describe pod etcd-controlplane | grep '\--trusted-ca-file'

# Take a snapshot of the ETCD database using the built-in snapshot functionality.

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db

# Restore the snapshot
ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
snapshot restore /opt/snapshot-pre-boot.db

# Next, update the /etc/kubernetes/manifests/etcd.yaml:
 volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data

Note 1: As the ETCD pod has changed it will automatically restart, and also kube-controller-manager and kube-scheduler. Wait 1-2 to mins for this pods to restart. You can run the command: watch "crictl ps | grep etcd" to see when the ETCD pod is restarted.
Note 2: If the etcd pod is not getting Ready 1/1, then restart it by kubectl delete pod -n kube-system etcd-controlplane and wait 1 minute.
Note 3: This is the simplest way to make sure that ETCD uses the restored data after the ETCD pod is recreated. You don't have to change anything else.

# How many clusters are defined in the kubeconfig on the student-node
kubectl config view
OR: k config get-clusters

# switch the context to cluster1 ( config cluster1 là context run kubectl)
kubectl config use-context cluster1

# check etcd pod
kubectl get pods -n kube-system  | grep etcd

# check static pod config(xem có config etcd ở đây không)
ls /etc/kubernetes/manifests/ | grep -i etcd

# Check process etcd
ps -ef | grep etcd

# Check etcd config by kube-apiserver
k describe pod kube-apiserver -n kube-system | grep etcd

# Check the members of the cluster etcd
ETCDCTL_API=3 etcdctl \
 --endpoints=https://127.0.0.1:2379 \
 --cacert=/etc/etcd/pki/ca.pem \
 --cert=/etc/etcd/pki/etcd.pem \
 --key=/etc/etcd/pki/etcd-key.pem \
  member list

# inspect the endpoints and certificates used by the etcd pod
kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep advertise-client-url
kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep pki

# SSH to the controlplane node of cluster1 and then take the backup using the endpoints and certificates we identified above
ETCDCTL_API=3 etcdctl --endpoints=https://192.10.6.24:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/cluster1.db

#### TLS Cert

# Identify the certificate file used for the kube-api server.
k describe pod -n kube-system kube-apiserver-controlplane | grep tls # --tls-cert-file=/etc/kubernetes/pki/apiserver.crt

# Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server.
k describe pod -n kube-system kube-apiserver-controlplane | grep '\--etcd-certfile'

# Identify the key used to authenticate kubeapi-server to the kubelet server.
k describe pod -n kube-system kube-apiserver-controlplane | grep '\--kubelet-client-key'

# Identify the ETCD Server Certificate used to host ETCD server.
k describe pod -n kube-system etcd-controlplane | grep '\--cert-file' # /etc/kubernetes/pki/etcd/server.crt

# Identify the ETCD Server CA Root Certificate used to serve ETCD Server
k describe pod -n kube-system etcd-controlplane | grep '\--trusted-ca-file'

# What is the Common Name (CN) configured on the Kube API Server Certificate?
k describe pod kube-apiserver-controlplane -n kube-system | grep '\--tls-cert-file'
openssl x509 -in file-path.crt -text -noout # Subject: CN = kube-apiserver # who issued cert: Issuer: CN = kubernetes

# How long, from the issued date, is the Root CA Certificate valid for?
k describe pod kube-apiserver-controlplane -n kube-system | grep cafile # --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
openssl x509 -in /etc/kubernetes/pki/etcd/ca.crt -text -noout

# The kube-api server stopped again! Check it out. Inspect the kube-api server logs and identify the root cause and fix the issue.
Run crictl ps -a command to identify the kube-api server container. 
Run crictl logs container-id command to view the logs.
 Err: connection error: desc = "transport: authentication handshake failed: tls: failed to verify certificate: x509: certificate signed by unknown authority"
 vi /etc/kubernetes/manifests/kube-apiserver.yaml => --etcd-cafile=/etc/kubernetes/pki/ca.crt => --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
--etcd-cafile string                        SSL Certificate Authority file used to secure etcd communication. 
--client-ca-file If set, any request presenting a client certificate signed by one of the authorities in the client-ca-file is authenticated with an identity corresponding to the CommonName of the client certificate.
