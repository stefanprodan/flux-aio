# flux-oci-sync

A [timoni.sh](http://timoni.sh) module for configuring Flux
to deploy workloads to Kubernetes from OCI artifacts.

## Install

To create a sync:

```shell
timoni -n flux-system apply my-repo-sync oci://ghcr.io/stefanprodan/modules/flux-oci-sync \
--values ./my-repo-sync.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n flux-system delete my-repo-sync
```

## Configuration

| Key                            | Type                                                | Default     | Description                                                                                                                                |
|--------------------------------|-----------------------------------------------------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `artifact: url:`               | `string`                                            | `""`        | URL in the format `oci://<registry host>/<repository name>`                                                                                |
| `artifact: tag:`               | `string`                                            | `latest`    | OCI artifact tag                                                                                                                           |
| `artifact: semver:`            | `string`                                            | `""`        | OCI artifact tag semver range, when specified takes precedence over tag                                                                    |
| `artifact: interval:`          | `int`                                               | `"1"`       | Interval in minutes to check for changes upstream                                                                                          |
| `artifact: ignore:`            | `string`                                            | `""`        | Multi-line string in the .gitignore format                                                                                                 |
| `auth: provider:`              | `string`                                            | `"generic"` | Kubernetes workload identity provider, can be  `aws`, `azure` or `gcp`                                                                     |
| `auth: credentials: username:` | `string`                                            | `""`        | Username when using `dockerconfigjson` credentials                                                                                         |
| `auth: credentials: password:` | `string`                                            | `""`        | Password when using `dockerconfigjson` credentials, can be a personal access token (PAT) when using GitHub, GitLab, DockerHub, etc         |
| `tls: insecure:`               | `bool`                                              | `false`     | Allow connecting to an insecure non-TLS OCI registry server                                                                                |
| `tls: ca:`                     | `string`                                            | `""`        | Certificate Authority (`ca.crt` file content) for when using a OCI registry server with self-signed TLS certs                              |
| `sync: path:`                  | `string`                                            | `"./"`      | Path to the directory containing Kubernetes YAMLs                                                                                          |
| `sync: prune:`                 | `bool`                                              | `true`      | Prune stale resources                                                                                                                      |
| `sync: wait:`                  | `bool`                                              | `false`     | Wait for resources to become ready                                                                                                         |
| `sync: timeout:`               | `int`                                               | `3`         | Wait timeout in minutes                                                                                                                    |
| `sync: retryInterval:`         | `int`                                               | `5`         | Retry failed reconciliation interval in minutes                                                                                            |
| `sync: serviceAccountName:`    | `string`                                            | `""`        | Service account to impersonate                                                                                                             |
| `sync: targetNamespace:`       | `string`                                            | `""`        | Target namespace                                                                                                                           |
| `substitute:`                  | `{[ string]: string}`                               | `{}`        | Configure [post build variable substitution](https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution) |
| `substituteFrom:`              | `[...{kind: string, name: string, optional: bool}]` | `[]`        | List of ConfigMaps and Secrets to use for variable substitution                                                                            |
| `dependsOn:`                   | `[...{name: string}]`                               | `{}`        | List of dependencies                                                                                                                       |
| `patches:`                     | `[...{patch: {...}}]`                               | `{}`        | Strategic merge and JSON patches, defined as inline YAML objects                                                                           |
| `decryption:`                  | `{provider: string, secretRef: { name: string}}`    | `{}`        | Configure [decryption](https://fluxcd.io/flux/components/kustomize/kustomizations/#decryption)                                             |
| `metadata: labels:`            | `{[ string]: string}`                               | `{}`        | Custom labels                                                                                                                              |
| `metadata: annotations:`       | `{[ string]: string}`                               | `{}`        | Custom annotations                                                                                                                         |
