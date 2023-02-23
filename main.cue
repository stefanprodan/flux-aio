package main

import (
	distribution "github.com/stefanprodan/flux-aio/distribution"
)

aio: distribution.#Flux & {
	spec: {
		name:    "flux"
		version: "v0.40.0"
		controllers: {
			source:       "ghcr.io/fluxcd/source-controller:v0.35.1"
			kustomize:    "ghcr.io/fluxcd/kustomize-controller:v0.34.0"
			helm:         "ghcr.io/fluxcd/helm-controller:v0.30.0"
			notification: "ghcr.io/fluxcd/notification-controller:v0.32.0"
		}
		// Enable the multi-tenancy lockdown by setting the securityProfile to 'restricted'
		securityProfile: "privileged"
	}
}

auto: distribution.#FluxAutoSync & {
	spec: {
		name:   "flux"
		image:  "ghcr.io/stefanprodan/manifests/flux-aio"
		semver: "*"
	}
}
