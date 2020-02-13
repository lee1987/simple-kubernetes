# Simple-Kubernetes
- [Intro](#intro)
- [Installation Prerequisites](#installation-prerequisites)
- [Installation Guide for Kubernetes Cluster](#installation-guide-for-kubernetes-cluster)
   - [Pre-configured your settings](#pre-configured-your-settings)
   - [Deployment](#deployment)
   - [Configure your Kubectl](#configure-your-kubectl)
   - [Verify the Installation](#verify-the-installation)
- [Installation Guide for Cluster Management Tools](#installation-guide-for-cluster-management-tools)
  - [Deploy a Kubernetes Web UI (Dashboard)](#deploy-a-kubernetes-web-ui-dashboard)
  - [Deploy NGINX Ingress Controller](#deploy-nginx-ingress-controller)
  - [Deploy a Monitoring & Alerting System](#deploy-a-monitoring-and-alerting-system)
  - [Deploy a Logging System](#deploy-a-logging-system)


# Intro

A small project to make deploying a Kubernetes cluster **simple**.

# Installation Prerequisites

A minimum 3 nodes cluster is required for this project.

There are a few important prerequisites which should be prepared, the list below contains current software and it's version numbers that have been tested:

| Software      | Version       |
| ------------- |:-------------:|
| Ansible       | 2.8.1         |
| Python        | 2.7.10        |

# Installation Guide for Cluster Management Tools

This installation guide assumes a macOS, and assuming you have a working GlusterFS cluster installed (and can be reached to/from the Kubernetes Cluster).

## Pre-configured your settings

Update your ansible’s inventory, which defaults to being saved in the location **./settings.ini**. You can specify a different inventory file using the **-i path** option on the command line.

## Deployment:

```sh
ansible-playbook -i settings.ini ./initial.yml
ansible-playbook -i settings.ini ./kube-dependencies.yml
ansible-playbook -i settings.ini ./master.yml
ansible-playbook -i settings.ini ./workers.yml
```

### Configure your Kubectl

To disable TLS validation: open & edit the kube config file on your host and set `insecure-skip-tls-verify` to true:
```json
insecure-skip-tls-verify: true
```

### Verify the Installation 

The minimum 3 nodes are required, to verify the number of nodes on your cluster using command below on your terminal:
```sh
kubectl get nodes
```

# Installation Guide for Cluster Management Tools

## Deploy a Kubernetes Web UI (Dashboard)

You may get a certificate error on your browser, then you need to generate a self-assign certificate on your host. To do that, log on to your node, and run below commands on the terminal:

```sh
openssl req  -new -config openssl.conf  -keyout certs/dashboard.key -out certs/dashboard.csr
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
kubectl create namespace kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kubernetes-dashboard
```

Deploy a Kubernetes Web UI (Dashboard)

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc1/aio/deploy/recommended.yaml
```

Access the Web UI (Dashboard)

Run below command on your terminal for port forwarding, then go to: https://127.0.0.1:10443/
```sh
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 10443:443
```

[Accessing Dashboard 1.7.x and above](https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/1.7.x-and-above.md)

Create role and Get a token for login:
```sh
kubectl apply -f ./user_role/dashboard-adminuser.yaml
kubectl apply -f ./user_role/cluster-role-bindings.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

## Deploy NGINX Ingress Controller

To enable external access to the services in a cluster, we need to deploy a [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/), [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is one of the ingress projects, it's supported and maintained by the Kubernetes project. To install, follow the guide on [NGINX Ingress Controller](https://git.k8s.io/ingress-nginx/README.md).

## Deploy a Monitoring and Alerting System

[kube-prometheus](https://github.com/coreos/kube-prometheus) is a open source project for Kubernetes Cluster monitoring, it collects Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.
To install, follow the `install` of `Customizing Kube-Prometheus` section.

## Deploy a Logging System

@todo: add central logging - aggregates the log to view the message if after pods die.


## Setup Persistent Volumes

```sh
kubectl create -f ./glusterfs/gluster-secret.yaml
kubectl create -f ./glusterfs/gluster-heketi-storage-replicate-2-class.yaml
```
