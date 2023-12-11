package templates

import (
	fluxv2 "helm.toolkit.fluxcd.io/helmrelease/v2beta1"
)

#HelmRelease: fluxv2.#HelmRelease & {
	_config:  #Config
	metadata: _config.metadata
	spec: fluxv2.#HelmReleaseSpec & {
		releaseName: "\(_config.metadata.name)"
		interval:    "\(_config.sync.interval)m"

		if _config.sync.targetNamespace != _|_ {
			targetNamespace:  "\(_config.sync.targetNamespace)"
			storageNamespace: "\(_config.sync.targetNamespace)"
		}

		if _config.sync.serviceAccountName != _|_ {
			serviceAccountName: _config.sync.serviceAccountName
		}

		chart: {
			spec: {
				chart:   "\(_config.chart.name)"
				version: "\(_config.chart.version)"
				sourceRef: {
					kind: "HelmRepository"
					name: "\(_config.metadata.name)"
				}
				interval: "\(_config.sync.interval)m"
			}
		}

		install: {
			crds: "Create"
			remediation: retries: _config.sync.retries
		}

		upgrade: {
			crds: "CreateReplace"
			remediation: retries: _config.sync.retries
		}

		if _config.helmValues != _|_ {
			values: _config.helmValues
		}
	}
}
