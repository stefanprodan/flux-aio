package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ResourceQuota: corev1.#ResourceQuota & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "ResourceQuota"
	metadata:   _config.metadata
	spec: {
		hard: pods: "1000"
		scopeSelector: matchExpressions: [{
			operator:  "In"
			scopeName: "PriorityClass"
			values: ["system-node-critical", "system-cluster-critical"]
		}]
	}
}
