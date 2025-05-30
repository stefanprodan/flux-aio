package templates

import (
	corev1 "k8s.io/api/core/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Timoni runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Enforce minimum Kubernetes version
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.21.0"}

	// Flux distribution version
	version: string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: version}
	metadata: {
		labels: "app.kubernetes.io/part-of":   "flux"
		annotations: "app.kubernetes.io/role": "cluster-admin"
	}
	selector: timoniv1.#Selector & {#Name: metadata.name}

	controllers: {
		source: {
			image:        timoniv1.#Image
			resources?:   corev1.#ResourceRequirements
			featureGates: *"" | string
		}
		kustomize: {
			enabled:      *true | bool
			image:        timoniv1.#Image
			resources?:   timoniv1.#ResourceRequirements
			featureGates: *"" | string
		}
		helm: {
			enabled:      *true | bool
			image:        timoniv1.#Image
			resources?:   timoniv1.#ResourceRequirements
			featureGates: *"" | string
		}
		notification: {
			enabled:      *true | bool
			image:        timoniv1.#Image
			resources?:   timoniv1.#ResourceRequirements
			featureGates: *"" | string
		}
	}

	expose: {
		webhookReceiver:    *false | bool
		notificationServer: *false | bool
		sourceServer:       *false | bool
	}

	proxy: {
		https?: string
		http?:  string
		no:     *".cluster.local.,.cluster.local,.svc" | string
	}

	env?: [string]: string

	securityProfile: "restricted" | "privileged"

	podSecurityProfile: *"" | "restricted" | "privileged"

	logLevel: *"info" | string

	hostNetwork: *true | bool

	compatibility: *"kubernetes" | "openshift"

	workload: {
		provider: *"" | "aws" | "azure" | "gcp"
		identity: *"" | string
	}

	reconcile: {
		concurrent: *5 | int
		requeue:    *30 | int
	}

	persistence: {
		enabled:      *false | bool
		storageClass: *"standard" | string
		size:         *"8Gi" | string & =~"^([0-9]*)?(Gi)?$"
	}

	tmpfs: {
		enabled:    *false | bool
		sizeLimit?: string & =~"^([0-9]*)?(Mi|Gi)?$"
	}

	resources: timoniv1.#ResourceRequirements
	resources: requests: cpu:    *"100m" | timoniv1.#CPUQuantity
	resources: requests: memory: *"64Mi" | timoniv1.#MemoryQuantity
	resources: limits: memory:   *"1Gi" | timoniv1.#MemoryQuantity

	imagePullSecrets?: [...timoniv1.#ObjectReference]
	imagePullSecret?: {
		registry!: string
		username!: string
		password!: string
	}

	securityContext: *{
		allowPrivilegeEscalation: false
		readOnlyRootFilesystem:   true
		runAsNonRoot:             true
		capabilities: drop: ["ALL"]
		seccompProfile: type: "RuntimeDefault"
	} | corev1.#PodSecurityContext

	affinity: corev1.#Affinity
	affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
		matchExpressions: [{
			key:      "kubernetes.io/os"
			operator: "In"
			values: ["linux"]
		}]
	}]
	affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: [{
		topologyKey: "kubernetes.io/hostname"
		labelSelector: matchExpressions: [{
			key:      "app.kubernetes.io/name"
			operator: "In"
			values: [metadata.name]
		}]
	}]

	tolerations: *[{
		operator: "Exists"
		key:      "node.kubernetes.io/not-ready"
	}, {
		operator:          "Exists"
		key:               "node.kubernetes.io/unreachable"
		effect:            "NoExecute"
		tolerationSeconds: 300
	}] | [...corev1.#Toleration]

}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config
	containerEnv: #ContainerEnv & {#config: config}

	containers: [
		#SourceController & {#config: config, _env: containerEnv},
		if config.controllers.kustomize.enabled {
			#KustomizeController & {#config: config, _env: containerEnv}
		},
		if config.controllers.helm.enabled {
			#HelmController & {#config: config, _env: containerEnv}
		},
		if config.controllers.notification.enabled {
			#NotificationController & {#config: config, _env: containerEnv}
		},
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
		namespace: #Namespace & {#config: config}
		resourcequota: #ResourceQuota & {#config: config}
		serviceaccount: #ServiceAccount & {#config: config}
		clusterrol: #ClusterRole & {#config: config}
		clusterrolebinding: #ClusterRoleBinding & {#config: config}
		deployment: #Deployment & {
			#config:     config
			_containers: containers
		}
	}

	if config.controllers.notification.enabled && config.expose.webhookReceiver {
		objects: webhookreceiver: #WebhookService & {#config: config}
	}

	if config.controllers.notification.enabled && config.expose.notificationServer {
		objects: notificationserver: #NotificationService & {#config: config}
	}

	if config.expose.sourceServer {
		objects: sourceserver: #SourceService & {#config: config}
	}

	if config.persistence.enabled {
		objects: pvc: #PVC & {#config: config}
	}

	if config.imagePullSecret != _|_ {
		objects: imagepullsecret: #PullSecret & {#config: config}
	}
}
