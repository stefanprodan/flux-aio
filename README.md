# flux-aio

[![flux](https://img.shields.io/badge/flux-v2.1.2-9cf)](https://fluxcd.io)
[![test](https://github.com/stefanprodan/flux-aio/workflows/test/badge.svg)](https://github.com/stefanprodan/flux-aio/actions)
[![license](https://img.shields.io/github/license/stefanprodan/flux-aio.svg)](https://github.com/stefanprodan/flux-aio/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/stefanprodan/flux-aio/all.svg)](https://github.com/stefanprodan/flux-aio/releases)

Flux All-In-One is an experimental distribution made with [Timoni](https://timoni.sh/)
for running the Flux controllers as single unit (Kubernetes Pod).

## Specifications

This distribution is optimized for running Flux at scale on:

- Bare clusters without a CNI plugin installed
- Edge clusters with limited CPU and memory resources
- Clusters where plain HTTP communication is not allowed between pods
- Clusters with egress via HTTP/S proxies
- Serverless clusters for cost optimisation (EKS Fargate)

Flux controllers included in this distribution:

- [source-controller](https://github.com/fluxcd/source-controller)
- [kustomize-controller](https://github.com/fluxcd/kustomize-controller)
- [helm-controller](https://github.com/fluxcd/helm-controller)
- [notification-controller](https://github.com/fluxcd/notification-controller)

On clusters without a CNI the Flux pod binds to the following ports on the host network:

- `9292` notification-controller webhook receiver endpoint
- `9690` notification-controller events receiver endpoint
- `9790` source-controller storage endpoint
- `9791-9799` metrics, liveness and readiness endpoints

## Install Flux with Timoni

To deploy Flux on Kubernetes clusters, you'll be using
the Timoni CLI and a Timoni [Bundle file](https://timoni.sh/bundle/)
where you'll define the configuration of the Flux controllers and their settings.

Install the Timoni CLI with:

```shell
brew install stefanprodan/tap/timoni
```

For other installation methods,
see [timoni.sh](https://timoni.sh/install/).

### Install Flux on self-managed clusters

To deploy Flux AIO on a cluster without a CNI, create a Timoni Bundle file
named `flux-aio.cue` with the following content: 

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-aio"
				version: "2.1.2"
			}
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "privileged"
				controllers: notification: enabled: false
			}
		}
	}
}
```

Apply the bundle with:

```shell
timoni bundle apply -f ./flux-aio.cue
```

You can fine tune the Flux installation using various options listed in
the [flux-aio module readme](modules/flux-aio/README.md#configuration).

Changes to the `flux-aio.cue` bundle, can be applied in dry-run mode
to see how Timoni will reconfigure Flux on the cluster:

```shell
timoni bundle apply -f ./flux-aio.cue --dry-run --diff
```

### Install Flux on managed clusters

When installing Flux on a managed Kubernetes cluster, the host network can be disabled
if the cloud vendor has already setup a CNI for you. You can also configure
persistent storage for Flux artifacts cache to speed up the startup after a pod eviction.

To grant Flux access to cloud resources such as container registries (for pulling OCI artifacts)
or KMS (for secretes decryption), you can use Kubernetes Workload Identity to bind the `flux`
service account from the `flux-system` namespace to an IAM role.

For example, on an EKS cluster with IRSA enabled, grant Flux access to ECR
by specified an AWS role ARN:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: {
				hostNetwork: false
				workload: {
					identity: "arn:aws:iam::111122223333:role/my-role"
					provider: "aws"
				}
				persistence: {
					enabled:      true
					storageClass: "standard"
					size:         "8Gi"
				}
			}
		}
	}
}
```

For Azure Workload Identity, the type must be set to `azure` and the identity set to the Azure Client ID.

For Google Cloud, the type must be set to `gcp` and the identity set to the GCP Identity Name.

## Configure Flux Git sync

To configure Flux to deploy workloads from a Git repository,
you'll be using the [flux-git-sync](modules/flux-git-sync/README.md) Timoni module.

This module generates Flux `GitRepository` and `Kustomization` objects and allows
the configuration of the Git URL, auth token, branch, path, interval, health checks.

### Sync from a public Git repository

To deploy the latest version of Cilium CNI and the metrics-server cluster addon,
add the `cluster-addons` instance to the `flux-aio.cue` bundle:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: securityProfile: "privileged"
		}
		"cluster-addons": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "flux-system"
			values: git: {
				url:  "https://github.com/stefanprodan/flux-aio"
				ref:  "refs/heads/main"
				path: "./test/cluster-addons"
			}
		}
	}
}
```

The above configuration, will instruct Flux to reconcile the `HelmRelease` manifests
from the [test/cluster-addons](/test/cluster-addons) directory.

Apply the bundle with:

```shell
timoni bundle apply -f ./flux-aio.cue
```

Timoni will configure the Flux Git sync and will wait for Flux to pull the repo and
deploy the cluster addons.

### Sync from a private Git repository

To configure Flux to sync with a private Git repository,
you can specify a Git token (GitHub PAT, GitLab deploy token, BitBucket token, etc).

To avoid storing sensitive information in your bundle files,
Timoni can read values from environment variable.

For example, to sync the cluster addons from your own private repo:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		// flux instance omitted for brevity 
		"cluster-addons": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "flux-system"
			values: git: {
				token: string @timoni(runtime:string:GITHUB_TOKEN)
				url:   "https://github.com/my-org/my-private-repo"
				ref:   "refs/heads/main"
				path:  "./test/cluster-addons"
			}
		}
	}
}
```

Assuming the `GITHUB_TOKEN` is set in your environment, apply the bundle
using the `--runtime-from-env` flag and Timoni will fill in the token value:

```shell
timoni bundle apply -f ./flux-aio.cue --runtime-from-env
```

To learn more about Timoni bundles, please see the documentation on
[Bundle API](https://timoni.sh/bundle/) and [Bundle Runtime API](https://timoni.sh/bundle-runtime/).

## Flux multi-tenancy

To enable Flux [multi-tenancy lockdown](https://fluxcd.io/flux/installation/configuration/multitenancy/),
you can set the security profile to `restricted`.

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: {
				securityProfile: "restricted"
			}
		}
	}
}
```

With the restricted profile, Flux Kustomizations and HelmReleases
can't create cluster-wide resources (CRDs, Namespaces, ClusterRoleBindings, etc)
unless they are deployed in the `flux-system` namespace.
The `flux-system` namespace, like `kube-system`, is reserved to cluster admins.

### Onboard tenants and their repositories

To configure Flux to deploy workloads from a tenant repository,
you'll be using the [flux-tenant](modules/flux-tenant/README.md)
and [flux-git-sync](modules/flux-git-sync/README.md) Timoni modules.

The `flux-tenant` module generates the tenant's Kubernetes namespace
and RBAC (service account & role binding) that constrains Flux to be able
to deploy applications only in that namespace.

The `flux-git-sync` module configures Flux to reconcile the tenant's Kubernetes
resources from their Git repository while impersonating the restricted service account.

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "dev-team"
	instances: {
		"dev-team": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-tenant"
			namespace: "dev-team-apps"
			values: role: "namespace-admin"
		}
		"dev-team-apps": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "dev-team-apps"
			values: {
				git: {
					token: string @timoni(runtime:string:DEVTEAM_TOKEN)
					url:   "https://github.com/org/dev-team-apps"
					ref:   "refs/heads/main"
					path:  "deploy/"
				}
				sync: targetNamespace: namespace
			}
		}
	}
}
```

On-board the tenant with:

```shell
export DEVTEAM_TOKEN=<GH TOKEN>
timoni bundle apply -f dev-team.cue --runtime-from-env
```

Off-board the tenant and remove all their workloads with:

```shell
timoni bundle delete dev-team
```

## Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads:

```shell
flux -n flux-system uninstall
```
