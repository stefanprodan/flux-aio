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

| Key                      | Type                  | Default | Description                                                                               |
|--------------------------|-----------------------|---------|-------------------------------------------------------------------------------------------|
| `git: url:`              | `string`              | `""`    | Git repository HTTPS URL                                                                  |
| `git: branch:`           | `string`              | `main`  | Git branch                                                                                |
| `git: token:`            | `string`              | `""`    | Git token (e.g. GitHub PAT or GitLab Deploy Token) for connection to a private repository |
| `git: path:`             | `string`              | `""`    | Path to the directory containing Kubernetes YAMLs                                         |
| `git: interval:`         | `int`                 | `"1"`   | Interval in minutes to check for changes upstream                                         |
| `metadata: labels:`      | `{[ string]: string}` | `{}`    | Common labels for all resources                                                           |
| `metadata: annotations:` | `{[ string]: string}` | `{}`    | Common annotations for all resources                                                      |
