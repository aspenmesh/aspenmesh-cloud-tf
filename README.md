# Deploy the Aspen Mesh Cloud on a New EKS Cluster

This deploys the following:

- Creates a new  VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS cluster control plane with one managed node group

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
git clone https://github.com/aspenmesh/aspenmesh-cloud-tf.git
```

#### Step 2: Run Terraform Init for the EKS cluster

Initialize a working directory with configuration files

```shell script
cd aspenmesh-cloud-tf/eks-cluster
terraform init
```

#### Step 5: Run Terraform plan for the EKS cluster

```shell script
terraform plan
```

#### Step 6: Run Terraform apply for the EKS cluster

```shell script
terraform apply
```

#### Step 7: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command.  This command is also an output after applying the configuration.

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

## How to Destroy

The following commands destroy the resources created by `terraform apply`:

```shell script
cd aspenmesh-cloud-tf/eks-cluster
terraform destroy
```

