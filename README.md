# Daemonset to configure K8s Linux node configuration

A unique way of configuring/modifying properties of the Linux OS of Kubernetes nodes, the process leverages Kubernetes artifacts and Linux namespaces to affect the relevant changes at the Linux OS level. The changes may include -
- adding additional security packages, 
- updating system packages, 
- modifying kernel parameters,
- other routine changes.
Since the process is executed as a Kubernetes daemon set (see attached YAML file), changes persist even after new nodes are introduced or old nodes are destroyed from the K8s clusters.  

## Configuration
The configmap within the `k8s-nodes-config-ds.yaml` file consists of two driver scripts - `wait.sh` and `install.sh`. 
* `wait.sh`'s logic could be modified to introduce delay in the process to give new Kubernetes nodes time to complete any pending housekeeping before executing the install.sh script.  
* `install.sh` script can be modified to perform the required changes on all the nodes. Sample commands like  - `tdnf check-update` and `tdnf update` update all the Kubernetes nodes' packages on a Photon based OS image.

```yaml
data:
  wait.sh: |
    #!/bin/bash
    # Do not modify this script
    # Sleep for 5 mins to allow node to be ready
    sleep 5m
    
  install.sh: |
    #!/bin/bash
    # Add node and OS specific commands that need to be executed
    tdnf check-update -y
    tdnf update -y
    
    # Do not remove this bottom line
    touch /tmp/install/installation-complete.txt
```
---

Users can use the attached `Dockerfile` to build a new container image or use one already available on Dockerhub. 
