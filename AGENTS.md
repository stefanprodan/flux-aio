# AGENTS.md

Guidance for AI agents working in the **flux-aio** repository.

## Project overview

flux-aio is a [Flux](https://fluxcd.io) distribution that runs all Flux
controllers in a **single pod**, packaged as [Timoni](https://timoni.sh) modules
written in [CUE](https://cuelang.org). It targets small/edge/serverless clusters
(K3s, EKS Fargate, etc.).

Versioning follows `<flux version>-<distribution release number>`, e.g. `2.9.0-0`.

## Repository layout

- `modules/flux-aio/` — the main module: deploys all controllers in one pod.
  - `values.cue` — production controller image tags and the Flux `version`. **Edit this to change shipped versions.**
  - `debug_values.cue` — values used only by `make gen-deploy`/`make vet` for local debugging. Kept one minor release behind production.
  - `templates/` — CUE templates for the Deployment, RBAC, services, etc.
  - `templates/crds.cue` — **generated** Flux CRDs (do not hand-edit; see below).
- `modules/flux-git-sync/`, `flux-oci-sync/`, `flux-helm-release/`, `flux-tenant/` — companion modules for Git/OCI sync, Helm releases, and tenant setup.
  - `*/cue.mod/gen/**/types_gen.cue` — **generated** CUE schemas vendored from Flux CRDs (do not hand-edit; see below).
- `bundles/` — Timoni bundles wiring the modules together.
- `test/` — kind cluster and addon test fixtures.
- `Makefile` — all build/codegen/release tasks. `Brewfile` — required CLIs.

## Prerequisites

Install the toolchain with `make tools` (uses `Brewfile`): `cue`, `kubectl`,
`kind`, `flux`, `timoni`.

## Common commands

| Command | Purpose |
|---|---|
| `make fmt` | Format all CUE definitions. Run before committing. |
| `make vet` | Vet every module (validates rendered resources). Run before committing. |
| `make gen-deploy` | Render the single-pod Deployment using `debug_values.cue`. |
| `make install` / `make uninstall` | Apply / remove Flux on the current cluster. |
| `make import-crds` | Regenerate `modules/flux-aio/templates/crds.cue`. |
| `make vendor-crds` | Regenerate the `types_gen.cue` schemas in the sync modules. |
| `make list-images` | Print the controller images for the installed `flux` CLI. |

`VERSION` is derived automatically from the `version:` field in
`modules/flux-aio/values.cue`, so the codegen targets read whatever version you
set there.

**Never hand-edit generated files** (`templates/crds.cue`,
`*/cue.mod/gen/**/types_gen.cue`); always regenerate them via the Makefile.

## Updating to a new Flux version

This is the canonical workflow (e.g. the `2.8.x` → `2.9.0` upgrade). Replace
`v2.9.0` below with the target Flux release.

1. **Find the target versions.** The `flux` CLI must match the release you are
   upgrading to (`make tools` / `brew upgrade flux`). Then list the controller
   images:
   ```bash
   flux version --client    # confirm CLI == target Flux version
   make list-images         # prints the flux-cli + the five controller images
   ```
   `make list-images` yields the `source/kustomize/notification/helm-controller`
   and `source-watcher` image tags for the installed CLI.

2. **Bump `modules/flux-aio/values.cue`** — set `version:` to the new Flux
   version (e.g. `v2.9.0`) and update all five controller image `tag:` fields to
   the values from step 1. The Makefile reads `VERSION` from this file, so do
   this first.

3. **Regenerate the CRDs and vendored schemas:**
   ```bash
   make import-crds    # rewrites modules/flux-aio/templates/crds.cue
   make vendor-crds    # rewrites the types_gen.cue files in the sync modules
   ```

4. **Prune any new, unused CRD API groups.** Each sync module vendors only the
   CRDs it needs; the `vendor-crds-*` targets `rm -rf` the rest. When Flux adds a
   new API group, `vendor-crds` leaves it as **untracked** files under
   `modules/*/cue.mod/gen/`. Check `git status` for untracked dirs after step 3.
   If a new group isn't used by the sync modules, delete the untracked dirs and
   add the group to the `rm -rf` lists in the three `vendor-crds-*` Makefile
   targets so it's pruned automatically next time.
   - Example: Flux 2.9 added `source.extensions.fluxcd.io` (ArtifactGenerator),
     which was removed from the sync modules and added to the cleanup lists.

5. **Update `modules/flux-aio/debug_values.cue`** — bump it to the *previous*
   stable release's `version:` and controller tags (it intentionally lags one
   minor behind production for upgrade-path debugging).

6. **Update `README.md`** — the `flux-vX.Y.Z` badge and the versioning example
   (`2.9.0-0`).

7. **Validate:**
   ```bash
   make fmt
   make vet                                     # all modules must report "valid module"
   timoni -n flux-system build flux ./modules/flux-aio \
     | grep -oE 'ghcr.io/fluxcd/[a-z-]+:v[0-9.]+' | sort -u   # confirm new images render
   ```

8. **Commit & push.** Branch `flux-X.Y.Z`, signed-off commit
   `Update Flux to vX.Y.Z` (matches existing history):
   ```bash
   git checkout -b flux-2.9.0
   git add -A
   git commit -s -m "Update Flux to v2.9.0"
   git push -u origin flux-2.9.0
   ```

Releasing the distribution (pushing modules/manifests to GHCR via `make
push-mod` / `make push-manifests`) is handled separately by the maintainer.

## Conventions

- Tabs for indentation in CUE/Makefile (CUE is tab-indented; `make fmt` enforces it).
- Commit messages: short imperative summary, signed off (`git commit -s`).
- Always run `make fmt` and `make vet` before committing.
