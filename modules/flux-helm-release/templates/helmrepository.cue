package templates

import (
	sourcev1 "source.toolkit.fluxcd.io/helmrepository/v1"
)

#HelmRepository: sourcev1.#HelmRepository & {
	#config:  #Config
	metadata: #config.metadata
	spec: sourcev1.#HelmRepositorySpec & {
		interval: "12h"
		url:      #config.repository.url
		if #config.repository.auth != _|_ {
			secretRef: name: "\(#config.metadata.name)-helm-auth"
		}
		if #config.repository.insecure {
			insecure: true
		}
		if #config.repository.certSecretName != _|_ {
			certSecretRef: name: #config.repository.certSecretName
		}
		provider: #config.repository.provider
	}
}

#HelmRepositoryAuth: {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:      "\(#config.metadata.name)-helm-auth"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	stringData: {
		if #config.repository.auth != _|_ {
			username: #config.repository.auth.username
			password: #config.repository.auth.password
		}
	}
}
