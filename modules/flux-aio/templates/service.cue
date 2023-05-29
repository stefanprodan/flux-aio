package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#WebhookReceiver: corev1.#Service & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "webhook-receiver"
		namespace:   _spec.metadata.namespace
		labels:      _spec.metadata.labels
		annotations: _spec.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _spec.metadata.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-webhook-nc"
			protocol:   "TCP"
		}]
	}
}

#SourceServer: corev1.#Service & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "source-controller"
		namespace:   _spec.metadata.namespace
		labels:      _spec.metadata.labels
		annotations: _spec.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _spec.metadata.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-sc"
			protocol:   "TCP"
		}]
	}
}
