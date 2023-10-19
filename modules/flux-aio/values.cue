@if(!debug)

package main

values: {
	version: "v2.1.2"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.1.2"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.1.1"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.1.0"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v0.36.2"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
