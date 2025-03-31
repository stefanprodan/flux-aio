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

	// GitHub App settings
	github: {
		appID:             *"" | string
		appInstallationID: *"" | string
		appPrivateKey:     *"" | string
	}

	// Cluster reconciler settings
	sync: {
		prune:         *true | bool
		wait:          *true | bool
		timeout:       *3 | int
		retryInterval: *5 | int

		serviceAccountName?: string
		targetNamespace?:    string
	}

	substitute?: [string]: string
	substituteFrom?: [...{
		kind:      "Secret" | "ConfigMap"
		name:      string
		optional?: bool
	}]

	dependsOn?: [...{
		name:       string
		namespace?: string
	}]

	// Strategic merge and JSON patches, defined as inline YAML objects,
	// capable of targeting objects based on kind, label and annotation selectors.
	patches?: [...{
		patch!: {...} | [...]
		target: {
			annotationSelector?: string
			group?:              string
			kind?:               string
			labelSelector?:      string
			name?:               string
			namespace?:          string
			version?:            string
		}
	}]
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		gitrepository: #GitRepository & {#config: config}
		kustomization: #Kustomization & {#config: config}
	}

	if config.git.token != "" || config.github.appID != "" {
		objects: gitsecret: #GitSecret & {#config: config}
	}
}
