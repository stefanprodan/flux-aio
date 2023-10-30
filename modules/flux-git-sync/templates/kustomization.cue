package templates

import (
	ksv1 "kustomize.toolkit.fluxcd.io/kustomization/v1"
	sourcev1 "source.toolkit.fluxcd.io/gitrepository/v1"
)

#Kustomization: ksv1.#Kustomization & {
	_config:  #Config
	metadata: _config.metadata
	spec:     ksv1.#KustomizationSpec & {
		sourceRef: {
			kind: sourcev1.#GitRepository.kind
			name: _config.metadata.name
		}
		interval:      "60m"
		retryInterval: "2m"
		path:          _config.git.path
		prune:         _config.sync.prune
		wait:          _config.sync.wait
		timeout:       "\(_config.sync.timeout)m"
		if _config.sync.serviceAccountName != _|_ {
			serviceAccountName: _config.sync.serviceAccountName
		}
		if _config.sync.targetNamespace != _|_ {
			targetNamespace: _config.sync.targetNamespace
		}
	}
}
