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

| Key                         | Type                  | Default | Description                    |
|-----------------------------|-----------------------|---------|--------------------------------|
| `repository: url:`          | `string`              | `""`    | Helm repository URL            |
| `chart: name:`              | `string`              | `""`    | Helm chart name                |
| `chart: version:`           | `string`              | `"*"`   | Helm chart name semver range   |
| `sync: interval:`           | `int`                 | `60`    | Reconcile interval             |
| `sync: serviceAccountName:` | `string`              | `""`    | Service account to impersonate |
| `helmValues`                | `{...}`               | `{}`    | Helm values                    |
| `metadata: labels:`         | `{[ string]: string}` | `{}`    | Custom labels                  |
| `metadata: annotations:`    | `{[ string]: string}` | `{}`    | Custom annotations             |
