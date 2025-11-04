###Lab 18: Persistent Storage Setup for Application Logging

This guide provides a detailed, step-by-step walkthrough for completing **Lab 18**. The goal is to set up persistent storage in Kubernetes for application logging using a `hostPath`-based Persistent Volume (PV) and a matching Persistent Volume Claim (PVC). This allows multiple pod replicas to read from and write to the same log storage volume.

---

#### Step 1: Prepare the Host Directory on the Node
The PV uses `hostPath`, which maps to a directory on the node's file system. You must create `/mnt/app-logs` with open permissions (777) to allow read/write access.

1. Access the node shell:
   - SSH into the worker node (e.g., `ssh user@node-ip`).

2. Create the directory:
   ```
   sudo mkdir -p /mnt/app-logs
   ```

3. Set permissions:
   ```
   sudo chmod 777 /mnt/app-logs
   ```
4. Exit the node shell:
   ```
   exit
   ```

---

#### Step 2: Create the Persistent Volume (PV) Manifest
The PV defines the storage resource.

Create a file named `pv-app-logs.yaml` with the following content:
   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: app-logs-pv
   spec:
     capacity:
       storage: 1Gi
     accessModes:
       - ReadWriteMany
     persistentVolumeReclaimPolicy: Retain
     hostPath:
       path: /mnt/app-logs
   ```

---

#### Step 3: Apply the Persistent Volume (PV)
Apply the manifest to create the PV in the cluster.

 Run the command:
   ```
   kubectl apply -f pv-app-logs.yaml
   ```

 Verify the PV creation:
   ```
   kubectl get pv app-logs-pv
   ```

---

#### Step 4: Create the Persistent Volume Claim (PVC) Manifest
The PVC requests storage that matches the PV.

 Create a file named `pvc-app-logs.yaml` with the following content:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: app-logs-pvc
   spec:
     accessModes:
       - ReadWriteMany
     resources:
       requests:
         storage: 1Gi
   ```

---

#### Step 5: Apply the Persistent Volume Claim (PVC)
Apply the manifest to create the PVC.

 Run the command:
   ```
   kubectl apply -f pvc-app-logs.yaml
   ```

 Verify the PVC creation and binding:
   ```
   kubectl get pvc app-logs-pvc
   ```

---

#### Step 6: Test the Setup (Optional but Recommended)
To ensure the storage works, deploy a simple pod that mounts the PVC and writes/reads logs.

 Create a test pod manifest `test-pod.yaml`:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: log-test-pod
   spec:
     containers:
       - name: busybox
         image: busybox
         command: ["/bin/sh", "-c", "echo 'Test log' > /logs/test.log && cat /logs/test.log && sleep 3600"]
         volumeMounts:
           - mountPath: /logs
             name: app-logs
     volumes:
       - name: app-logs
         persistentVolumeClaim:
           claimName: app-logs-pvc
   ```

 Apply the pod:
   ```
   kubectl apply -f test-pod.yaml
   ```

 Check pod logs:
   ```
   kubectl logs log-test-pod
   ```
 Shows `'Test log'`.
