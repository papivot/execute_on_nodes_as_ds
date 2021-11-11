# Daemonset to modify K8s Linux node configuration

An easy method of configuring/modifying properties of the Linux OS of Kubernetes nodes, the process leverages Kubernetes artifacts and Linux namespaces to affect the relevant changes at the Linux OS level. The changes may include -
- adding additional security packages, 
- adding config files like ssh keys,
- updating system packages, 
- modifying kernel parameters,
- other routine changes.
Since the process is executed as a Kubernetes daemonset (see attached YAML file), changes persist even after new nodes are introduced or old nodes are destroyed from the K8s clusters.  

*Note* Since the process requries root level access to the K8s nodes, please use caution while deploying this image. The daemonset requires `hostPID: true` and `privileged: true` to be set. See the attached `k8s-nodes-config-ds.yaml` file.

## Building a new container image (optional)

- Modify the `exec_on_node.sh` script (if needed)
- Use the provided Dockerfile as a sample and build a new container image. 
- Upload the image to a registry of your choice

## Deployment on a K8s cluster

* Users can use the attached `Dockerfile` to build a new container image or use one already available on deployment yaml.
* Modify the  `k8s-nodes-config-ds.yaml` file - 
  * Modify the container image name (if needed)
  * The configmap within the `k8s-nodes-config-ds.yaml` file consists of two driver scripts - `wait.sh` and `install.sh`. 
    *  `wait.sh`'s logic could be modified to introduce delay in the process to give new Kubernetes nodes time to complete any pending housekeeping before executing the install.sh script.  This could be modified as per cluster specific requreiments. Please use the defaule values if not sure. (see example below)
    * `install.sh` script can be modified to perform the desired changes on all the nodes. This is where all the magic happens. Sample commands like  - `tdnf check-update` and `tdnf update` update all the Kubernetes nodes' packages on a Photon based OS image. (see example below)
    * Add any additional files that may be needed for the configuration.

```yaml
apiVersion: v1
kind: ConfigMap
...
...
data:
  wait.sh: |
    #!/bin/bash
    # Modify the wait script to suit your node ready logic
    # E.g. Sleep for 5 mins to allow node to be ready
    sleep 5m

  install.sh: |
    #!/bin/bash
    if [ ! -f /tmp/install/installation-complete.txt ]
    then
    # --------- Add your node and OS specific commands that need to be executed -----
    # --------- All files are located and executed from /tmp/install folder --------
      tdnf check-update -y
      tdnf update -y

    # ----------- Do not modify the lines below ---------------
      touch /tmp/install/installation-complete.txt
    else
      # Script execution was completed previously. Exit gracefully.
      exit 0
    fi

  # Add additonal files to be passwd thru configmap here
```
* Deploy the daemonset on the K8s cluster 
```yaml
kubectl apply -f k8s-nodes-config-ds.yaml
```
---
