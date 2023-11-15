# flux-git-sync

A [timoni.sh](http://timoni.sh) module for configuring Flux
to deploy workloads to Kubernetes from a Git repository.

## Install

To create a sync:

```shell
timoni -n flux-system apply my-repo-sync oci://ghcr.io/stefanprodan/modules/flux-git-sync \
--values ./my-repo-sync.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n flux-system delete my-repo-sync
```

## Configuration

| Key                         | Type                  | Default           | Description                                                                                                                                |
|-----------------------------|-----------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `git: url:`                 | `string`              | `""`              | Git repository HTTPS URL                                                                                                                   |
| `git: ref:`                 | `string`              | `refs/heads/main` | Git [reference](https://fluxcd.io/flux/components/source/gitrepositories/#name-example)                                                    |
| `git: token:`               | `string`              | `""`              | Git token (e.g. GitHub PAT or GitLab Deploy Token) for connection to a private repository                                                  |
| `git: ca:`                  | `string`              | `""`              | Certificate Authority (`ca.crt` file content) for when using a Git server with self-signed TLS certs                                       |
| `git: path:`                | `string`              | `""`              | Path to the directory containing Kubernetes YAMLs                                                                                          |
| `git: interval:`            | `int`                 | `"1"`             | Interval in minutes to check for changes upstream                                                                                          |
| `sync: prune:`              | `bool`                | `true`            | Prune stale resources                                                                                                                      |
| `sync: wait:`               | `bool`                | `false`           | Wait for resources to become ready                                                                                                         |
| `sync: timeout:`            | `int`                 | `3`               | Wait timeout in minutes                                                                                                                    |
| `sync: serviceAccountName:` | `string`              | `""`              | Service account to impersonate                                                                                                             |
| `sync: targetNamespace:`    | `string`              | `""`              | Target namespace                                                                                                                           |
| `substitute:`               | `{[ string]: string}` | `{}`              | Configure [post build variable substitution](https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution) |
| `metadata: labels:`         | `{[ string]: string}` | `{}`              | Custom labels                                                                                                                              |
| `metadata: annotations:`    | `{[ string]: string}` | `{}`              | Custom annotations                                                                                                                         |
