# flux-aio

Flux All-In-One is an experimental distribution made with [cuelang](https://cuelang.org/)
for running [Flux](https://fluxcd.io) on Kubernetes clusters without a CNI plugin being
installed in advanced.

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

Install cue, kind, kubectl, flux and other CLI tools with Homebrew:

```shell
make tools
```

The complete list of tools can be found in the `Brewfile`.

### Install Flux

List the CUE generated resources with `make ls`:

```console
$ make ls

RESOURCE                                                                 API VERSION
Namespace/flux-system                                                    v1
ServiceAccount/flux-system/flux                                          v1
ClusterRoleBinding/flux                                                  rbac.authorization.k8s.io/v1
Service/flux-system/webhook-receiver                                     v1
Deployment/flux-system/flux                                              apps/v1
CustomResourceDefinition/alerts.notification.toolkit.fluxcd.io           apiextensions.k8s.io/v1
CustomResourceDefinition/buckets.source.toolkit.fluxcd.io                apiextensions.k8s.io/v1
CustomResourceDefinition/gitrepositories.source.toolkit.fluxcd.io        apiextensions.k8s.io/v1
CustomResourceDefinition/helmcharts.source.toolkit.fluxcd.io             apiextensions.k8s.io/v1
CustomResourceDefinition/helmreleases.helm.toolkit.fluxcd.io             apiextensions.k8s.io/v1
CustomResourceDefinition/helmrepositories.source.toolkit.fluxcd.io       apiextensions.k8s.io/v1
CustomResourceDefinition/kustomizations.kustomize.toolkit.fluxcd.io      apiextensions.k8s.io/v1
CustomResourceDefinition/ocirepositories.source.toolkit.fluxcd.io        apiextensions.k8s.io/v1
CustomResourceDefinition/providers.notification.toolkit.fluxcd.io        apiextensions.k8s.io/v1
CustomResourceDefinition/receivers.notification.toolkit.fluxcd.io        apiextensions.k8s.io/v1
```

Deploy Flux AIO on your cluster with `make install`:

```console
$ make install 

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
