# Flux

Flux All-In-One is an experimental distribution made with [cuelang](https://cuelang.org/)
for running [Flux](https://fluxcd.io) on Kubernetes clusters without a CNI plugin being
installed in advance.

## Module Repository

This module is available on GitHub Container Registry at
[ghcr.io/stefanprodan/modules/flux](https://github.com/stefanprodan/podinfo/pkgs/container/modules%2Fflux).

## Install

To install Flux using the default values:

```shell
timoni -n flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio
```

To install a specific Flux version:

```shell
timoni flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio -v 2.1.1
```

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
	securityProfile: "restricted"
}
```

And apply the values with:

```shell
timoni -n flux-system apply flux oci://ghcr.io/stefanprodan/modules/flux-aio \
--values ./my-values.cue
```

## Uninstall

To uninstall Flux and delete all its Kubernetes resources:

```shell
flux -n flux-system uninstall
```

## Configuration

### General values

| Key                     | Type                               | Default                       | Description                                                                                                                                  |
|-------------------------|------------------------------------|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `hostNetwork:`          | `bool`                             | `true`                        | Host network must be enabled on bare-metal clusters without a CNI preinstalled                                                               |
| `securityProfile:`      | `string`                           | `privileged`                  | To enable Flux multi-tenancy lockdown set the value to `restricted`                                                                          |
| `workload: provider`    | `string`                           | `""`                          | Kubernetes workload identity provider, can be  `aws`, `azure` or `gcp`                                                                       |
| `workload: identity`    | `string`                           | `""`                          | Kubernetes workload ID, can be an AWS Role ARN, Azure Client ID, or GCP Identity Name                                                        |
| `reconcile: concurrent` | `int`                              | `5`                           | The maximum number of parallel reconciliations per controller                                                                                |
| `reconcile: requeue`    | `int`                              | `30`                          | The interval in seconds at which failing dependencies are reevaluated                                                                        |
| `logLevel:`             | `string`                           | `info`                        | Flux log level can be `debug`, `info`, `error`                                                                                               |
| `resources:`            | `corev1.#ResourceRequirements`     | `limits: memory: "1Gi"`       | [Kubernetes resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers)                     |
| `tolerations:`          | `[ ...corev1.#Toleration]`         | `[{operator: "Exists"}]`      | [Kubernetes toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration)                                        |
| `securityContext:`      | `corev1.#SecurityContext`          | `capabilities: drop: ["ALL"]` | [Kubernetes container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context)                           |
| `imagePullSecrets:`     | `[...corev1.LocalObjectReference]` | `[]`                          | [Kubernetes image pull secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)                 |
| `affinity:`             | `corev1.#Affinity`                 | `{}`                          | [Kubernetes affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
