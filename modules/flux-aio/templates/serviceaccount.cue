package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   #config.metadata
	if #config.workload.provider == "aws" {
		metadata: annotations: "eks.amazonaws.com/role-arn": #config.workload.identity
	}
	if #config.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use":            "true"
		metadata: annotations: "azure.workload.identity/client-id": #config.workload.identity
	}
	if #config.workload.provider == "gcp" {
		metadata: annotations: "iam.gke.io/gcp-service-account": #config.workload.identity
	}
}
