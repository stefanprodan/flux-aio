package main

values: {
	version: "v2.1.0"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.1.0"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.1.0"
		notification: "ghcr.io/fluxcd/notification-controller:v1.1.0"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.36.0"
	}
	securityProfile: "privileged"
}
