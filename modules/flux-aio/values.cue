@if(!debug)

package main

values: {
	version: "v2.9.0"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.9.1"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.9.1"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.9.1"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v1.6.1"
			digest:     ""
		}
		watcher: image: {
			repository: "ghcr.io/fluxcd/source-watcher"
			tag:        "v2.2.1"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
