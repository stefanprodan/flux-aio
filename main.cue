package main

import (
	distribution "github.com/stefanprodan/flux-aio/distribution"
)

aio: distribution.#Flux & {
	spec: {
		name:    "flux"
		version: "v0.38.1"
		controllers: {
			source:       "ghcr.io/fluxcd/source-controller:v0.33.0"
			kustomize:    "ghcr.io/fluxcd/kustomize-controller:v0.32.0"
			helm:         "ghcr.io/fluxcd/helm-controller:v0.28.0"
			notification: "ghcr.io/fluxcd/notification-controller:v0.30.1"
		}
	}
}

auto: distribution.#FluxAutoSync & {
	spec: {
		name:   "flux"
		image:  "ghcr.io/stefanprodan/manifests/flux-aio"
		semver: "*"
	}
}
