package main

import (
	distribution "github.com/stefanprodan/flux-aio/distribution"
)

aio: distribution.#Flux & {
	spec: {
		name:    "flux"
		version: "v2.0.0-rc.1"
		controllers: {
			source:       "ghcr.io/fluxcd/source-controller:v1.0.0-rc.1"
			kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.0.0-rc.1"
			helm:         "ghcr.io/fluxcd/helm-controller:v0.32.1"
			notification: "ghcr.io/fluxcd/notification-controller:v1.0.0-rc.1"
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
