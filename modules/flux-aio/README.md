# Flux

Flux All-In-One is an experimental distribution made with [Timoni](https://github.com/stefanprodan/timoni)
for deploying [Flux](https://fluxcd.io) on Kubernetes clusters.

The main difference to the upstream distribution, is that Flux AIO bundles
all the controllers into a single Kubernetes Deployment.
The communication between controllers happens on the loopback interface, hence
Flux can function on clusters which don't have a CNI plugin installed.
This allows Kubernetes operators to setup their clusters networking in a GitOps way.

### Prerequisites

Install the Timoni CLI with:

```shell
brew install stefanprodan/tap/timoni
```

For other installation methods,
see [timoni.sh](https://timoni.sh/install/).

## Module Repository

This module is available on GitHub Container Registry at
[ghcr.io/stefanprodan/modules/flux](https://github.com/stefanprodan/podinfo/pkgs/container/modules%2Fflux).

## Install

Create a `flux-aio.cue` file with the following content:

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
	}
}
```

Install Flux by applying the Timoni bundle:

```shell
timoni bundle apply -f ./flux-aio.cue
```

## Uninstall

To uninstall Flux and delete all its Kubernetes resources:

```shell
flux -n flux-system uninstall
```

## Configuration

| Key                          | Type                               | Default                       | Description                                                                                                                                                                              |
|------------------------------|------------------------------------|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `hostNetwork:`               | `bool`                             | `true`                        | Host network must be enabled on bare-metal clusters without a CNI preinstalled                                                                                                           |
| `securityProfile:`           | `string`                           | `privileged`                  | To enable Flux multi-tenancy lockdown set the value to `restricted`                                                                                                                      |
| `workload: provider`         | `string`                           | `""`                          | Kubernetes workload identity provider, can be  `aws`, `azure` or `gcp`                                                                                                                   |
| `workload: identity`         | `string`                           | `""`                          | Kubernetes workload ID, can be an AWS Role ARN, Azure Client ID, or GCP Identity Name                                                                                                    |
| `reconcile: concurrent`      | `int`                              | `5`                           | The maximum number of parallel reconciliations per controller                                                                                                                            |
| `reconcile: requeue`         | `int`                              | `30`                          | The interval in seconds at which failing dependencies are reevaluated                                                                                                                    |
| `persistence: enabled:`      | `bool`                             | `false`                       | Enable persistent storage for Flux artifacts                                                                                                                                             |
| `persistence: storageClass:` | `string`                           | `standard`                    | The [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) storage class name                                                                          |
| `persistence: size:`         | `string`                           | `8Gi`                         | The persistent volume size                                                                                                                                                               |
| `tmpfs: enabled:`            | `bool`                             | `false`                       | Enable RAM-backed filesystem for the Flux [emptyDir volume](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) to speed up the git pull and kustomize build operations       |
| `tmpfs: sizeLimit:`          | `string`                           | `null`                        | The tmpfs memory limit e.g. `500Mi` or `1Gi`                                                                                                                                             |
| `proxy: http:`               | `string`                           | `null`                        | HTTP Proxy URL                                                                                                                                                                           |
| `proxy: https:`              | `string`                           | `null`                        | HTTPS Proxy URL                                                                                                                                                                          |
| `env:`                       | `[string]: string`                 | `null`                        | Environment key values pairs for setting the `env` on all controller containers                                                                                                          |
| `logLevel:`                  | `string`                           | `info`                        | Flux log level can be `debug`, `info`, `error`                                                                                                                                           |
| `resources:`                 | `corev1.#ResourceRequirements`     | `limits: memory: "1Gi"`       | [Kubernetes resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) common to all containers, can be overridden by controller basis |
| `tolerations:`               | `[ ...corev1.#Toleration]`         | `[{operator: "Exists"}]`      | [Kubernetes toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration)                                                                                    |
| `securityContext:`           | `corev1.#SecurityContext`          | `capabilities: drop: ["ALL"]` | [Kubernetes container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context)                                                                       |
| `affinity:`                  | `corev1.#Affinity`                 | `{}`                          | [Kubernetes affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)                                             |
| `imagePullSecrets:`          | `[...corev1.LocalObjectReference]` | `[]`                          | [Kubernetes image pull secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)                                                             |
| `imagePullSecret: registry:` | `string`                           | `null`                        | Registry address for the generated image pull secret                                                                                                                                     |
| `imagePullSecret: username:` | `string`                           | `null`                        | Registry username for the generated image pull secret                                                                                                                                    |
| `imagePullSecret: password:` | `string`                           | `null`                        | Registry password for the generated image pull secret                                                                                                                                    |
| `compatibility:`             | `string`                           | `kubernetes`                  | Can be set to `openshift` to make the security context compatible with RedHat OpenShift                                                                                                  |                                                                                                 |
| `podSecurityProfile:`        | `string`                           | `""`                          | Can be `privileged` or `restricted`, used for setting the `pod-security.kubernetes.io` labels on the namespace                                                                           |

### Controllers

| Key                                    | Type                           | Default                                                | Description                                                                           |
|----------------------------------------|--------------------------------|--------------------------------------------------------|---------------------------------------------------------------------------------------|
| `controllers: source: image:`          | `timoniv1.#Image`              | `repository: "ghcr.io/fluxcd/source-controller"`       | Container image, tag and digest                                                       |
| `controllers: source: resources`       | `corev1.#ResourceRequirements` | `null`                                                 | Set resource requests and limits specific for the `source-controller` container       |
| `controllers: helm: enabled`           | `bool`                         | `true`                                                 | Include the `helm-controller` component                                               |
| `controllers: helm: image:`            | `timoniv1.#Image`              | `repository: "ghcr.io/fluxcd/source-controller"`       | Container image, tag and digest                                                       |
| `controllers: helm: resources`         | `corev1.#ResourceRequirements` | `null`                                                 | Set resource requests and limits specific for the `helm-controller` container         |
| `controllers: kustomize: enabled`      | `bool`                         | `true`                                                 | Include the `kustomize-controller` component                                          |
| `controllers: kustomize: image:`       | `timoniv1.#Image`              | `repository: "ghcr.io/fluxcd/kustomize-controller"`    | Container image, tag and digest                                                       |
| `controllers: kustomize: resources`    | `corev1.#ResourceRequirements` | `null`                                                 | Set resource requests and limits specific for the `kustomize-controller` container    |
| `controllers: notification: enabled`   | `bool`                         | `true`                                                 | Include the `notification-controller` component                                       |
| `controllers: notification: image:`    | `timoniv1.#Image`              | `repository: "ghcr.io/fluxcd/notification-controller"` | Container image, tag and digest                                                       |
| `controllers: notification: resources` | `corev1.#ResourceRequirements` | `null`                                                 | Set resource requests and limits specific for the `notification-controller` container |
| `expose: webhookReceiver:`             | `bool`                         | `false`                                                | Create the `webhook-reciver` Kubernetes Service                                       |
| `expose: notificationServer:`          | `bool`                         | `false`                                                | Create the `notification-controller` Kubernetes Service                               |
| `expose: sourceServer:`                | `bool`                         | `false`                                                | Create the `source-controller` Kubernetes Service                                     |
