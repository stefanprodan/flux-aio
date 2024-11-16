package templates

import (
	"strings"

	helmv2 "helm.toolkit.fluxcd.io/helmrelease/v2"
)

#HelmRelease: helmv2.#HelmRelease & {
	#config:  #Config
	metadata: #config.metadata
	spec: helmv2.#HelmReleaseSpec & {
		releaseName: "\(#config.metadata.name)"
		interval:    "\(#config.sync.interval)m"
		timeout:     "\(#config.sync.timeout)m"

		if #config.sync.targetNamespace != _|_ {
			targetNamespace:  "\(#config.sync.targetNamespace)"
			storageNamespace: "\(#config.sync.targetNamespace)"
		}

		if #config.sync.serviceAccountName != _|_ {
			serviceAccountName: #config.sync.serviceAccountName
		}

		if !strings.HasPrefix(#config.repository.url, "oci://") {
			chart: {
				metadata: {
					labels: #config.metadata.labels
					if #config.metadata.annotations != _|_ {
						annotations: #config.metadata.annotations
					}
				}
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
		}

		if strings.HasPrefix(#config.repository.url, "oci://") {
			chartRef: {
				kind: "OCIRepository"
				name: "\(#config.metadata.name)"
			}
		}

		install: {
			crds: "Create"
			remediation: retries: #config.sync.retries
			disableWait:        #config.sync.disableWait
			disableWaitForJobs: #config.sync.disableWait
		}

		upgrade: {
			crds: "CreateReplace"
			remediation: retries: #config.sync.retries
			disableWait:        #config.sync.disableWait
			disableWaitForJobs: #config.sync.disableWait
		}

		test: enable: #config.test

		if #config.helmValues != _|_ {
			values: #config.helmValues
		}

		if #config.dependsOn != _|_ {
			dependsOn: #config.dependsOn
		}

		if #config.driftDetection != _|_ {
			driftDetection: mode: #config.driftDetection
		}
	}
}
