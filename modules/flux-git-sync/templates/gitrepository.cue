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
		if #config.git.token != "" || #config.github.appID != "" {
			secretRef: name: #config.metadata.name
		}
		if #config.github.appID != "" {
			provider: "github"
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
		if #config.git.token != "" {
			password: #config.git.token
		}
		if #config.git.ca != "" {
			"ca.crt": #config.git.ca
		}
		if #config.github.appID != "" {
			githubAppID:             #config.github.appID
			githubAppInstallationID: #config.github.appInstallationID
			githubAppPrivateKey:     #config.github.appPrivateKey
		}
	}
}
