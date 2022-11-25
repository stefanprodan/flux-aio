package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#NotificationController: corev1.#Container & {
	_spec: #FluxSpec

	name:            "notification-controller"
	image:           _spec.controllers.notification
	imagePullPolicy: "IfNotPresent"
	securityContext: _spec.securityContext
	ports: [{
		containerPort: 9080
		name:          "http"
		protocol:      "TCP"
	}, {
		containerPort: 9292
		name:          "http-webhook"
		protocol:      "TCP"
	}, {
		containerPort: 8083
		name:          "http-prom"
		protocol:      "TCP"
	}, {
		containerPort: 9443
		name:          "healthz"
		protocol:      "TCP"
	}]
	env: [{
		name: "RUNTIME_NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz"
	}
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_spec.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election",
		"--metrics-addr=:8083",
		"--health-addr=:9443",
		"--events-addr=:9080",
	]
	resources: _spec.resources
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
