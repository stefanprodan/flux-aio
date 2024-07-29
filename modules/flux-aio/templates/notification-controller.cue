package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#NotificationController: corev1.#Container & {
	#config: #Config
	_env:    #ContainerEnv

	name:            "notification-controller"
	image:           #config.controllers.notification.image.reference
	imagePullPolicy: "IfNotPresent"
	securityContext: #config.securityContext
	env:             _env.env
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
		"--log-level=\(#config.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=false",
		"--metrics-addr=:9798",
		"--health-addr=:9799",
		"--events-addr=:9690",
		if #config.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
	]
	if #config.controllers.notification.resources == _|_ {
		resources: #config.resources
	}
	if #config.controllers.notification.resources != _|_ {
		resources: #config.controllers.notification.resources
	}
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}] + #config.controllers.notification.extraVolumeMounts
}
