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

	git: {
		url!:     string & =~"^https.*$"
		path!:    string
		ref:      *"refs/heads/main" | string
		interval: *1 | int
		token:    *"" | string
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		gitrepository: #GitRepository & {_config: config}
		kustomization: #Kustomization & {_config: config}
	}

	if config.git.token != "" {
		objects: gitsecret: #GitSecret & {_config: config}
	}
}
