@if(!debug)

package main

values: {
	version: "v2.8.6"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.8.3"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.8.4"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.8.4"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v1.5.4"
			digest:     ""
		}
		watcher: image: {
			repository: "ghcr.io/fluxcd/source-watcher"
			tag:        "v2.1.1"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
