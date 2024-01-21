package templates

import (
	corev1 "k8s.io/api/core/v1"
	sourcev1 "source.toolkit.fluxcd.io/gitrepository/v1"
)

#GitRepository: sourcev1.#GitRepository & {
	#config:  #Config
	metadata: #config.metadata
	spec: sourcev1.#GitRepositorySpec & {
		interval: "\(#config.git.interval)m"
		url:      #config.git.url
		ref: name: #config.git.ref
		if #config.git.token != "" {
			secretRef: name: #config.metadata.name
		}
		if #config.git.ignore != "" {
			ignore: #config.git.ignore
		}
	}
}

#GitSecret: corev1.#Secret & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   #config.metadata
	stringData: {
		username: "git"
		password: #config.git.token
		if #config.git.ca != "" {
			"ca.crt": #config.git.ca
		}
	}
}
