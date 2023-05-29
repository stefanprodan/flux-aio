package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   _spec.metadata
	if _spec.workload.provider == "aws" {
		metadata: annotations: "eks.amazonaws.com/role-arn": _spec.workload.indentity
	}
	if _spec.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use":            "true"
		metadata: annotations: "azure.workload.identity/client-id": _spec.workload.indentity
	}
	if _spec.workload.provider == "gcp" {
		metadata: annotations: "iam.gke.io/gcp-service-account": _spec.workload.indentity
	}
}
