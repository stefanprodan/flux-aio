package main

values: {
	version: "v2.0.0-rc.5"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.0.0-rc.5"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.0.0-rc.4"
		notification: "ghcr.io/fluxcd/notification-controller:v1.0.0-rc.4"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.34.1"
	}
	securityProfile: "privileged"
}
