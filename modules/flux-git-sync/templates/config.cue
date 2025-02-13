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

	// Git over HTTPS settings
	git: {
		url!:     string & =~"^https.*$"
		path!:    string
		ref:      *"refs/heads/main" | string
		interval: *1 | int
		token:    *"" | string
		ca:       *"" | string
		ignore:   *"" | string
	}

	// Cluster reconciler settings
	sync: {
		prune:         *true | bool
		wait:          *true | bool
		timeout:       *3 | int
		interval:      *60 | int
		retryInterval: *5 | int

		serviceAccountName?: string
		targetNamespace?:    string
	}

	substitute?: [string]: string

	dependsOn?: [...{
		name:       string
		namespace?: string
	}]
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		gitrepository: #GitRepository & {#config: config}
		kustomization: #Kustomization & {#config: config}
	}

	if config.git.token != "" {
		objects: gitsecret: #GitSecret & {#config: config}
	}
}
