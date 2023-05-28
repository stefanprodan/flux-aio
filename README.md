# flux-aio

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

To install or upgrade to a specific Flux version:

```console
$ timoni -n flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio -v 2.0.0-rc.3

pulling oci://ghcr.io/stefanprodan/modules/flux-aio:2.0.0-rc.3
using module timoni.sh/flux-aio version 2.0.0-rc.3
installing flux in namespace flux-system
Namespace/flux-system created
CustomResourceDefinition/alerts.notification.toolkit.fluxcd.io created
CustomResourceDefinition/buckets.source.toolkit.fluxcd.io created
CustomResourceDefinition/gitrepositories.source.toolkit.fluxcd.io created
CustomResourceDefinition/helmcharts.source.toolkit.fluxcd.io created
CustomResourceDefinition/helmreleases.helm.toolkit.fluxcd.io created
CustomResourceDefinition/helmrepositories.source.toolkit.fluxcd.io created
CustomResourceDefinition/imagepolicies.image.toolkit.fluxcd.io created
CustomResourceDefinition/imagerepositories.image.toolkit.fluxcd.io created
CustomResourceDefinition/imageupdateautomations.image.toolkit.fluxcd.io created
CustomResourceDefinition/kustomizations.kustomize.toolkit.fluxcd.io created
CustomResourceDefinition/ocirepositories.source.toolkit.fluxcd.io created
CustomResourceDefinition/providers.notification.toolkit.fluxcd.io created
CustomResourceDefinition/receivers.notification.toolkit.fluxcd.io created
Namespace/flux-system configured
ServiceAccount/flux-system/flux created
ClusterRoleBinding/flux created
Service/flux-system/source-controller created
Service/flux-system/webhook-receiver created
Deployment/flux-system/flux created
waiting for 19 resource(s) to become ready...
resources are ready
```

To change the [default configuration](modules/flux-aio/README.md#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, to enable Flux multi-tenancy lockdown,
create a file `flux-values.cue` with the following content:

```cue
values: {
	securityProfile: "restricted"
}
```

And apply the values with:

```shell
timoni -n flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio \
--values ./flux-values.cue
```

### Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads:

```shell
flux -n flux-system uninstall
```
