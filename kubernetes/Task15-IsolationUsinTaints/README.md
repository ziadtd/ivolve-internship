# Lab 15: Node Isolation Using Taints in Kubernetes

## Overview
This lab demonstrates how to use Kubernetes taints to isolate nodes and control pod scheduling. Taints allow nodes to repel certain pods unless those pods have matching tolerations.

### Step 1: Start Minikube with 2 Nodes

Start a Minikube cluster with 2 nodes:

```bash
minikube start --nodes 2 --driver=docker
```
if this only starts one node 
```bash
minkibe add node
```

---

### Step 2: Taint the Second Node

Apply a taint to the second node (minikube-m02) with the key-value pair `workload=worker` and effect `NoSchedule`:

```bash
kubectl taint nodes minikube-m02 workload=worker:NoSchedule
```

---

### Step 3: Describe All Nodes to Verify the Taint

#### Describe the Control Plane Node:

```bash
kubectl describe node minikube | grep -i taints
```

#### Describe the Worker Node:

```bash
kubectl describe node minikube-m02 | grep -i taints
```

---

### Step 4: Test the Taint (Optional)

Create a test deployment to see the taint in action:

```bash
kubectl create deployment nginx --image=nginx --replicas=3

kubectl get pods -o wide
```

**Expected Result:** All pods should be scheduled on the `minikube` node only, because `minikube-m02` has the taint and the pods don't have a matching toleration.


Create a pod with a toleration to schedule on the tainted node:

```yaml
# pod-with-toleration.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-tolerant
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "worker"
    effect: "NoSchedule"
```

Apply and verify:

```bash
kubectl apply -f pod-with-toleration.yaml

kubectl get pod nginx-tolerant -o wide
```

This pod can be scheduled on `minikube-m02` because it has the matching toleration.
