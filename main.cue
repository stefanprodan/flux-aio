package main

import (
	distribution "github.com/stefanprodan/flux-aio/distribution"
)

aio: distribution.#Flux & {
	spec: {
		name:    "flux"
		version: "v0.37.0"
		controllers: {
			source:       "ghcr.io/fluxcd/source-controller:v0.32.1"
			kustomize:    "ghcr.io/fluxcd/kustomize-controller:v0.31.0"
			helm:         "ghcr.io/fluxcd/helm-controller:v0.27.0"
			notification: "ghcr.io/fluxcd/notification-controller:v0.29.0"
		}
	}
}

artifact: image: "ghcr.io/stefanprodan/manifests/flux-aio"
