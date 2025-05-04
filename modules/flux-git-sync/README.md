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

| Key                          | Type                                                | Default           | Description                                                                                                                                |
|------------------------------|-----------------------------------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `git: url:`                  | `string`                                            | `""`              | Git repository HTTPS URL                                                                                                                   |
| `git: ref:`                  | `string`                                            | `refs/heads/main` | Git [reference](https://fluxcd.io/flux/components/source/gitrepositories/#name-example)                                                    |
| `git: ca:`                   | `string`                                            | `""`              | Certificate Authority (`ca.crt` file content) for when using a Git server with self-signed TLS certs                                       |
| `git: path:`                 | `string`                                            | `""`              | Path to the directory containing Kubernetes YAMLs                                                                                          |
| `git: ignore:`               | `string`                                            | `""`              | Multi-line string in the .gitignore format                                                                                                 |
| `git: interval:`             | `int`                                               | `"1"`             | Interval in minutes to check for changes upstream                                                                                          |
| `git: token:`                | `string`                                            | `""`              | Git token (e.g. GitHub PAT or GitLab Deploy Token) for connection to a private repository                                                  |
| `github: appID:`             | `string`                                            | `""`              | GitHub App ID for connection to a private GitHub repository                                                                                |
| `github: appInstallationID:` | `string`                                            | `""`              | GitHub App Installation ID                                                                                                                 |
| `github: appPrivateKey:`     | `string`                                            | `""`              | GitHub App Private Key contents                                                                                                            |
| `sync: prune:`               | `bool`                                              | `true`            | Prune stale resources                                                                                                                      |
| `sync: wait:`                | `bool`                                              | `false`           | Wait for resources to become ready                                                                                                         |
| `sync: timeout:`             | `int`                                               | `3`               | Wait timeout in minutes                                                                                                                    |
| `sync: retryInterval:`       | `int`                                               | `5`               | Retry failed reconciliation interval in minutes                                                                                            |
| `sync: serviceAccountName:`  | `string`                                            | `""`              | Service account to impersonate                                                                                                             |
| `sync: targetNamespace:`     | `string`                                            | `""`              | Target namespace                                                                                                                           |
| `substitute:`                | `{[ string]: string}`                               | `{}`              | Configure [post build variable substitution](https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution) |
| `substituteFrom:`            | `[...{kind: string, name: string, optional: bool}]` | `[]`              | List of ConfigMaps and Secrets to use for variable substitution                                                                            |
| `dependsOn:`                 | `[...{name: string}]`                               | `{}`              | List of dependencies                                                                                                                       |
| `patches:`                   | `[...{patch: {...}}]`                               | `{}`              | Strategic merge and JSON patches, defined as inline YAML objects                                                                           |
| `decryption:`                | `{provider: string, secretRef: { name: string}}`    | `{}`              | Configure [decryption](https://fluxcd.io/flux/components/kustomize/kustomizations/#decryption)                                             |
| `metadata: labels:`          | `{[ string]: string}`                               | `{}`              | Custom labels                                                                                                                              |
| `metadata: annotations:`     | `{[ string]: string}`                               | `{}`              | Custom annotations                                                                                                                         |
