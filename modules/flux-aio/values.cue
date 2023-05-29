package main

values: {
	version: "v2.0.0-rc.3"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.0.0-rc.3"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:v1.0.0-rc.3"
		notification: "ghcr.io/fluxcd/notification-controller:v1.0.0-rc.3"
		helm:         "ghcr.io/fluxcd/helm-controller:v0.33.0"
	}
	securityProfile: "privileged"
}
