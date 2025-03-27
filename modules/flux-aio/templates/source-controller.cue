package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#SourceController: corev1.#Container & {
	#config: #Config
	_env:    #ContainerEnv

	name:            "source-controller"
	image:           #config.controllers.source.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: #config.securityContext
	env:             _env.env

	ports: [{
		containerPort: 9790
		name:          "http-sc"
		protocol:      "TCP"
	}, {
		containerPort: 9791
		name:          "http-prom-sc"
		protocol:      "TCP"
	}, {
		containerPort: 9792
		name:          "healthz-sc"
		protocol:      "TCP"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(#config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9791",
		"--health-addr=:9792",
		"--storage-addr=:9790",
		"--storage-path=/data",
		"--storage-adv-addr=\(#config.metadata.name).$(RUNTIME_NAMESPACE).svc.cluster.local.",
		"--concurrent=\(#config.reconcile.concurrent)",
		"--requeue-dependency=\(#config.reconcile.requeue)s",
		"--watch-label-selector=!sharding.fluxcd.io/key",
		"--helm-cache-max-size=10",
		"--helm-cache-ttl=60m",
		"--helm-cache-purge-interval=5m",
		if #config.controllers.notification.enabled {
			"--events-addr=http://localhost:9690"
		},
	]
	livenessProbe: httpGet: {
		port: "healthz-sc"
		path: "/healthz"
	}
	readinessProbe: httpGet: {
		port: "http-sc"
		path: "/"
	}
	if #config.controllers.source.resources == _|_ {
		resources: #config.resources
	}
	if #config.controllers.source.resources != _|_ {
		resources: #config.controllers.source.resources
	}
	volumeMounts: [{
		name:      "data"
		mountPath: "/data"
	}, {
		name:      "tmp"
		mountPath: "/tmp"
	}] + #config.controllers.source.extraVolumeMounts
}
