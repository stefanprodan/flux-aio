# Flux All-In-One distribution

.ONESHELL:
SHELL := bash
.SHELLFLAGS += -eo pipefail

USER := stefanprodan
VERSION?=$(shell grep 'version:' modules/flux-aio/values.cue | awk '{ print $$2 }' | tr -d '"')

.PHONY: tools
tools: ## Install cue, kind, kubectl, Timoni and FLux CLIs
	brew bundle

.PHONY: install
install: ## Install Flux
	@timoni -n flux-system apply flux ./modules/flux-aio --timeout=5m

.PHONY: uninstall
uninstall: ## Uninstall Flux
	@flux -n flux-system uninstall --silent

.PHONY: fmt
fmt: ## Format all CUE definitions
	@timoni fmt .

.PHONY: fmt-check
fmt-check: ## Verify that all CUE definitions are formatted
	@timoni fmt --diff .

.PHONY: vet
vet: ## Vet modules
	@for dir in ./modules/* ; do
		echo "vetting $$dir"
		timoni mod vet $$dir --debug
	done

.PHONY: gen
gen: ## Print the CUE generated objects
	@cd modules/flux-aio
	@cue cmd -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 build

.PHONY: ls
ls: ## List the CUE generated objects
	@cd modules/flux-aio
	@cue cmd -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 ls

.PHONY: gen-deploy
gen-deploy: ## Print the Flux deployment
	@timoni -n flux-system build flux ./modules/flux-aio/ -f ./modules/flux-aio/debug_values.cue | yq e '. | select(.kind == "Deployment")'

# $(call push_module,<module name>,<description>)
define push_module
	@timoni mod push ./modules/$(1) oci://ghcr.io/$(USER)/modules/$(1) -v=$(VERSION:v%=%) --latest \
		--resolve-symlinks \
		--sign cosign \
		-a 'org.opencontainers.image.source=https://github.com/$(USER)/flux-aio'  \
		-a 'org.opencontainers.image.licenses=Apache-2.0' \
		-a 'org.opencontainers.image.description=$(2)' \
		-a 'org.opencontainers.image.documentation=https://github.com/$(USER)/flux-aio/blob/main/README.md'
endef

.PHONY: push-mod
push-mod: ## Push the Timoni modules to GHCR
	$(call push_module,flux-aio,A timoni.sh module for deploying Flux AIO.)
	$(call push_module,flux-git-sync,A timoni.sh module for configuring Flux Git reconciliation.)
	$(call push_module,flux-oci-sync,A timoni.sh module for configuring Flux OCI artifacts reconciliation.)
	$(call push_module,flux-tenant,A timoni.sh module for managing Flux tenants.)
	$(call push_module,flux-helm-release,A timoni.sh module for deploying Flux Helm Releases.)

.PHONY: push-manifests
push-manifests: ## Build and push the Flux manifests to GHCR
	@timoni -n flux-system build flux ./modules/flux-aio | flux push artifact \
		oci://ghcr.io/$(USER)/manifests/flux-aio:$(VERSION) \
		--source=https://github.com/fluxcd/flux2 \
		--revision=$(VERSION) \
		-f-

.PHONY: import-crds
import-crds: ## Update Flux API CUE definitions
	@cd modules/flux-aio/templates
	@kubectl kustomize https://github.com/fluxcd/flux2/manifests/crds?ref=$(VERSION) > crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p templates crds.yaml
	@rm crds.yaml

.PHONY: vendor-k8s
vendor-k8s: ## Update the shared Kubernetes API schemas in ./schemas
	@timoni mod vendor k8s ./schemas
	@cd schemas/cue.mod/gen/k8s.io
	@for dir in api/* ; do
		case $$dir in
			api/core|api/apps|api/rbac) ;;
			*) rm -rf $$dir ;;
		esac
	done
	@rm -rf apiextensions-apiserver

.PHONY: vendor-crds
vendor-crds: ## Update the shared Flux CRD schemas in ./schemas
	@timoni mod vendor crd ./schemas -f https://github.com/fluxcd/flux2/releases/download/$(VERSION)/install.yaml
	@cd schemas/cue.mod/gen
	@rm -rf image.toolkit.fluxcd.io \
	notification.toolkit.fluxcd.io

.PHONY: list-images
list-images:
	@echo "ghcr.io/fluxcd/flux-cli:$$(flux version --client | awk '$$2 != "" { print $$2}')"
	@flux install --export --components-extra source-watcher | grep 'image:' | awk '$$2 != "" { print $$2}' | sort -u

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
