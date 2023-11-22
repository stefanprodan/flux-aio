package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#HelmController: corev1.#Container & {
	_config: #Config
	_env:    #ContainerEnv

	name:            "helm-controller"
	image:           _config.controllers.helm.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: _config.securityContext
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
		"--log-level=\(_config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9795",
		"--health-addr=:9796",
		"--watch-label-selector=!sharding.fluxcd.io/key",
		"--concurrent=\(_config.reconcile.concurrent)",
		"--requeue-dependency=\(_config.reconcile.requeue)s",
		if _config.controllers.notification.enabled {
			"--events-addr=http://localhost:9690"
		},
		if _config.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
		if _config.securityProfile == "restricted" {
			"--default-service-account=\(_config.metadata.name)"
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
	if _config.controllers.helm.resources == _|_ {
		resources: _config.resources
	}
	if _config.controllers.helm.resources != _|_ {
		resources: _config.controllers.helm.resources
	}
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
