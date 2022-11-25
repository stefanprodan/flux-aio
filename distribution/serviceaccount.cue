package distribution

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_spec:      #FluxSpec
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:        _spec.name
		namespace:   "\(_spec.name)-system"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
