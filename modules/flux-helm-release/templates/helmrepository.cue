package templates

import (
	"strings"

	fluxv1 "source.toolkit.fluxcd.io/helmrepository/v1beta2"
)

#HelmRepository: fluxv1.#HelmRepository & {
	#config:  #Config
	metadata: #config.metadata
	spec: fluxv1.#HelmRepositorySpec & {
		interval: "12h"
		url:      #config.repository.url
		if strings.HasPrefix(#config.repository.url, "oci") {
			type: "oci"
		}
		if #config.repository.auth != _|_ {
			secretRef: name: "\(#config.metadata.name)-auth"
		}
		if #config.repository.insecure {
			insecure: true
		}
		provider: #config.repository.provider
	}
}

#HelmRepositoryAuth: {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:      "\(#config.metadata.name)-auth"
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
