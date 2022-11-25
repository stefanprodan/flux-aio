package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#KustomizeController: corev1.#Container & {
	_spec: #FluxSpec

	name:            "kustomize-controller"
	image:           _spec.controllers.kustomize
	imagePullPolicy: "IfNotPresent"
	securityContext: _spec.securityContext
	ports: [{
		containerPort: 8081
		name:          "http-prom"
		protocol:      "TCP"
	}, {
		containerPort: 9441
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
		"--metrics-addr=:8081",
		"--health-addr=:9441",
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
