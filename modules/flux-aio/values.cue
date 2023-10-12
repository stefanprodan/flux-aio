@if(!debug)

package main

values: {
	version: "v2.1.2"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.1.2"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.1.1"
		notification: "ghcr.io/fluxcd/notification-controller:v1.1.0"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.36.2"
	}
	securityProfile: "privileged"
}
