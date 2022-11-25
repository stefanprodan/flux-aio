package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_spec:      #FluxSpec
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:        "\(_spec.name)-system"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
