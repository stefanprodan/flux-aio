package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#WebhookReceiver: corev1.#Service & {
	_spec:      #FluxSpec
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "webhook-receiver"
		namespace:   "\(_spec.name)-system"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _spec.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-webhook-nc"
			protocol:   "TCP"
		}]
	}
}

#SourceServer: corev1.#Service & {
	_spec:      #FluxSpec
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "source-controller"
		namespace:   "\(_spec.name)-system"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _spec.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-sc"
			protocol:   "TCP"
		}]
	}
}
