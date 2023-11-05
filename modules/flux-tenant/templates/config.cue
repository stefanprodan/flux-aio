package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: labels: "toolkit.fluxcd.io/tenant": metadata.name

	fluxServiceAccount: string | *"flux"

	role: "namespace-admin" | "cluster-admin" | *"namespace-admin"

	resourceQuota: {
		kustomizations: int | *100
		helmreleases:   int | *100
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		namespace:      #Namespace & {_config:      config}
		serviceAccount: #ServiceAccount & {_config: config}
		roleBinding:    #NamespaceAdmin & {_config: config}
		resourcequota:  #ResourceQuota & {_config:  config}
	}

	if config.role == "cluster-admin" {
		objects: clusterRoleBinding: #ClusterAdmin & {_config: config}
	}
}
