package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#KustomizeController: corev1.#Container & {
	_config: #Config
	_env:    #ContainerEnv

	name:            "kustomize-controller"
	image:           _config.controllers.kustomize.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: _config.securityContext
	env:             _env.env
	ports: [{
		containerPort: 9793
		name:          "http-prom-kc"
		protocol:      "TCP"
	}, {
		containerPort: 9794
		name:          "healthz-kc"
		protocol:      "TCP"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9793",
		"--health-addr=:9794",
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
			"--no-remote-bases"
		},
		if _config.securityProfile == "restricted" {
			"--default-service-account=\(_config.metadata.name)"
		},
	]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz-kc"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz-kc"
	}
	if _config.controllers.kustomize.resources == _|_ {
		resources: _config.resources
	}
	if _config.controllers.kustomize.resources != _|_ {
		resources: _config.controllers.kustomize.resources
	}
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
