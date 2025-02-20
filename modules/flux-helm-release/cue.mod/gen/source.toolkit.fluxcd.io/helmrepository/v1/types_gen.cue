// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f https://github.com/fluxcd/source-controller/releases/download/v1.3.0/source-controller.crds.yaml

package v1

import "strings"

// HelmRepository is the Schema for the helmrepositories API.
#HelmRepository: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "source.toolkit.fluxcd.io/v1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "HelmRepository"
	metadata!: {
		name!: strings.MaxRunes(253) & strings.MinRunes(1) & {
			string
		}
		namespace!: strings.MaxRunes(63) & strings.MinRunes(1) & {
			string
		}
		labels?: {
			[string]: string
		}
		annotations?: {
			[string]: string
		}
	}

	// HelmRepositorySpec specifies the required configuration to
	// produce an
	// Artifact for a Helm repository index YAML.
	spec!: #HelmRepositorySpec
}

// HelmRepositorySpec specifies the required configuration to
// produce an
// Artifact for a Helm repository index YAML.
#HelmRepositorySpec: {
	accessFrom?: {
		// NamespaceSelectors is the list of namespace selectors to which
		// this ACL applies.
		// Items in this list are evaluated using a logical OR operation.
		namespaceSelectors!: [...{
			// MatchLabels is a map of {key,value} pairs. A single {key,value}
			// in the matchLabels
			// map is equivalent to an element of matchExpressions, whose key
			// field is "key", the
			// operator is "In", and the values array contains only "value".
			// The requirements are ANDed.
			matchLabels?: close({
				[string]: string
			})
		}]
	}
	certSecretRef?: {
		// Name of the referent.
		name!: string
	}

	// Insecure allows connecting to a non-TLS HTTP container
	// registry.
	// This field is only taken into account if the .spec.type field
	// is set to 'oci'.
	insecure?: bool

	// Interval at which the HelmRepository URL is checked for
	// updates.
	// This interval is approximate and may be subject to jitter to
	// ensure
	// efficient use of resources.
	interval?: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"

	// PassCredentials allows the credentials from the SecretRef to be
	// passed
	// on to a host that does not match the host as defined in URL.
	// This may be required if the host of the advertised chart URLs
	// in the
	// index differ from the defined URL.
	// Enabling this should be done with caution, as it can
	// potentially result
	// in credentials getting stolen in a MITM-attack.
	passCredentials?: bool

	// Provider used for authentication, can be 'aws', 'azure', 'gcp'
	// or 'generic'.
	// This field is optional, and only taken into account if the
	// .spec.type field is set to 'oci'.
	// When not specified, defaults to 'generic'.
	provider?: "generic" | "aws" | "azure" | "gcp"
	secretRef?: {
		// Name of the referent.
		name!: string
	}

	// Suspend tells the controller to suspend the reconciliation of
	// this
	// HelmRepository.
	suspend?: bool

	// Timeout is used for the index fetch operation for an HTTPS helm
	// repository,
	// and for remote OCI Repository operations like pulling for an
	// OCI helm
	// chart by the associated HelmChart.
	// Its default value is 60s.
	timeout?: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m))+$"

	// Type of the HelmRepository.
	// When this field is set to "oci", the URL field value must be
	// prefixed with "oci://".
	type?: "default" | "oci"

	// URL of the Helm repository, a valid URL contains at least a
	// protocol and
	// host.
	url!: =~"^(http|https|oci)://.*$"
}
