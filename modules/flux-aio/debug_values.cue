@if(debug)

package main

// Values used by debug_tool.cue.
// Eval example:
// cue -t debug -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 eval -c -e timoni.instance.objects.deployment
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
	hostNetwork:     true
	securityProfile: "privileged"
	resources: {
		requests: {
			cpu:    "250m"
			memory: "512Mi"
		}
		limits: {
			cpu:    "250m"
			memory: "512Mi"
		}
	}
	expose: {
		webhookReceiver:    true
		notificationServer: true
		sourceServer:       true
	}
	persistence: enabled: true
}
