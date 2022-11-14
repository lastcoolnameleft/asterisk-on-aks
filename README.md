# Asterisk on AKS

This repo is a deployable example for running Asterisk on AKS.  Asterisk has a lot of features, but this repo focuses on getting a successful VOIP call between two SIP clients.

## Architecture

!Diagram forthcoming

Asterisk uses a pool of ports to facilitate communication between the RTP clients. (default: 10k UDP ports). Since K8s currently [doesn't support port ranges](https://github.com/kubernetes/kubernetes/issues/23864), this example uses pods with [host networking enabled](https://kubernetes.io/docs/concepts/configuration/overview/#services).

Using a separate nodepool with Public IP's enabled, we're able to connect directly to the exposed ports from the pod.

## Requirements

* AKS Cluster
* [Nodepool with PIP enabled](https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools#assign-a-public-ip-per-node-for-your-node-pools)

## Installation

```
cp etc-asterisk/sip.conf.template etc-asterisk/sip.conf
vi etc-asterisk/sip.conf 
# Update externip to the Public IP address of the VM 
# Update localnet to "CIDR/Mask" of the Asterisk hosts (For my scenario in kubenet, it was 10.224.0.0/255.255.0.0)
# Update secret for each user

RG=asterisk
AKS=asterisk
az aks create -g $RG -n $AKS
az aks nodepool add -g $RG --cluster-name $AKS -n asterisk --enable-node-public-ip --node-count 1

kubectl create secret generic etc-asterisk --from-file=etc-asterisk/sip.conf --from-file=etc-asterisk/extensions.conf

kubectl apply -f deployment.yaml
```

In Azure Portal, in the NSG for the vnet, add an Inbound security rule to allow the following destination port ranges:
* 5060, 10000-20000

## Test

Using two separate SIP clients, enter the account credentials:
* Domain: Public IP Address of the Host
* Username: 1001 or 1002
* Password: The secret you specified in sip.conf