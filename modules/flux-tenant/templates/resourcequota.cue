package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ResourceQuota: corev1.#ResourceQuota & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "ResourceQuota"
	metadata: {
		name:      "\(#config.fluxServiceAccount)-quota"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	spec: corev1.#ResourceQuotaSpec & {
		hard: {
			"count/kustomizations.kustomize.toolkit.fluxcd.io": "\(#config.resourceQuota.kustomizations)"
			"count/helmreleases.helm.toolkit.fluxcd.io":        "\(#config.resourceQuota.helmreleases)"
		}
	}
}
