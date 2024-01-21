package templates

import (
	fluxv2 "helm.toolkit.fluxcd.io/helmrelease/v2beta2"
)

#HelmRelease: fluxv2.#HelmRelease & {
	#config:  #Config
	metadata: #config.metadata
	spec: fluxv2.#HelmReleaseSpec & {
		releaseName: "\(#config.metadata.name)"
		interval:    "\(#config.sync.interval)m"

		if #config.sync.targetNamespace != _|_ {
			targetNamespace:  "\(#config.sync.targetNamespace)"
			storageNamespace: "\(#config.sync.targetNamespace)"
		}

		if #config.sync.serviceAccountName != _|_ {
			serviceAccountName: #config.sync.serviceAccountName
		}

		chart: {
			spec: {
				chart:   "\(#config.chart.name)"
				version: "\(#config.chart.version)"
				sourceRef: {
					kind: "HelmRepository"
					name: "\(#config.metadata.name)"
				}
				interval: "\(#config.sync.interval)m"
			}
		}

		install: {
			crds: "Create"
			remediation: retries: #config.sync.retries
		}

		upgrade: {
			crds: "CreateReplace"
			remediation: retries: #config.sync.retries
		}

		if #config.helmValues != _|_ {
			values: #config.helmValues
		}
	}
}
