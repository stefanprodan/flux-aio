package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#NotificationController: corev1.#Container & {
	_config: #Config

	name:            "notification-controller"
	image:           _config.controllers.notification
	imagePullPolicy: "IfNotPresent"
	securityContext: _config.securityContext
	ports: [{
		containerPort: 9690
		name:          "http-nc"
		protocol:      "TCP"
	}, {
		containerPort: 9797
		name:          "http-webhook-nc"
		protocol:      "TCP"
	}, {
		containerPort: 9798
		name:          "http-prom-nc"
		protocol:      "TCP"
	}, {
		containerPort: 9799
		name:          "healthz-nc"
		protocol:      "TCP"
	}]
	env: [{
		name: "RUNTIME_NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz-nc"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz-nc"
	}
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election",
		"--metrics-addr=:9798",
		"--health-addr=:9799",
		"--events-addr=:9690",
		if _config.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
	]
	resources: _config.resources
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
