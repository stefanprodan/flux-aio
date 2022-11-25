package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#HelmController: corev1.#Container & {
	_spec: #FluxSpec

	name:            "helm-controller"
	image:           _spec.controllers.helm
	imagePullPolicy: "IfNotPresent"
	securityContext: _spec.securityContext
	ports: [{
		containerPort: 8082
		name:          "http-prom"
		protocol:      "TCP"
	}, {
		containerPort: 9442
		name:          "healthz"
		protocol:      "TCP"
	}]
	env: [{
		name:  "SOURCE_CONTROLLER_LOCALHOST"
		value: "localhost:9090"
	}, {
		name: "RUNTIME_NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_spec.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=true",
		"--metrics-addr=:8082",
		"--health-addr=:9442",
		"--events-addr=http://localhost:9080",
	]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz"
	}
	resources: _spec.resources
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
