# Flux All-In-One distribution

.ONESHELL:
.SHELLFLAGS += -e

VERSION:=main

.PHONY: tools
tools: ## Install cue, kind, kubectl, kustomize, FLux CLI and other tools with Homebrew
	brew bundle

.PHONY: install
install: ## Generate manifests and Install Flux
	@cue install

.PHONY: uninstall
uninstall: ## Uninstall Flux
	@flux uninstall --silent

.PHONY: automate
automate: ## Configure Flux to automatically upgrade itself
	@cue automate

.PHONY: vet
vet: ## Format and vet all CUE definitions
	@cue fmt ./... && cue vet --all-errors --concrete ./...

.PHONY: gen
gen: vet ## Print the CUE generated objects
	@cue gen

.PHONY: ls
ls: ## List the CUE generated objects
	@cue ls

.PHONY: publish
publish:
	@cue publish

.PHONY: import-k8s
import-k8s:
	go get -u k8s.io/api/...
	go get -u k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1
	cue get go k8s.io/api/...
	cue get go k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1

.PHONY: import-crds
import-crds:
	@cd distribution
	@kustomize build github.com/fluxcd/flux2/manifests/crds?ref=$(VERSION) > crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p distribution crds.yaml
	@rm crds.yaml

.PHONY: list-images
list-images:
	@flux install --export | grep 'image:'| awk '$2 != "" { print $2}' | sort -u

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
