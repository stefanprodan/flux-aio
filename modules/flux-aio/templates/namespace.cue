package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:        _config.metadata.namespace
		labels:      _config.metadata.labels
		annotations: _config.metadata.annotations
	}
}
