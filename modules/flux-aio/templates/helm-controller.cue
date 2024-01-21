package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#HelmController: corev1.#Container & {
	#config: #Config
	_env:    #ContainerEnv

	name:            "helm-controller"
	image:           #config.controllers.helm.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: #config.securityContext
	env:             _env.env
	ports: [{
		containerPort: 9795
		name:          "http-prom-hc"
		protocol:      "TCP"
	}, {
		containerPort: 9796
		name:          "healthz-hc"
		protocol:      "TCP"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(#config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9795",
		"--health-addr=:9796",
		"--watch-label-selector=!sharding.fluxcd.io/key",
		"--concurrent=\(#config.reconcile.concurrent)",
		"--requeue-dependency=\(#config.reconcile.requeue)s",
		if #config.controllers.notification.enabled {
			"--events-addr=http://localhost:9690"
		},
		if #config.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
		if #config.securityProfile == "restricted" {
			"--default-service-account=\(#config.metadata.name)"
		},
	]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz-hc"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz-hc"
	}
	if #config.controllers.helm.resources == _|_ {
		resources: #config.resources
	}
	if #config.controllers.helm.resources != _|_ {
		resources: #config.controllers.helm.resources
	}
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
