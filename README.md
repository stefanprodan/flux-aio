# flux-aio

[![flux](https://img.shields.io/badge/flux-v2.0.1-9cf)](https://fluxcd.io)
[![test](https://github.com/stefanprodan/flux-aio/workflows/test/badge.svg)](https://github.com/stefanprodan/flux-aio/actions)
[![license](https://img.shields.io/github/license/stefanprodan/flux-aio.svg)](https://github.com/stefanprodan/flux-aio/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/stefanprodan/flux-aio/all.svg)](https://github.com/stefanprodan/flux-aio/releases)

Flux All-In-One is an experimental distribution made with [Timoni](https://github.com/stefanprodan/timoni)
for running [Flux](https://fluxcd.io) on Kubernetes clusters without a CNI plugin being
installed in advance.

The main difference to the upstream distribution, is that Flux AIO bundles
all the controllers into a single Kubernetes Deployment.
The communication between controllers happens on the loopback interface, hence
Flux can function on clusters which don't have a CNI plugin installed.
This allows Kubernetes operators to setup their clusters networking in a GitOps way.

## Get started

### Prerequisites

Install the Timoni CLI with:

```shell
brew install stefanprodan/tap/timoni
```

For other installation methods,
see [timoni.sh](https://timoni.sh/install/).

### Install Flux

Deploy Flux AIO on your cluster with Timoni:

```shell
timoni -n flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio
```

The Flux pod binds to the following ports on the host network:

- `9292` notification-controller webhook receiver endpoint
- `9690` notification-controller events receiver endpoint
- `9790` source-controller storage endpoint
- `9791-9799` metrics, liveness and readiness endpoints

### Configure Flux

To pin Flux to a particular version or/and to change the
[default configuration](modules/flux-aio/README.md#configuration),
create a Timoni bundle file. For example, to enable Flux multi-tenancy lockdown,
create a file `flux-aio.cue` with the following content:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		flux: {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-aio"
				version: "2.0.1"
			}
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "restricted"
			}
		}
	}
}
```

And apply the bundle with:

```shell
timoni bundle apply -f ./flux-aio.cue
```

### Workload Identity

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

### Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads:

```shell
flux -n flux-system uninstall
```
