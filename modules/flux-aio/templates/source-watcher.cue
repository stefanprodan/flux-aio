package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#SourceWatcher: corev1.#Container & {
	#config: #Config
	_env:    #ContainerEnv

	name:            "source-watcher"
	image:           #config.controllers.watcher.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: #config.securityContext
	env:             _env.env

	ports: [{
		containerPort: 9691
		name:          "http-sw"
		protocol:      "TCP"
	}, {
		containerPort: 9692
		name:          "http-prom-sw"
		protocol:      "TCP"
	}, {
		containerPort: 9693
		name:          "healthz-sw"
		protocol:      "TCP"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(#config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9692",
		"--health-addr=:9693",
		"--storage-addr=:9691",
		"--storage-path=/data",
		"--storage-adv-addr=source-watcher.$(RUNTIME_NAMESPACE).svc.cluster.local.",
		if #config.controllers.notification.enabled {
			"--events-addr=http://localhost:9690"
		},
		if #config.controllers.watcher.featureGates != "" {
			"--feature-gates=\(#config.controllers.watcher.featureGates)"
		},
	]
	livenessProbe: httpGet: {
		port: "healthz-sw"
		path: "/healthz"
	}
	readinessProbe: httpGet: {
		port: "http-sw"
		path: "/"
	}
	if #config.controllers.watcher.resources == _|_ {
		resources: #config.resources
	}
	if #config.controllers.watcher.resources != _|_ {
		resources: #config.controllers.watcher.resources
	}
	volumeMounts: [{
		name:      "data"
		mountPath: "/data"
	}, {
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
