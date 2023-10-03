# Flux All-In-One distribution

.ONESHELL:
.SHELLFLAGS += -e

VERSION:=$(shell grep 'version:' modules/flux-aio/values.cue | awk '{ print $$2 }' | tr -d '"')

.PHONY: tools
tools: ## Install cue, kind, kubectl, Timoni and FLux CLIs
	brew bundle

.PHONY: install
install: ## Install Flux
	@timoni -n flux-system apply flux ./modules/flux-aio --timeout=5m

.PHONY: uninstall
uninstall: ## Uninstall Flux
	@flux -n flux-system uninstall --silent

.PHONY: vet
vet: ## Format and vet all CUE definitions
	@timoni mod lint modules/flux-aio
	@cd modules/flux-aio
	@cue fmt ./...

.PHONY: gen
gen: vet ## Print the CUE generated objects
	@cd modules/flux-aio
	@cue cmd -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 build

.PHONY: ls
ls: ## List the CUE generated objects
	@cd modules/flux-aio
	@cue cmd -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 ls

.PHONY: push-mod
push-mod: ## Push the Timoni module to GHCR
	@timoni mod push ./modules/flux-aio oci://ghcr.io/stefanprodan/modules/flux-aio -v=$(VERSION:v%=%) --latest \
		--sign cosign \
		-a 'org.opencontainers.image.source=https://github.com/stefanprodan/flux-aio'  \
		-a 'org.opencontainers.image.licenses=Apache-2.0' \
		-a 'org.opencontainers.image.description=A timoni.sh module for deploying Flux AIO.' \
		-a 'org.opencontainers.image.documentation=https://github.com/stefanprodan/flux-aio/blob/main/README.md'

.PHONY: push-manifests
push-manifests: ## Build and push the Flux manifests to GHCR
	@timoni -n flux-system build flux ./modules/flux-aio | flux push artifact \
		oci://ghcr.io/stefanprodan/manifests/flux-aio:$(VERSION) \
		--source=https://github.com/fluxcd/flux2 \
		--revision=$(VERSION) \
		-f-

.PHONY: import-crds
import-crds: ## Update Flux API CUE definitions
	@cd modules/flux-aio/templates
	@kubectl kustomize https://github.com/fluxcd/flux2/manifests/crds?ref=$(VERSION) > crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p templates crds.yaml
	@rm crds.yaml

.PHONY: vendor-crds
vendor-crds: ## Update Flux CRDs for Git sync
	@cd modules/flux-git-sync
	@timoni mod vendor crds -f https://github.com/fluxcd/flux2/releases/download/$(VERSION)/install.yaml
	@cd cue.mod/gen
	@rm -rf image.toolkit.fluxcd.io helm.toolkit.fluxcd.io notification.toolkit.fluxcd.io
	@rm -rf kustomize.toolkit.fluxcd.io/kustomization/v1beta1 kustomize.toolkit.fluxcd.io/kustomization/v1beta2
	@rm -rf source.toolkit.fluxcd.io/gitrepository/v1beta1 source.toolkit.fluxcd.io/gitrepository/v1beta2
	@rm -rf source.toolkit.fluxcd.io/bucket source.toolkit.fluxcd.io/ocirepository source.toolkit.fluxcd.io/helmrepository source.toolkit.fluxcd.io/helmchart

.PHONY: list-images
list-images:
	@echo "ghcr.io/fluxcd/flux-cli:$$(flux version --client | awk '$$2 != "" { print $$2}')"
	@flux install --export | grep 'image:' | awk '$$2 != "" { print $$2}' | sort -u

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
