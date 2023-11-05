package templates

import (
	"strings"

	fluxv1 "source.toolkit.fluxcd.io/helmrepository/v1beta2"
)

#HelmRepository: fluxv1.#HelmRepository & {
	_config:  #Config
	metadata: _config.metadata
	spec:     fluxv1.#HelmRepositorySpec & {
		interval: "12h"
		url:      _config.repository.url
		if strings.HasPrefix(_config.repository.url, "oci") {
			type: "oci"
		}
		if _config.repository.auth != _|_ {
			secretRef: name: "\(_config.metadata.name)-auth"
		}
	}
}

#HelmRepositoryAuth: {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:      "\(_config.metadata.name)-auth"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels
		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	stringData: {
		if _config.repository.auth != _|_ {
			username: _config.repository.auth.username
			password: _config.repository.auth.password
		}
	}
}
