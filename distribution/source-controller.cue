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
		"--log-level=\(_spec.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=true",
		"--metrics-addr=:9791",
		"--health-addr=:9792",
		"--storage-addr=:9790",
		"--storage-path=/data",
		"--storage-adv-addr=\(_spec.name).$(RUNTIME_NAMESPACE).svc.cluster.local.",
		"--events-addr=http://localhost:9690",
	]
	livenessProbe: httpGet: {
		port: "healthz-sc"
		path: "/healthz"
	}
	readinessProbe: httpGet: {
		port: "http-sc"
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
