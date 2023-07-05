package main

values: {
	version: "v2.0.0"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.0.0"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.0.0"
		notification: "ghcr.io/fluxcd/notification-controller:v1.0.0"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.35.0"
	}
	securityProfile: "privileged"
}
