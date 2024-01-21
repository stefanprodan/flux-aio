package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#WebhookService: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "webhook-receiver"
		namespace:   #config.metadata.namespace
		labels:      #config.metadata.labels
		annotations: #config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     "ClusterIP"
		selector: #config.selector.labels
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-webhook-nc"
			protocol:   "TCP"
		}]
	}
}

#NotificationService: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "notification-controller"
		namespace:   #config.metadata.namespace
		labels:      #config.metadata.labels
		annotations: #config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     "ClusterIP"
		selector: #config.selector.labels
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-nc"
			protocol:   "TCP"
		}]
	}
}

#SourceService: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:        "source-controller"
		namespace:   #config.metadata.namespace
		labels:      #config.metadata.labels
		annotations: #config.metadata.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     "ClusterIP"
		selector: #config.selector.labels
		ports: [{
			name:       "http"
			port:       80
			targetPort: "http-sc"
			protocol:   "TCP"
		}]
	}
}
