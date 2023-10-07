@if(debug)

package main

// Values used by debug_tool.cue.
// Eval example:
// cue -t debug -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 eval -c -e timoni.instance.objects.deployment
values: {
	version: "v2.1.1"
	controllers: {
		source:       "ghcr.io/fluxcd/source-controller:v1.1.1"
		kustomize:    "ghcr.io/fluxcd/kustomize-controller:preview-ef135a14"
		notification: "ghcr.io/fluxcd/notification-controller:v1.1.0"
		helm:         "ghcr.io/fluxcd/helm-controller:preview-bd3ec356"
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
