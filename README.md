# flux-aio

[![test](https://github.com/stefanprodan/flux-aio/workflows/test/badge.svg)](https://github.com/stefanprodan/flux-aio/actions)
[![license](https://img.shields.io/github/license/stefanprodan/flux-aio.svg)](https://github.com/stefanprodan/flux-aio/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/stefanprodan/flux-aio/all.svg)](https://github.com/stefanprodan/flux-aio/releases)

Flux All-In-One is an experimental distribution made with [cuelang](https://cuelang.org/)
for running [Flux](https://fluxcd.io) on Kubernetes clusters without a CNI plugin being
installed in advance.

The main difference to the upstream distribution, is that Flux AIO bundles
all the controllers into a single Kubernetes Deployment.
The communication between controllers happens on the loopback interface, hence
Flux can function on clusters which don't have a CNI plugin installed.
This allows Kubernetes operators to setup their clusters networking in a GitOps way.

## Get started

### Prerequisites

Start by cloning the repository locally:

```shell
git clone https://github.com/stefanprodan/flux-aio.git
cd flux-aio
```

Install cue, kubectl and flux with Homebrew:

```shell
brew bundle
```

The complete list of tools can be found in the `Brewfile`.

### Install Flux

Deploy Flux AIO on your cluster with `cue install`:

```console
$ cue install 

namespace/flux-system serverside-applied
serviceaccount/flux serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/flux serverside-applied
service/webhook-receiver serverside-applied
deployment.apps/flux serverside-applied
customresourcedefinition.apiextensions.k8s.io/alerts.notification.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/buckets.source.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/gitrepositories.source.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/helmcharts.source.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/helmreleases.helm.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/helmrepositories.source.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/kustomizations.kustomize.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/ocirepositories.source.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/providers.notification.toolkit.fluxcd.io serverside-applied
customresourcedefinition.apiextensions.k8s.io/receivers.notification.toolkit.fluxcd.io serverside-applied
Waiting for deployment "flux" rollout to finish: 0 of 1 updated replicas are available...
deployment "flux" successfully rolled out
```

### Configure Flux self-update

Configure Flux to update itself from
[ghcr.io/stefanprodan/manifests/flux-aio](https://github.com/users/stefanprodan/packages/container/package/manifests%2Fflux-aio)
with `cue automate`:

```console
$ cue automate

ocirepository.source.toolkit.fluxcd.io/flux-source serverside-applied
kustomization.kustomize.toolkit.fluxcd.io/flux-sync serverside-applied
kustomization.kustomize.toolkit.fluxcd.io/flux-sync condition met
```

### Uninstall Flux

To remove Flux from your cluster, without affecting any reconciled workloads, run `flux uninstall`.
