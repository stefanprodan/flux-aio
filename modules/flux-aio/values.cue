package main

values: {
	version: "v2.1.1"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.1.1"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.1.0"
		notification: "ghcr.io/fluxcd/notification-controller:v1.1.0"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.36.1"
	}
	securityProfile: "privileged"
}
