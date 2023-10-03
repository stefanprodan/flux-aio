# flux-aio

[![flux](https://img.shields.io/badge/flux-v2.1.1-9cf)](https://fluxcd.io)
[![test](https://github.com/stefanprodan/flux-aio/workflows/test/badge.svg)](https://github.com/stefanprodan/flux-aio/actions)
[![license](https://img.shields.io/github/license/stefanprodan/flux-aio.svg)](https://github.com/stefanprodan/flux-aio/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/stefanprodan/flux-aio/all.svg)](https://github.com/stefanprodan/flux-aio/releases)

Flux All-In-One is an experimental distribution made with [Timoni](https://github.com/stefanprodan/timoni)
for running [Flux](https://fluxcd.io) on Kubernetes clusters without a CNI plugin being
installed in advance.

## Specifications

The main difference to the upstream distribution, is that Flux AIO bundles
all the controllers into a single Kubernetes Deployment.
The communication between controllers happens on the loopback interface, hence
Flux can function on clusters which don't have a CNI plugin installed.
This allows Kubernetes operators to setup their clusters networking in a GitOps way.

The Flux pod binds to the following ports on the host network:

- `9292` notification-controller webhook receiver endpoint
- `9690` notification-controller events receiver endpoint
- `9790` source-controller storage endpoint
- `9791-9799` metrics, liveness and readiness endpoints

## Get started

### Prerequisites

Install the Timoni CLI with:

```shell
brew install stefanprodan/tap/timoni
```

For other installation methods,
see [timoni.sh](https://timoni.sh/install/).

### Install Flux on self-managed clusters

To deploy Flux AIO on a cluster without a CNI,
create a Timoni bundle with the host network value enabled: 

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		flux: {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-aio"
				version: "2.1.1"
			}
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "privileged"
			}
		}
	}
}
```

And apply the bundle with:

```shell
timoni bundle apply -f ./flux-aio.cue
```

To enable Flux multi-tenancy lockdown, you can set the security profile to `restricted`,
as documented in the [module readme](modules/flux-aio/README.md#configuration).

### Install Flux on managed clusters

When installing Flux on a managed Kubernetes cluster, the host network can be disabled
if the cloud vendor has already setup a CNI for you.

To grant Flux access to cloud resources such as container registries (for pulling OCI artifacts)
or KMS (for secretes decryption), you can use Kubernetes Workload Identity to bind the `flux`
service account from the `flux-system` namespace to an IAM role.

For example, on an EKS cluster with IRSA enabled, grant Flux access to ACR by specified an AWS role ARN:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		flux: {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: {
				hostNetwork: false
				workload: {
					identity: "arn:aws:iam::111122223333:role/my-role"
					provider: "aws"
				}
			}
		}
	}
}
```

For Azure Workload Identity, the type must be set to `azure` and the identity set to the Azure Client ID.

For Google Cloud, the type must be set to `gcp` and the identity set to the GCP Identity Name.

### Configure Flux Git sync

To configure Flux to deploy workloads from a Git repository,
you can use the [flux-git-sync](modules/flux-git-sync/README.md) module.

For example, to deploy the latest version of Cilium CNI and the metrics server cluster addon,
add the `cluster-addons` instance to the `flux-aio.cue` bundle:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		flux: {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "privileged"
			}
		}
		"cluster-addons": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "flux-system"
			values: git: {
				url:  "https://github.com/stefanprodan/flux-aio"
				ref:  "refs/head/main"
				path: "./test/cluster-addons"
			}
		}
	}
}
```

The above configuration, will generate a Flux GitRepository and Kustomization for
reconciling the HelmReleases defined in the [test/cluster-addons](/test/cluster-addons)
directory from this repository.

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
				token: "" @timoni(runtime:string:GITHUB_TOKEN)
				url:   "https://github.com/my-org/my-private-repo"
				ref:   "refs/head/main"
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

### Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads:

```shell
flux -n flux-system uninstall
```
