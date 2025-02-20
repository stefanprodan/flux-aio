// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f https://github.com/fluxcd/flux2/releases/download/v2.5.0/install.yaml

package v1

import "strings"

// Kustomization is the Schema for the kustomizations API.
#Kustomization: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "kustomize.toolkit.fluxcd.io/v1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "Kustomization"
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

	// KustomizationSpec defines the configuration to calculate the
	// desired state
	// from a Source using Kustomize.
	spec!: #KustomizationSpec
}

// KustomizationSpec defines the configuration to calculate the
// desired state
// from a Source using Kustomize.
#KustomizationSpec: {
	// CommonMetadata specifies the common labels and annotations that
	// are
	// applied to all resources. Any existing label or annotation will
	// be
	// overridden if its key matches a common one.
	commonMetadata?: {
		// Annotations to be added to the object's metadata.
		annotations?: close({
			[string]: string
		})

		// Labels to be added to the object's metadata.
		labels?: close({
			[string]: string
		})
	}

	// Components specifies relative paths to specifications of other
	// Components.
	components?: [...string]

	// Decrypt Kubernetes secrets before applying them on the cluster.
	decryption?: {
		// Provider is the name of the decryption engine.
		provider!: "sops"
		secretRef?: {
			// Name of the referent.
			name!: string
		}
	}

	// DeletionPolicy can be used to control garbage collection when
	// this
	// Kustomization is deleted. Valid values are ('MirrorPrune',
	// 'Delete',
	// 'Orphan'). 'MirrorPrune' mirrors the Prune field (orphan if
	// false,
	// delete if true). Defaults to 'MirrorPrune'.
	deletionPolicy?: "MirrorPrune" | "Delete" | "Orphan"

	// DependsOn may contain a meta.NamespacedObjectReference slice
	// with references to Kustomization resources that must be ready
	// before this
	// Kustomization can be reconciled.
	dependsOn?: [...{
		// Name of the referent.
		name!: string

		// Namespace of the referent, when not specified it acts as
		// LocalObjectReference.
		namespace?: string
	}]

	// Force instructs the controller to recreate resources
	// when patching fails due to an immutable field change.
	force?: bool

	// HealthCheckExprs is a list of healthcheck expressions for
	// evaluating the
	// health of custom resources using Common Expression Language
	// (CEL).
	// The expressions are evaluated only when Wait or HealthChecks
	// are specified.
	healthCheckExprs?: [...{
		// APIVersion of the custom resource under evaluation.
		apiVersion!: string

		// Current is the CEL expression that determines if the status
		// of the custom resource has reached the desired state.
		current!: string

		// Failed is the CEL expression that determines if the status
		// of the custom resource has failed to reach the desired state.
		failed?: string

		// InProgress is the CEL expression that determines if the status
		// of the custom resource has not yet reached the desired state.
		inProgress?: string

		// Kind of the custom resource under evaluation.
		kind!: string
	}]

	// A list of resources to be included in the health assessment.
	healthChecks?: [...{
		// API version of the referent, if not specified the Kubernetes
		// preferred version will be used.
		apiVersion?: string

		// Kind of the referent.
		kind!: string

		// Name of the referent.
		name!: string

		// Namespace of the referent, when not specified it acts as
		// LocalObjectReference.
		namespace?: string
	}]

	// Images is a list of (image name, new name, new tag or digest)
	// for changing image names, tags or digests. This can also be
	// achieved with a
	// patch, but this operator is simpler to specify.
	images?: [...{
		// Digest is the value used to replace the original image tag.
		// If digest is present NewTag value is ignored.
		digest?: string

		// Name is a tag-less image name.
		name!: string

		// NewName is the value used to replace the original name.
		newName?: string

		// NewTag is the value used to replace the original tag.
		newTag?: string
	}]

	// The interval at which to reconcile the Kustomization.
	// This interval is approximate and may be subject to jitter to
	// ensure
	// efficient use of resources.
	interval!: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"
	kubeConfig?: {
		// SecretRef holds the name of a secret that contains a key with
		// the kubeconfig file as the value. If no key is set, the key
		// will default
		// to 'value'.
		// It is recommended that the kubeconfig is self-contained, and
		// the secret
		// is regularly updated if credentials such as a
		// cloud-access-token expire.
		// Cloud specific `cmd-path` auth helpers will not function
		// without adding
		// binaries and credentials to the Pod that is responsible for
		// reconciling
		// Kubernetes resources.
		secretRef!: {
			// Key in the Secret, when not specified an
			// implementation-specific default key is used.
			key?: string

			// Name of the Secret.
			name!: string
		}
	}

	// NamePrefix will prefix the names of all managed resources.
	namePrefix?: strings.MaxRunes(200) & strings.MinRunes(1)

	// NameSuffix will suffix the names of all managed resources.
	nameSuffix?: strings.MaxRunes(200) & strings.MinRunes(1)

	// Strategic merge and JSON patches, defined as inline YAML
	// objects,
	// capable of targeting objects based on kind, label and
	// annotation selectors.
	patches?: [...{
		// Patch contains an inline StrategicMerge patch or an inline
		// JSON6902 patch with
		// an array of operation objects.
		patch!: string

		// Target points to the resources that the patch document should
		// be applied to.
		target?: {
			// AnnotationSelector is a string that follows the label selection
			// expression
			// https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
			// It matches with the resource annotations.
			annotationSelector?: string

			// Group is the API group to select resources from.
			// Together with Version and Kind it is capable of unambiguously
			// identifying and/or selecting resources.
			// https://github.com/kubernetes/community/blob/master/contributors/design-proposals/api-machinery/api-group.md
			group?: string

			// Kind of the API Group to select resources from.
			// Together with Group and Version it is capable of unambiguously
			// identifying and/or selecting resources.
			// https://github.com/kubernetes/community/blob/master/contributors/design-proposals/api-machinery/api-group.md
			kind?: string

			// LabelSelector is a string that follows the label selection
			// expression
			// https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#api
			// It matches with the resource labels.
			labelSelector?: string

			// Name to match resources with.
			name?: string

			// Namespace to select resources from.
			namespace?: string

			// Version of the API Group to select resources from.
			// Together with Group and Kind it is capable of unambiguously
			// identifying and/or selecting resources.
			// https://github.com/kubernetes/community/blob/master/contributors/design-proposals/api-machinery/api-group.md
			version?: string
		}
	}]

	// Path to the directory containing the kustomization.yaml file,
	// or the
	// set of plain YAMLs a kustomization.yaml should be generated
	// for.
	// Defaults to 'None', which translates to the root path of the
	// SourceRef.
	path?: string

	// PostBuild describes which actions to perform on the YAML
	// manifest
	// generated by building the kustomize overlay.
	postBuild?: {
		// Substitute holds a map of key/value pairs.
		// The variables defined in your YAML manifests that match any of
		// the keys
		// defined in the map will be substituted with the set value.
		// Includes support for bash string replacement functions
		// e.g. ${var:=default}, ${var:position} and
		// ${var/substring/replacement}.
		substitute?: close({
			[string]: string
		})

		// SubstituteFrom holds references to ConfigMaps and Secrets
		// containing
		// the variables and their values to be substituted in the YAML
		// manifests.
		// The ConfigMap and the Secret data keys represent the var names,
		// and they
		// must match the vars declared in the manifests for the
		// substitution to
		// happen.
		substituteFrom?: [...{
			// Kind of the values referent, valid values are ('Secret',
			// 'ConfigMap').
			kind!: "Secret" | "ConfigMap"

			// Name of the values referent. Should reside in the same
			// namespace as the
			// referring resource.
			name!: strings.MaxRunes(253) & strings.MinRunes(1)

			// Optional indicates whether the referenced resource must exist,
			// or whether to
			// tolerate its absence. If true and the referenced resource is
			// absent, proceed
			// as if the resource was present but empty, without any variables
			// defined.
			optional?: bool
		}]
	}

	// Prune enables garbage collection.
	prune!: bool

	// The interval at which to retry a previously failed
	// reconciliation.
	// When not specified, the controller uses the
	// KustomizationSpec.Interval
	// value to retry failures.
	retryInterval?: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"

	// The name of the Kubernetes service account to impersonate
	// when reconciling this Kustomization.
	serviceAccountName?: string

	// Reference of the source where the kustomization file is.
	sourceRef!: {
		// API version of the referent.
		apiVersion?: string

		// Kind of the referent.
		kind!: "OCIRepository" | "GitRepository" | "Bucket"

		// Name of the referent.
		name!: string

		// Namespace of the referent, defaults to the namespace of the
		// Kubernetes
		// resource object that contains the reference.
		namespace?: string
	}

	// This flag tells the controller to suspend subsequent kustomize
	// executions,
	// it does not apply to already started executions. Defaults to
	// false.
	suspend?: bool

	// TargetNamespace sets or overrides the namespace in the
	// kustomization.yaml file.
	targetNamespace?: strings.MaxRunes(63) & strings.MinRunes(1)

	// Timeout for validation, apply and health checking operations.
	// Defaults to 'Interval' duration.
	timeout?: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"

	// Wait instructs the controller to check the health of all the
	// reconciled
	// resources. When enabled, the HealthChecks are ignored. Defaults
	// to false.
	wait?: bool
}
