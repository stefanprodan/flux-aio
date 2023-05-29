package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ResourceQuota: corev1.#ResourceQuota & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "ResourceQuota"
	metadata:   _spec.metadata
	spec: {
		hard: pods: "1000"
		scopeSelector: matchExpressions: [{
			operator:  "In"
			scopeName: "PriorityClass"
			values: ["system-node-critical", "system-cluster-critical"]
		}]
	}
}
