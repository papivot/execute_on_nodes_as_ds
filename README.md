# Daemonset to modify K8s Linux node configuration

This repository contains a set of files to build and deploy a Kubernetes DaemonSet that can be used to perform configuration changes on the underlying Linux OS of the Kubernetes nodes.

## :warning: Security Warning :warning:

This tool is very powerful and carries significant security risks. It runs a container with elevated privileges on your Kubernetes nodes, which, if compromised, could lead to a full cluster compromise.

**Use this tool with extreme caution.**

- **Restrict access:** Only allow trusted users to deploy and manage this DaemonSet.
- **Use a private registry:** Always host your container images in a private, trusted registry.
- **Limit scope:** Use the `nodeSelector` to ensure the DaemonSet only runs on the intended nodes.
- **Audit changes:** Carefully review any changes to the `install.sh` script in the `ConfigMap`.

## File Overview

- `docker/Dockerfile`: Used to build the container image that runs on the nodes. It has been optimized for security and size.
- `docker/exec_on_node.sh`: The entrypoint script for the container. It uses `nsenter` to execute scripts from the `ConfigMap` on the host node.
- `deployment/k8s-nodes-config-ds.yaml`: The Kubernetes manifest for the DaemonSet. It has been secured by removing `privileged` mode, adding specific capabilities, and restricting its execution scope.
- `README.md`: This file.

## How it works

The process leverages a Kubernetes DaemonSet to run a container on each target node. This container has access to the host's process namespace (`hostPID: true`) and is granted specific capabilities (`SYS_ADMIN`, `SYS_PTRACE`, `SYS_CHROOT`) that allow it to use `nsenter`. `nsenter` is a tool that can run a program in another process's namespaces. In this case, it targets the `init` process (PID 1) on the host to execute scripts as if they were running directly on the node's OS.

The scripts to be executed are provided via a `ConfigMap`, which allows for easy customization without rebuilding the container image.

## Building the container image

1.  **(Optional)** Modify the `docker/exec_on_node.sh` script if you need to change the core execution logic.
2.  Build the container image using the provided `Dockerfile`:
    ```bash
    docker build -t <your-private-registry>/node-execution:0.1.0 docker/
    ```
3.  Push the image to your private registry:
    ```bash
    docker push <your-private-registry>/node-execution:0.1.0
    ```

## Deployment on a K8s cluster

1.  **Label your target nodes:** The provided `k8s-nodes-config-ds.yaml` uses a `nodeSelector` to target specific nodes. You need to label the nodes where you want this DaemonSet to run.
    ```bash
    kubectl label node <your-node-name> papivot.com/node-config-target="true"
    ```

2.  **Customize the installation scripts:** Modify the `install.sh` and `wait.sh` scripts within the `ConfigMap` in the `deployment/k8s-nodes-config-ds.yaml` file to perform your desired actions. The `install.sh` script creates a file at `/var/tmp/ds-installation-complete.txt` to prevent re-execution on subsequent container starts.

3.  **Deploy the DaemonSet:**
    ```bash
    kubectl apply -f deployment/k8s-nodes-config-ds.yaml
    ```

### Example `k8s-nodes-config-ds.yaml`

The `deployment/k8s-nodes-config-ds.yaml` file is already configured with security best practices. Below is a snippet of the `DaemonSet` resource for reference.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-configure
  namespace: k8s-papivot-tools
spec:
  selector:
    matchLabels:
      name: node-configure-job
  template:
    metadata:
      labels:
        name: node-configure-job
    spec:
      hostPID: true
      containers:
      - image: <your-private-registry>/node-execution:0.1.0
        name: node-configure-pod
        securityContext:
          capabilities:
            add:
            - SYS_ADMIN
            - SYS_PTRACE
            - SYS_CHROOT
          readOnlyRootFilesystem: true
        volumeMounts:
        - name: install-script
          mountPath: /host-install-files
        - name: host-mount
          mountPath: /host
      volumes:
      - name: install-script
        configMap:
          name: installation-scripts
      - name: host-mount
        hostPath:
          path: /tmp/install
      nodeSelector:
        papivot.com/node-config-target: "true"
```
---
The `recipes` directory contains examples of other tools and techniques for interacting with nodes, such as `falco` for security monitoring. These are not directly related to the node configuration DaemonSet but are provided as additional resources.
