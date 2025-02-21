# flux-aio

[![flux](https://img.shields.io/badge/flux-v2.5.0-9cf)](https://fluxcd.io)
[![test](https://github.com/stefanprodan/flux-aio/workflows/test/badge.svg)](https://github.com/stefanprodan/flux-aio/actions)
[![license](https://img.shields.io/github/license/stefanprodan/flux-aio.svg)](https://github.com/stefanprodan/flux-aio/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/stefanprodan/flux-aio/all.svg)](https://github.com/stefanprodan/flux-aio/releases)

Flux All-In-One is a lightweight distribution made
with [Timoni](https://timoni.sh) for running the GitOps Toolkit controllers as a
single deployable unit (Kubernetes Pod).

This distribution is optimized for running [Flux](https://fluxcd.io) on:

- Bare clusters without a CNI plugin installed
- Edge clusters with limited CPU and memory resources
- Clusters where plain HTTP communication is not allowed between pods
- Clusters with egress via HTTP/S proxies
- Serverless clusters for cost optimisation (EKS Fargate)

The versioning of this distribution follows semver with the following format:
`<flux version>-<distribution release number>`, e.g. `2.5.0-0`.

## Documentation

- [Distribution specifications](https://timoni.sh/flux-aio/#specifications)
- [Flux installation and upgrade](https://timoni.sh/flux-aio/#flux-installation)
- [Flux OCI sync configuration](https://timoni.sh/flux-aio/#flux-oci-sync-configuration)
- [Flux Git sync configuration](https://timoni.sh/flux-aio/#flux-git-sync-configuration)
- [Flux multi-tenancy configuration](https://timoni.sh/flux-aio/#flux-multi-tenancy-configuration)

## Quickstart Guide

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
				version: "latest"
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
timoni bundle apply -f flux-aio.cue
```

Note that on clusters without `kube-proxy`, you'll have to add the following env vars to values:

```cue
values: env: {
	"KUBERNETES_SERVICE_HOST": "<host>"
	"KUBERNETES_SERVICE_PORT": "<port>"
}
```

Note that on [Talos](https://github.com/siderolabs/talos) clusters, you'll have to set the pod security profile to
`privileged`:

```cue
values: {
	hostNetwork:     true
	podSecurityProfile: "privileged"
}
```

You can fine tune the Flux installation using various options, for more information see
the [installation guide](https://timoni.sh/flux-aio/#flux-installation).

Changes to the `flux-aio.cue` bundle, can be applied in dry-run mode
to see how Timoni will reconfigure Flux on the cluster:

```shell
timoni bundle apply -f flux-aio.cue --dry-run --diff
```

### Sync from a public Git repository

To deploy the latest version of Cilium CNI and the metrics-server cluster addon,
add the `cluster-addons` instance to the `flux-aio.cue` bundle:

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
timoni bundle apply -f flux-aio.cue
```

Timoni will configure the Flux Git sync and will wait for Flux to pull the repo and
deploy the cluster addons.

For more details on how to sync from private Git repositories and self-hosted Git servers,
see the [Git sync documentation](https://timoni.sh/flux-aio/#flux-git-sync-configuration).

### Sync from a bootstrap repository

If you want to use Flux AIO with a bootstrap repository layout, you'll have to add an ignore
rule for the `flux-system` directory and name the sync instance `flux-system`:

```cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		// flux instance omitted for brevity
		"flux-system": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
			namespace: "flux-system"
			values: {
				git: {
					token:  string @timoni(runtime:string:GITHUB_TOKEN)
					url:    "https://github.com/fluxcd/flux2-kustomize-helm-example.git"
					ref:    "refs/heads/main"
					path:   "clusters/production"
					ignore: "clusters/**/flux-system/"
				}
				sync: wait: false
			}
		}
	}
}
```

The above configuration, generates the same `flux-system` objects (`GitRepository`, `Secret`, `Kustomization`)
as the `flux bootstrap` command.

### Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads:

```shell
flux -n flux-system uninstall
```
