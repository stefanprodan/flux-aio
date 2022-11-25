package distribution

import (
	apiextensions "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
	corev1 "k8s.io/api/core/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
)

customresourcedefinition: [string]: apiextensions.#CustomResourceDefinition

#FluxSpec: {
	name: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"

	version: string
	controllers: {
		source:       string
		kustomize:    string
		helm:         string
		notification: string
	}

	labels: *{
			"app.kubernetes.io/name":    name
			"app.kubernetes.io/version": version
			"app.kubernetes.io/part-of": "flux"
	} | {[ string]: string}

	annotations: *{
			"app.kubernetes.io/role": "cluster-admin"
	} | {[ string]: string}

	logLevel: *"info" | string

	resources: *{
		requests: {
			cpu:    "100m"
			memory: "64Mi"
		}
		limits: memory: "1Gi"
	} | corev1.#ResourceRequirements

	securityContext: *{
		allowPrivilegeEscalation: false
		readOnlyRootFilesystem:   true
		runAsNonRoot:             true
		capabilities: drop: ["ALL"]
		seccompProfile: type: "RuntimeDefault"
	} | corev1.#PodSecurityContext

	affinity?: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
		matchExpressions: [{
			key:      "kubernetes.io/os"
			operator: "In"
			values: ["linux"]
		}]
	}] | corev1.#Affinity

	tolerations?: [ ...corev1.#Toleration]
}

#Flux: {
	spec: #FluxSpec

	containers: [
		#SourceController & {_spec:       spec},
		#KustomizeController & {_spec:    spec},
		#HelmController & {_spec:         spec},
		#NotificationController & {_spec: spec},
	]

	resources: [ID=_]: runtime.#Object
	resources: {
		"\(spec.name)-namespace":          #Namespace & {_spec:          spec}
		"\(spec.name)-serviceaccount":     #ServiceAccount & {_spec:     spec}
		"\(spec.name)-clusterrolebinding": #ClusterRoleBinding & {_spec: spec}
		"\(spec.name)-service":            #WebhookReceiver & {_spec:    spec}
		"\(spec.name)-deployment":         #Deployment & {
			_spec:       spec
			_containers: containers
		}
	}

	resources: {
		for name, crd in customresourcedefinition {
			"\(name)": crd
			"\(name)": metadata: labels:      spec.labels
			"\(name)": metadata: annotations: spec.annotations
		}
	}
}
