package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   _config.metadata
	if _config.workload.provider == "aws" {
		metadata: annotations: "eks.amazonaws.com/role-arn": _config.workload.indentity
	}
	if _config.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use":            "true"
		metadata: annotations: "azure.workload.identity/client-id": _config.workload.indentity
	}
	if _config.workload.provider == "gcp" {
		metadata: annotations: "iam.gke.io/gcp-service-account": _config.workload.indentity
	}
}
