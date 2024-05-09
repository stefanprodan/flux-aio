@if(!debug)

package main

values: {
	version: "v2.3.0"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.3.0"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.3.0"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.3.0"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v1.0.0"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
