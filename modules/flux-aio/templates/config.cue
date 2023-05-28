package templates

import (
	"strings"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Metadata (common to all resources)
	metadata: metav1.#ObjectMeta
	metadata: name:      *"flux" | string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)
	metadata: namespace: *"flux-system" | string & strings.MaxRunes(63)

	metadata: labels: *{
			"app.kubernetes.io/name":    metadata.name
			"app.kubernetes.io/version": version
			"app.kubernetes.io/part-of": "flux"
	} | {[ string]: string}

	metadata: annotations: *{
			"app.kubernetes.io/role": "cluster-admin"
	} | {[ string]: string}

	version: string

	controllers: {
		source:       string
		kustomize:    string
		helm:         string
		notification: string
	}

	securityProfile: "restricted" | "privileged"

	logLevel: *"info" | string

	resources: *{
		requests: {
			cpu:    "100m"
			memory: "64Mi"
		}
		limits: memory: "1Gi"
	} | corev1.#ResourceRequirements

	imagePullSecrets?: [...corev1.LocalObjectReference]

	securityContext: *{
		allowPrivilegeEscalation: false
		readOnlyRootFilesystem:   true
		runAsNonRoot:             true
		capabilities: drop: ["ALL"]
		seccompProfile: type: "RuntimeDefault"
	} | corev1.#PodSecurityContext

	tolerations: *[{
		operator: "Exists"
	}] | corev1.#Toleration

	affinity?: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
		matchExpressions: [{
			key:      "kubernetes.io/os"
			operator: "In"
			values: ["linux"]
		}]
	}] | corev1.#Affinity
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	containers: [
		#SourceController & {_spec:       config},
		#KustomizeController & {_spec:    config},
		#HelmController & {_spec:         config},
		#NotificationController & {_spec: config},
	]

	objects: [ID=_]: runtime.#Object

	objects: {
		for name, crd in customresourcedefinition {
			"\(name)": crd
			"\(name)": metadata: labels:      config.metadata.labels
			"\(name)": metadata: annotations: config.metadata.annotations
		}
	}

	objects: {
		"\(config.metadata.name)-namespace":          #Namespace & {_spec:          config}
		"\(config.metadata.name)-serviceaccount":     #ServiceAccount & {_spec:     config}
		"\(config.metadata.name)-clusterrolebinding": #ClusterRoleBinding & {_spec: config}
		"\(config.metadata.name)-webhookreceiver":    #WebhookReceiver & {_spec:    config}
		"\(config.metadata.name)-sourceserver":       #SourceServer & {_spec:       config}
		"\(config.metadata.name)-deployment":         #Deployment & {
			_spec:       config
			_containers: containers
		}
	}
}
