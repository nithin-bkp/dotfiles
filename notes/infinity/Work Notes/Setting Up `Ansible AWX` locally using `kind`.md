## Introduction

`Ansible` is an open-source automation tool that allows for infrastructure as code, enabling the configuration, provisioning, and deployment of systems and applications. Additionally `AWX` is web Interface based platform sitting on top of `Ansible` to manage, monitor and configure various workloads created in `Ansible`. For us developers/maintainers of the alert engine, it is necessary to integrate and test the `AutoRemediation` channel available in the `Alert Engine`. And `AutoRemediation` is just an alias for the jobs run on `Ansible`. So essentially a locally working `Ansible AWX` setup is a must. Relying on external servers hosting `AWX`  and managed by somebody else is not a desirable state. Hence this is a step towards self-sufficiency.

I am assuming that all of our development setup is manged through `kind`, which is mostly the case. There are options available for docker-compose, but not covered here. [See Here](https://github.com/ansible/awx/blob/17.1.0/INSTALL.md#docker-compose) for more details.

### 1.  Clone the `awx-operator` repo

```bash
git clone -b 2.7.2 git@github.com:ansible/awx-operator.git --depth 1
cd awx-operator
```
### 2. Create a Kind cluster to run `AWX`

   `AWX` is a stack of `postgres`, `redis`, `django` and `ansible` . Hence it is a good idea to have a separate cluster to manage it.
   
   Create a file called `cluster_config.yaml` and add the below contents:
   
```yaml
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
- role: worker
```

```bash
kind create cluster --config=cluster_config.yaml --name ansible-awx
```

### 3. Toggling the `kubectl` context to and from `kind-ansible-awx`

Initially to deploy `vuSmartMaps` in our application, we would have created a cluster already using `kind create cluster --name vsmaps` and deployed all our services in it. When this command is issued, `kind` informs `kubectl` to use this cluster for all further operations like `get pods` , `get svc` and so on. Now during step #2, when we create another kind cluster (`ansible-awx`), `kind` will now inform `kubectl` to use this cluster and detach from `vsmaps` cluster. So now when we perform `kubectl get pods -n vsmaps` , you won't see any of your `vsmaps` pods. It is important **not to panic** at this point. What `kubectl` did was only switch context to the cluster, your `vsmaps` cluster and its objects are still intact. To switch back and forth to `vsmaps` and `ansible-awx` cluster just use the below:

To switch to `vsmaps` cluster
```bash
kubectl config use-context kind-vsmaps
```

To switch to `ansible-awx` cluster
```bash
kubectl config use-context kind-ansible-awx
```

To continue along, make sure you are in the `kind-ansible-awx` cluster by running the below command:
```bash
> kubectl config get-contexts
CURRENT   NAME                          CLUSTER                       AUTHINFO                      NAMESPACE
*         kind-ansible-awx              kind-ansible-awx              kind-ansible-awx
          kind-opentelemetry-operator   kind-opentelemetry-operator   kind-opentelemetry-operator
          kind-vsmaps                   kind-vsmaps                   kind-vsmaps
``` 

You will see an asterisk next to `kind-ansible-awx`, if not switch the context to it before proceeding. ``

## 4. Install `nginx` ingress router

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### 5. Setting `awx` as namespace to the `ansible-awx`  cluster

All the `k8s` objects we will install for `Ansible AWX` is defaulted to be installed and run on the `awx` namespace because these objects are annotated with `awx` namespace in their `yaml` definitions. Hence we will 
annotate the cluster we created with `awx` namespace so that these objects get installed on it.

```bash
kubectl config set-context --current --namespace=awx
```

### 6.  Installing the operator

Create a file name `kustomization.yaml` in the current directory. Include the following:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.7.2

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.7.2

# Specify a custom namespace in which to install AWX
namespace: awx
```

```bash
kubectl apply -k .
```

### 7. Deploy `AWX`

Create a file named `awx-cr.yaml` and add the following:

```yaml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
  nodeport_port: 32000

```

```bash
kubectl create -f awx-cr.yaml
```

After running the above command wait for all the objects to be in the ready in the `awx` namespace:

```bash
kubectl get-all -n awx
NAME                                                  READY   STATUS    RESTARTS   AGE
pod/awx-demo-postgres-13-0                            1/1     Running   0          18h
pod/awx-demo-task-f47597699-8bznx                     4/4     Running   0          18h
pod/awx-demo-web-785498b5c9-p7n6k                     3/3     Running   0          18h
pod/awx-operator-controller-manager-ccb997689-pqg2k   2/2     Running   0          18h

NAME                                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/awx-demo-postgres-13                              ClusterIP   None            <none>        5432/TCP       18h
service/awx-demo-service                                  NodePort    10.96.187.168   <none>        80:32000/TCP   18h
service/awx-operator-controller-manager-metrics-service   ClusterIP   10.96.215.219   <none>        8443/TCP       18h

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/awx-demo-task                     1/1     1            1           18h
deployment.apps/awx-demo-web                      1/1     1            1           18h
deployment.apps/awx-operator-controller-manager   1/1     1            1           18h

NAME                                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/awx-demo-task-f47597699                     1         1         1       18h
replicaset.apps/awx-demo-web-785498b5c9                     1         1         1       18h
replicaset.apps/awx-operator-controller-manager-ccb997689   1         1         1       18h

NAME                                    READY   AGE
statefulset.apps/awx-demo-postgres-13   1/1     18h
```

Your `AWX` instance should now be reachable at http://localhost:32000/

#### Note: To delete the cluster run `kind delete cluster`