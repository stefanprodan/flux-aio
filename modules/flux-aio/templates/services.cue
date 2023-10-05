package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#WebhookService: corev1.#Service & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "webhook-receiver"
		namespace:   _config.metadata.namespace
		labels:      _config.metadata.labels
		annotations: _config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _config.metadata.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-webhook-nc"
			protocol:   "TCP"
		}]
	}
}

#NotificationService: corev1.#Service & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "notification-controller"
		namespace:   _config.metadata.namespace
		labels:      _config.metadata.labels
		annotations: _config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _config.metadata.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-nc"
			protocol:   "TCP"
		}]
	}
}

#SourceService: corev1.#Service & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "source-controller"
		namespace:   _config.metadata.namespace
		labels:      _config.metadata.labels
		annotations: _config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type: "ClusterIP"
		selector: "app.kubernetes.io/name": _config.metadata.name
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-sc"
			protocol:   "TCP"
		}]
	}
}
