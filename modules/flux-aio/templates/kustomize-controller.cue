package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#KustomizeController: corev1.#Container & {
	#config: #Config
	_env:    #ContainerEnv

	name:            "kustomize-controller"
	image:           #config.controllers.kustomize.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: #config.securityContext
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
		"--log-level=\(#config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9793",
		"--health-addr=:9794",
		"--watch-label-selector=!sharding.fluxcd.io/key",
		"--override-manager=timoni",
		"--concurrent=\(#config.reconcile.concurrent)",
		"--requeue-dependency=\(#config.reconcile.requeue)s",
		if #config.controllers.notification.enabled {
			"--events-addr=http://localhost:9690"
		},
		if #config.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
		if #config.securityProfile == "restricted" {
			"--no-remote-bases"
		},
		if #config.securityProfile == "restricted" {
			"--default-service-account=\(#config.metadata.name)"
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
	if #config.controllers.kustomize.resources == _|_ {
		resources: #config.resources
	}
	if #config.controllers.kustomize.resources != _|_ {
		resources: #config.controllers.kustomize.resources
	}
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}] + #config.controllers.kustomize.extraVolumeMounts
}
