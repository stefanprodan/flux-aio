package templates

import (
	corev1 "k8s.io/api/core/v1"
	sourcev1 "source.toolkit.fluxcd.io/gitrepository/v1"
)

#GitRepository: sourcev1.#GitRepository & {
	_config:  #Config
	metadata: _config.metadata
	spec: sourcev1.#GitRepositorySpec & {
		interval: "\(_config.git.interval)m"
		url:      _config.git.url
		ref: name: _config.git.ref
		if _config.git.token != "" {
			secretRef: name: _config.metadata.name
		}
		if _config.git.ignore != "" {
			ignore: _config.git.ignore
		}
	}
}

#GitSecret: corev1.#Secret & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   _config.metadata
	stringData: {
		username: "git"
		password: _config.git.token
		if _config.git.ca != "" {
			"ca.crt": _config.git.ca
		}
	}
}
