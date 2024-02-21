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
		url!: string & =~"^(http|https|oci)://.*$"
		auth?: {
			username!: string
			password!: string
		}
		provider: *"generic" | "aws" | "azure" | "gcp"
		insecure: *false | bool
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

	dependsOn?: [...{
		name:       string
		namespace?: string
	}]
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		repository: #HelmRepository & {#config: config}
		release: #HelmRelease & {#config: config}
	}

	if config.repository.auth != _|_ {
		objects: secret: #HelmRepositoryAuth & {#config: config}
	}
}
