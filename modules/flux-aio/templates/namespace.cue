package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:        _spec.metadata.namespace
		labels:      _spec.metadata.labels
		annotations: _spec.metadata.annotations
	}
}
