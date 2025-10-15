@if(!debug)

package main

values: {
	version: "v2.6.4"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.6.2"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.6.1"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.6.0"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v1.4.2"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
