# Shared schemas

This CUE module holds the single copy of the vendored schemas used by all
Timoni modules in this repository:

- `cue.mod/pkg/timoni.sh` — the Timoni core schemas
- `cue.mod/gen/k8s.io` — the Kubernetes API schemas
- `cue.mod/gen/*.fluxcd.io` — the Flux CRD schemas

Instead of vendoring these into every module, each module symlinks them:

```shell
ln -s ../../../../schemas/cue.mod/gen/k8s.io modules/my-module/cue.mod/gen/k8s.io
```

Timoni v0.30 or newer follows the symlinks when building, vetting and pushing
modules. Publishing to a registry requires the `--resolve-symlinks` flag,
which packages the symlink targets as regular files:

```shell
timoni mod push ./modules/my-module oci://ghcr.io/org/my-module -v 1.0.0 --resolve-symlinks
```

## Updating

```shell
make vendor-k8s   # update the Kubernetes API schemas
make vendor-crds  # update the Flux CRD schemas
```

Both targets vendor into this module and prune the API groups that no module
imports. The Timoni core schemas under `cue.mod/pkg` are the ones shipped with
`timoni mod init` and are updated by hand when upgrading Timoni.
