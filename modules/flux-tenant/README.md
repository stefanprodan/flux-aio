# flux-tenant

A [timoni.sh](http://timoni.sh) module for managing Flux tenants.

## Install

To create a tenant:

```shell
timoni -n my-tenant-apps apply my-tenant oci://ghcr.io/stefanprodan/modules/flux-tenant \
--values ./my-tenant.cue
```

## Uninstall

To remove the tenant and delete all its Kubernetes resources:

```shell
timoni -n my-tenant-apps delete my-tenant
```

## Configuration

| Key                              | Type                  | Default           | Description                                                                                                                                                                    |
|----------------------------------|-----------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role:`                          | `string`              | `namespace-admin` | Restrict the Flux service account to the tenant's namespace using a role binding to `admin`. Can be set to `cluster-admin` for granting full read-write access to the cluster. |
| `fluxServiceAccountName:`        | `string`              | `flux`            | Service account to impersonate                                                                                                                                                 |
| `resourceQuota: kustomizations:` | `int`                 | `100`             | Max number of Flux Kustomizations                                                                                                                                              |
| `resourceQuota: helmreleases:`   | `int`                 | `100`             | Max number of Flux HelmReleases                                                                                                                                                |
| `metadata: labels:`              | `{[ string]: string}` | `{}`              | Custom labels                                                                                                                                                                  |
| `metadata: annotations:`         | `{[ string]: string}` | `{}`              | Custom annotations                                                                                                                                                             |
