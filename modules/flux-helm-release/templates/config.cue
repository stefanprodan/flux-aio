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

	repository: {
		url!: string
	}

	chart: {
		name!:   string
		version: string | *"*"
	}

	sync: {
		retries:             int | *-1
		interval:            int | *60
		serviceAccountName?: string
		targetNamespace?:    string
	}

	helmValues?: {...}

}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		repository: #HelmRepository & {_config: config}
		release:    #HelmRelease & {_config:    config}
	}
}
