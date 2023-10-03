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
		path:          _config.git.path
		interval:      "10m"
		wait:          true
		timeout:       "3m"
		retryInterval: "2m"
		prune:         true
		force:         false
	}
}
