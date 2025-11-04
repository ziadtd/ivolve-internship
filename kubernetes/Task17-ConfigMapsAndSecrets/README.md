# Lab 17: Managing Configuration and Sensitive Data with ConfigMaps and Secrets

## Objective

This lab demonstrates how to manage configuration data and sensitive credentials in Kubernetes using **ConfigMaps** and **Secrets**.
It focuses on separating non-sensitive application configurations from sensitive information such as passwords and credentials.

---


## Step 1: Define a ConfigMap

The `ConfigMap` stores **non-sensitive** MySQL configuration variables such as the database host and user.

Create a file named `configmap.yml` with the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  labels:
    app: mysql
data:
  DB_HOST: mysql-service
  DB_USER: ivolve_user
```

Apply the ConfigMap to your cluster:

```bash
kubectl apply -f configmap.yml
```

---

## Step 2: Define a Secret

The `Secret` securely stores **sensitive** MySQL credentials, such as the database user password and the root password.
Data values must be base64-encoded before being stored in the manifest.

### Encode the passwords

```bash
echo -n "ivolvepass" | base64
echo -n "rootpass" | base64
```

### Create the Secret manifest

Create a file named `secret.yml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  labels:
    app: mysql
type: Opaque
data:
  DB_PASSWORD: aXZvbHZlcGFzcw==
  MYSQL_ROOT_PASSWORD: cm9vdHBhc3M=
```


```bash
kubectl apply -f secret.yml
```

---

## Step 3: Reference ConfigMap and Secret in a Pod

Create a deployment or pod that uses these configurations.
Example manifest (`deployment.yml`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ivolve-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ivolve-app
  template:
    metadata:
      labels:
        app: ivolve-app
    spec:
      containers:
      - name: ivolve-app
        image: nginx:latest
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: DB_HOST
        - name: DB_USER
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: DB_USER
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: DB_PASSWORD
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD
```

Apply the deployment:

```bash
kubectl apply -f deployment.yml
```

---

## Step 4: Verify the Resources

Check that the environment variables are correctly injected into the pod:

```bash
kubectl exec -it <pod-name> -- env | grep DB_
```
