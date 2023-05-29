package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#KustomizeController: corev1.#Container & {
	_spec: #Config

	name:            "kustomize-controller"
	image:           _spec.controllers.kustomize
	imagePullPolicy: "IfNotPresent"
	securityContext: _spec.securityContext
	ports: [{
		containerPort: 9793
		name:          "http-prom-kc"
		protocol:      "TCP"
	}, {
		containerPort: 9794
		name:          "healthz-kc"
		protocol:      "TCP"
	}]
	env: [{
		name:  "SOURCE_CONTROLLER_LOCALHOST"
		value: "localhost:9790"
	}, {
		name: "RUNTIME_NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}]
	args: [
		"--watch-all-namespaces",
		"--log-level=\(_spec.logLevel)",
		"--log-encoding=json",
		"--enable-leader-election=true",
		"--metrics-addr=:9793",
		"--health-addr=:9794",
		"--events-addr=http://localhost:9690",
		if _spec.securityProfile == "restricted" {
			"--no-cross-namespace-refs"
		},
		if _spec.securityProfile == "restricted" {
			"--no-remote-bases"
		},
		if _spec.securityProfile == "restricted" {
			"--default-service-account=\(_spec.metadata.name)"
		},
	]
	readinessProbe: httpGet: {
		path: "/readyz"
		port: "healthz-kc"
	}
	livenessProbe: httpGet: {
		path: "/healthz"
		port: "healthz-kc"
	}
	resources: _spec.resources
	volumeMounts: [{
		name:      "tmp"
		mountPath: "/tmp"
	}]
}
