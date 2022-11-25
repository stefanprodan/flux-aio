package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#SourceController: corev1.#Container & {
	_spec: #FluxSpec

	name:            "source-controller"
	image:           _spec.controllers.source
	imagePullPolicy: "IfNotPresent"
	securityContext: _spec.securityContext
	ports: [{
		containerPort: 9090
		name:          "http"
		protocol:      "TCP"
	}, {
		containerPort: 8080
		name:          "http-prom"
		protocol:      "TCP"
	}, {
		containerPort: 9440
		name:          "healthz"
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
		"--log-level=\(_spec.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=true",
		"--storage-path=/data",
		"--storage-adv-addr=\(_spec.name).$(RUNTIME_NAMESPACE).svc.cluster.local.",
		"--events-addr=http://localhost:9080",
	]
	livenessProbe: httpGet: {
		port: "healthz"
		path: "/healthz"
	}
	readinessProbe: httpGet: {
		port: "http"
		path: "/"
	}
	resources: _spec.resources
	volumeMounts: [{
		name:      "data"
		mountPath: "/data"
	}, {
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
