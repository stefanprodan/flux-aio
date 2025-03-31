package templates

import (
	"encoding/json"

	ksv1 "kustomize.toolkit.fluxcd.io/kustomization/v1"
	sourcev1 "source.toolkit.fluxcd.io/gitrepository/v1"
)

#Kustomization: ksv1.#Kustomization & {
	#config:  #Config
	metadata: #config.metadata
	spec: ksv1.#KustomizationSpec & {
		sourceRef: {
			kind: sourcev1.#GitRepository.kind
			name: #config.metadata.name
		}
		interval:      "60m"
		retryInterval: "\(#config.sync.retryInterval)m"
		path:          #config.git.path
		prune:         #config.sync.prune
		wait:          #config.sync.wait
		timeout:       "\(#config.sync.timeout)m"
		if #config.sync.serviceAccountName != _|_ {
			serviceAccountName: #config.sync.serviceAccountName
		}
		if #config.sync.targetNamespace != _|_ {
			targetNamespace: #config.sync.targetNamespace
		}

		if #config.substitute != _|_ {
			postBuild: substitute: #config.substitute
		}

		if #config.substituteFrom != _|_ {
			postBuild: substituteFrom: #config.substituteFrom
		}

		if #config.dependsOn != _|_ {
			dependsOn: #config.dependsOn
		}

		if #config.patches != _|_ {
			patches: [for p in #config.patches {patch: json.Marshal(p.patch), target: p.target}]
		}
	}
}
