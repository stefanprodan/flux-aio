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

	// OCI artifact settings
	artifact: {
		url!:     string & =~"^oci://.*$"
		tag:      *"latest" | string
		semver?:  string
		interval: *1 | int
		ignore:   *"" | string
	}

	// OCI registry auth settings
	auth: {
		// OCI registry OIDC provider
		provider: *"generic" | "aws" | "azure" | "gcp"
		// OCI registry basic auth credentials
		credentials?: {
			username!: string
			password!: string
		}
	}

	// OCI registry TLS settings
	tls: {
		// Allow insecure non TLS connections
		insecure: *false | bool
		// OCI registry CA certificate for allowing self-signed certs
		ca?: string
	}

	// Cluster reconciler settings
	sync: {
		path:          *"./" | string
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

	decryption?: {
		provider: string
		secretRef?: {
			name: string
		}
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		ocirepository: #OCIRepository & {#config: config}
		kustomization: #Kustomization & {#config: config}
	}

	if config.auth.credentials != _|_ {
		objects: imagepullsecret: #PullSecret & {#config: config}
	}

	if config.tls.ca != _|_ {
		objects: tlssecret: #TLSSecret & {#config: config}
	}
}
