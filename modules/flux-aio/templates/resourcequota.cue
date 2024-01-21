package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ResourceQuota: corev1.#ResourceQuota & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "ResourceQuota"
	metadata:   #config.metadata
	spec: {
		hard: pods: "1000"
		scopeSelector: matchExpressions: [{
			operator:  "In"
			scopeName: "PriorityClass"
			values: ["system-node-critical", "system-cluster-critical"]
		}]
	}
}
