package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#SourceController: corev1.#Container & {
	_config: #Config

	name:            "source-controller"
	image:           _config.controllers.source
	imagePullPolicy: "IfNotPresent"
	securityContext: _config.securityContext
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
	env: [{
		name: "RUNTIME_NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}, {
		name:  "TUF_ROOT"
		value: "/tmp/.sigstore"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9791",
		"--health-addr=:9792",
		"--storage-addr=:9790",
		"--storage-path=/data",
		"--storage-adv-addr=\(_config.metadata.name).$(RUNTIME_NAMESPACE).svc.cluster.local.",
		"--concurrent=\(_config.reconcile.concurrent)",
		"--requeue-dependency=\(_config.reconcile.requeue)s",
		"--watch-label-selector=!sharding.fluxcd.io/key",
		"--events-addr=http://localhost:9690",
		"--helm-cache-max-size=10",
		"--helm-cache-ttl=60m",
		"--helm-cache-purge-interval=5m",
	]
	livenessProbe: httpGet: {
		port: "healthz-sc"
		path: "/healthz"
	}
	readinessProbe: httpGet: {
		port: "http-sc"
		path: "/"
	}
	resources: _config.resources
	volumeMounts: [{
		name:      "data"
		mountPath: "/data"
	}, {
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
