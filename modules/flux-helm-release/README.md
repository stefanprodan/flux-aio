# flux-helm-release

A [timoni.sh](http://timoni.sh) module for deploying Flux Helm Releases.

## Install

To create a Flux Helm Release:

```shell
timoni -n default apply podinfo oci://ghcr.io/stefanprodan/modules/flux-helm-release \
--values ./podinfo.cue
```

## Uninstall

To remove the Flux Helm Release and delete all its Kubernetes resources:

```shell
timoni -n default delete podinfo
```

## Configuration

| Key                           | Type                  | Default      | Description                                                         |
|-------------------------------|-----------------------|--------------|---------------------------------------------------------------------|
| `repository: url:`            | `string`              | `""`         | Helm repository URL                                                 |
| `repository: provider:`       | `string`              | `"generic"`  | Helm repository Cloud OIDC provider, can be `aws`, `azure` or `gcp` |
| `repository: auth: username:` | `string`              | `""`         | Helm repository username                                            |
| `repository: auth: password:` | `string`              | `""`         | Helm repository password                                            |
| `repository: insecure:`       | `bool`                | `false`      | Allow connecting to an insecure (HTTP) OCI registry server          |
| `chart: name:`                | `string`              | `""`         | Helm chart name                                                     |
| `chart: version:`             | `string`              | `"*"`        | Helm chart name semver range                                        |
| `sync: interval:`             | `int`                 | `60`         | Reconcile interval in minutes                                       |
| `sync: timeout:`              | `int`                 | `5`          | Timeout in minutes                                                  |
| `sync: serviceAccountName:`   | `string`              | `""`         | Service account to impersonate                                      |
| `sync: disableWait:`          | `bool`                | `false`      | Disables waiting for resource readiness after install/upgrade       |
| `dependsOn:`                  | `[...{name: string}]` | `{}`         | List of dependencies                                                |
| `driftDetection:`             | `string`              | `"disabled"` | Set drift detection mode, can be `enabled` or `warn`                |
| `test:`                       | `bool`                | `false`      | Run Helm tests after install and upgrade                            |
| `helmValues:`                 | `{...}`               | `{}`         | Helm values                                                         |
| `metadata: labels:`           | `{[ string]: string}` | `{}`         | Custom labels                                                       |
| `metadata: annotations:`      | `{[ string]: string}` | `{}`         | Custom annotations                                                  |
