package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ResourceQuota: corev1.#ResourceQuota & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "ResourceQuota"
	metadata: {
		name:      "\(_config.fluxServiceAccount)-quota"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels
		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	spec: corev1.#ResourceQuotaSpec & {
		hard: {
			"count/kustomizations.kustomize.toolkit.fluxcd.io": "\(_config.resourceQuota.kustomizations)"
			"count/helmreleases.helm.toolkit.fluxcd.io":        "\(_config.resourceQuota.helmreleases)"
		}
	}
}
