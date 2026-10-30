@if(!debug)

package main

values: {
	version: "v2.10.0"
	controllers: {
		source: image: {
			repository: "ghcr.io/fluxcd/source-controller"
			tag:        "v1.10.1"
			digest:     ""
		}
		kustomize: image: {
			repository: "ghcr.io/fluxcd/kustomize-controller"
			tag:        "v1.10.1"
			digest:     ""
		}
		notification: image: {
			repository: "ghcr.io/fluxcd/notification-controller"
			tag:        "v1.10.0"
			digest:     ""
		}
		helm: image: {
			repository: "ghcr.io/fluxcd/helm-controller"
			tag:        "v1.7.1"
			digest:     ""
		}
		watcher: image: {
			repository: "ghcr.io/fluxcd/source-watcher"
			tag:        "v2.3.1"
			digest:     ""
		}
	}
	securityProfile: "privileged"
}
