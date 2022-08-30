# Deploy the Aspen Mesh Demo Site on a New EKS Cluster

This deploys the following:

- Creates a new  VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS cluster control plane with one managed node group
- Installs Istio on the EKS cluster
- Installs Prometheus, Grafana, and Kiali on the EKS cluster
- Installs Argo Rollouts on the EKS cluster
- Deploys the Aspen Mesh Demo Site to the EKS cluster
- Installs the Aspen Mesh Collector in the EKS cluster

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools before you start working with this module:

 1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
 1. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
 1. [Helm](https://helm.sh/docs/intro/install/)
 1. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

_Note:_ Because of the way that the Kubernetes provider works, there are two separate Terraform configurations (`cluster` and `workloads`).  The Kubernetes provider requires an existing Kubernetes cluster to fetch metadata, so the EKS cluster needs to be created prior to instantiating the Kubernetes provider.

If you already have a Kubernetes cluster, you can skip to [Step 7](#step-7-run-terraform-init-for-the-workloads).

#### Step 1: Clone the repo using the command below

```shell script
git clone https://github.com/aspenmesh/aspenmesh-demo-site-infra.git
```

#### Step 2: Run Terraform Init for the EKS cluster

Initialize a working directory with configuration files

```shell script
cd aspenmesh-demo-site/eks-cluster
terraform init
```
#### Step 3: Update variables for the EKS cluster

 1. Edit [`values.yaml`](../charts/aspenmesh-demo/charts/frontend/values.yaml) in the `frontend` chart, and set the hostname for the demo site.
 1. _Optional_ Create a file called demo-site.auto.tfvars to override default values set in [`variables.tf`](./variables.tf).

#### Step 4: Run Terraform plan for the EKS cluster

```shell script
terraform plan
```

#### Step 5: Run Terraform apply for the EKS cluster

```shell script
terraform apply
```

#### Step 6: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command.  This command is also an output after applying the configuration.

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 7: Run Terraform Init for the workloads

Initialize a working directory with configuration files

```shell script
cd ../workloads
terraform init
```
#### Step 8: Update variables for the workloads

Create a file called demo-site.auto.tfvars to set values for [`variables.tf`](./variables.tf).  At a minimum, `aspenmesh_demo_hostname` and `aspenmesh_demo_tenant_name` must be set.

#### Step 9: Run Terraform plan for the workloads

```shell script
terraform plan
```

#### Step 10: Run Terraform apply for the workloads

```shell script
terraform apply
```

#### Step 11: Test that everything is deployed

Forward the ports for the following workloads in `kubectl`:

|Namespace|Pod|Port|
|---------|---|----|
|istio-system|grafana-xxx|3000|
|istio-system|kiali-xxx|20001|
|frontend|frontend-xxx|8080|

And then open these URLs in a browser to make sure everything is deployed:

```shell script
open http://localhost:3000
open http://localhost:20001
open http://localhost:8080
```

You can create a CNAME DNS record for the hostname that you created in Step 3 to expose the demo site publicly.  The CNAME record should point to the ingress gateway's External IP value:

```shell script
kubectl get svc -n istio-system istio-ingressgateway | awk '{print $4}'

EXTERNAL-IP
a6d274b8802a94151978dc2df034e93a-506542154.us-east-2.elb.amazonaws.com
```

## How to Destroy

The following commands destroy the resources created by `terraform apply`:

```shell script
cd aspenmesh-demo-site/terraform/workloads/
terraform destroy
cd ../cluster/
terraform destroy
```

