// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go k8s.io/api/resource/v1alpha1

package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/types"
)

// ResourceClaim describes which resources are needed by a resource consumer.
// Its status tracks whether the resource has been allocated and what the
// resulting attributes are.
//
// This is an alpha type and requires enabling the DynamicResourceAllocation
// feature gate.
#ResourceClaim: {
	metav1.#TypeMeta

	// Standard object metadata
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// Spec describes the desired attributes of a resource that then needs
	// to be allocated. It can only be set once when creating the
	// ResourceClaim.
	spec: #ResourceClaimSpec @go(Spec) @protobuf(2,bytes)

	// Status describes whether the resource is available and with which
	// attributes.
	// +optional
	status?: #ResourceClaimStatus @go(Status) @protobuf(3,bytes,opt)
}

// ResourceClaimSpec defines how a resource is to be allocated.
#ResourceClaimSpec: {
	// ResourceClassName references the driver and additional parameters
	// via the name of a ResourceClass that was created as part of the
	// driver deployment.
	resourceClassName: string @go(ResourceClassName) @protobuf(1,bytes)

	// ParametersRef references a separate object with arbitrary parameters
	// that will be used by the driver when allocating a resource for the
	// claim.
	//
	// The object must be in the same namespace as the ResourceClaim.
	// +optional
	parametersRef?: null | #ResourceClaimParametersReference @go(ParametersRef,*ResourceClaimParametersReference) @protobuf(2,bytes,opt)

	// Allocation can start immediately or when a Pod wants to use the
	// resource. "WaitForFirstConsumer" is the default.
	// +optional
	allocationMode?: #AllocationMode @go(AllocationMode) @protobuf(3,bytes,opt)
}

// AllocationMode describes whether a ResourceClaim gets allocated immediately
// when it gets created (AllocationModeImmediate) or whether allocation is
// delayed until it is needed for a Pod
// (AllocationModeWaitForFirstConsumer). Other modes might get added in the
// future.
#AllocationMode: string // #enumAllocationMode

#enumAllocationMode:
	#AllocationModeWaitForFirstConsumer |
	#AllocationModeImmediate

// When a ResourceClaim has AllocationModeWaitForFirstConsumer, allocation is
// delayed until a Pod gets scheduled that needs the ResourceClaim. The
// scheduler will consider all resource requirements of that Pod and
// trigger allocation for a node that fits the Pod.
#AllocationModeWaitForFirstConsumer: #AllocationMode & "WaitForFirstConsumer"

// When a ResourceClaim has AllocationModeImmediate, allocation starts
// as soon as the ResourceClaim gets created. This is done without
// considering the needs of Pods that will use the ResourceClaim
// because those Pods are not known yet.
#AllocationModeImmediate: #AllocationMode & "Immediate"

// ResourceClaimStatus tracks whether the resource has been allocated and what
// the resulting attributes are.
#ResourceClaimStatus: {
	// DriverName is a copy of the driver name from the ResourceClass at
	// the time when allocation started.
	// +optional
	driverName?: string @go(DriverName) @protobuf(1,bytes,opt)

	// Allocation is set by the resource driver once a resource has been
	// allocated successfully. If this is not specified, the resource is
	// not yet allocated.
	// +optional
	allocation?: null | #AllocationResult @go(Allocation,*AllocationResult) @protobuf(2,bytes,opt)

	// ReservedFor indicates which entities are currently allowed to use
	// the claim. A Pod which references a ResourceClaim which is not
	// reserved for that Pod will not be started.
	//
	// There can be at most 32 such reservations. This may get increased in
	// the future, but not reduced.
	//
	// +listType=map
	// +listMapKey=uid
	// +optional
	reservedFor?: [...#ResourceClaimConsumerReference] @go(ReservedFor,[]ResourceClaimConsumerReference) @protobuf(3,bytes,opt)

	// DeallocationRequested indicates that a ResourceClaim is to be
	// deallocated.
	//
	// The driver then must deallocate this claim and reset the field
	// together with clearing the Allocation field.
	//
	// While DeallocationRequested is set, no new consumers may be added to
	// ReservedFor.
	// +optional
	deallocationRequested?: bool @go(DeallocationRequested) @protobuf(4,varint,opt)
}

#ResourceClaimReservedForMaxSize: 32

// AllocationResult contains attributed of an allocated resource.
#AllocationResult: {
	// ResourceHandle contains arbitrary data returned by the driver after a
	// successful allocation. This is opaque for
	// Kubernetes. Driver documentation may explain to users how to
	// interpret this data if needed.
	//
	// The maximum size of this field is 16KiB. This may get
	// increased in the future, but not reduced.
	// +optional
	resourceHandle?: string @go(ResourceHandle) @protobuf(1,bytes,opt)

	// This field will get set by the resource driver after it has
	// allocated the resource driver to inform the scheduler where it can
	// schedule Pods using the ResourceClaim.
	//
	// Setting this field is optional. If null, the resource is available
	// everywhere.
	// +optional
	availableOnNodes?: null | v1.#NodeSelector @go(AvailableOnNodes,*v1.NodeSelector) @protobuf(2,bytes,opt)

	// Shareable determines whether the resource supports more
	// than one consumer at a time.
	// +optional
	shareable?: bool @go(Shareable) @protobuf(3,varint,opt)
}

#ResourceHandleMaxSize: 16384

// ResourceClaimList is a collection of claims.
#ResourceClaimList: {
	metav1.#TypeMeta

	// Standard list metadata
	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// Items is the list of resource claims.
	items: [...#ResourceClaim] @go(Items,[]ResourceClaim) @protobuf(2,bytes,rep)
}

// PodScheduling objects hold information that is needed to schedule
// a Pod with ResourceClaims that use "WaitForFirstConsumer" allocation
// mode.
//
// This is an alpha type and requires enabling the DynamicResourceAllocation
// feature gate.
#PodScheduling: {
	metav1.#TypeMeta

	// Standard object metadata
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// Spec describes where resources for the Pod are needed.
	spec: #PodSchedulingSpec @go(Spec) @protobuf(2,bytes)

	// Status describes where resources for the Pod can be allocated.
	// +optional
	status?: #PodSchedulingStatus @go(Status) @protobuf(3,bytes,opt)
}

// PodSchedulingSpec describes where resources for the Pod are needed.
#PodSchedulingSpec: {
	// SelectedNode is the node for which allocation of ResourceClaims that
	// are referenced by the Pod and that use "WaitForFirstConsumer"
	// allocation is to be attempted.
	// +optional
	selectedNode?: string @go(SelectedNode) @protobuf(1,bytes,opt)

	// PotentialNodes lists nodes where the Pod might be able to run.
	//
	// The size of this field is limited to 128. This is large enough for
	// many clusters. Larger clusters may need more attempts to find a node
	// that suits all pending resources. This may get increased in the
	// future, but not reduced.
	//
	// +listType=set
	// +optional
	potentialNodes?: [...string] @go(PotentialNodes,[]string) @protobuf(2,bytes,opt)
}

// PodSchedulingStatus describes where resources for the Pod can be allocated.
#PodSchedulingStatus: {
	// ResourceClaims describes resource availability for each
	// pod.spec.resourceClaim entry where the corresponding ResourceClaim
	// uses "WaitForFirstConsumer" allocation mode.
	//
	// +listType=map
	// +listMapKey=name
	// +optional
	resourceClaims?: [...#ResourceClaimSchedulingStatus] @go(ResourceClaims,[]ResourceClaimSchedulingStatus) @protobuf(1,bytes,opt)
}

// ResourceClaimSchedulingStatus contains information about one particular
// ResourceClaim with "WaitForFirstConsumer" allocation mode.
#ResourceClaimSchedulingStatus: {
	// Name matches the pod.spec.resourceClaims[*].Name field.
	// +optional
	name?: string @go(Name) @protobuf(1,bytes,opt)

	// UnsuitableNodes lists nodes that the ResourceClaim cannot be
	// allocated for.
	//
	// The size of this field is limited to 128, the same as for
	// PodSchedulingSpec.PotentialNodes. This may get increased in the
	// future, but not reduced.
	//
	// +listType=set
	// +optional
	unsuitableNodes?: [...string] @go(UnsuitableNodes,[]string) @protobuf(2,bytes,opt)
}

#PodSchedulingNodeListMaxSize: 128

// PodSchedulingList is a collection of Pod scheduling objects.
#PodSchedulingList: {
	metav1.#TypeMeta

	// Standard list metadata
	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// Items is the list of PodScheduling objects.
	items: [...#PodScheduling] @go(Items,[]PodScheduling) @protobuf(2,bytes,rep)
}

// ResourceClass is used by administrators to influence how resources
// are allocated.
//
// This is an alpha type and requires enabling the DynamicResourceAllocation
// feature gate.
#ResourceClass: {
	metav1.#TypeMeta

	// Standard object metadata
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// DriverName defines the name of the dynamic resource driver that is
	// used for allocation of a ResourceClaim that uses this class.
	//
	// Resource drivers have a unique name in forward domain order
	// (acme.example.com).
	driverName: string @go(DriverName) @protobuf(2,bytes)

	// ParametersRef references an arbitrary separate object that may hold
	// parameters that will be used by the driver when allocating a
	// resource that uses this class. A dynamic resource driver can
	// distinguish between parameters stored here and and those stored in
	// ResourceClaimSpec.
	// +optional
	parametersRef?: null | #ResourceClassParametersReference @go(ParametersRef,*ResourceClassParametersReference) @protobuf(3,bytes,opt)

	// Only nodes matching the selector will be considered by the scheduler
	// when trying to find a Node that fits a Pod when that Pod uses
	// a ResourceClaim that has not been allocated yet.
	//
	// Setting this field is optional. If null, all nodes are candidates.
	// +optional
	suitableNodes?: null | v1.#NodeSelector @go(SuitableNodes,*v1.NodeSelector) @protobuf(4,bytes,opt)
}

// ResourceClassList is a collection of classes.
#ResourceClassList: {
	metav1.#TypeMeta

	// Standard list metadata
	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// Items is the list of resource classes.
	items: [...#ResourceClass] @go(Items,[]ResourceClass) @protobuf(2,bytes,rep)
}

// ResourceClassParametersReference contains enough information to let you
// locate the parameters for a ResourceClass.
#ResourceClassParametersReference: {
	// APIGroup is the group for the resource being referenced. It is
	// empty for the core API. This matches the group in the APIVersion
	// that is used when creating the resources.
	// +optional
	apiGroup?: string @go(APIGroup) @protobuf(1,bytes,opt)

	// Kind is the type of resource being referenced. This is the same
	// value as in the parameter object's metadata.
	kind: string @go(Kind) @protobuf(2,bytes)

	// Name is the name of resource being referenced.
	name: string @go(Name) @protobuf(3,bytes)

	// Namespace that contains the referenced resource. Must be empty
	// for cluster-scoped resources and non-empty for namespaced
	// resources.
	// +optional
	namespace?: string @go(Namespace) @protobuf(4,bytes,opt)
}

// ResourceClaimParametersReference contains enough information to let you
// locate the parameters for a ResourceClaim. The object must be in the same
// namespace as the ResourceClaim.
#ResourceClaimParametersReference: {
	// APIGroup is the group for the resource being referenced. It is
	// empty for the core API. This matches the group in the APIVersion
	// that is used when creating the resources.
	// +optional
	apiGroup?: string @go(APIGroup) @protobuf(1,bytes,opt)

	// Kind is the type of resource being referenced. This is the same
	// value as in the parameter object's metadata, for example "ConfigMap".
	kind: string @go(Kind) @protobuf(2,bytes)

	// Name is the name of resource being referenced.
	name: string @go(Name) @protobuf(3,bytes)
}

// ResourceClaimConsumerReference contains enough information to let you
// locate the consumer of a ResourceClaim. The user must be a resource in the same
// namespace as the ResourceClaim.
#ResourceClaimConsumerReference: {
	// APIGroup is the group for the resource being referenced. It is
	// empty for the core API. This matches the group in the APIVersion
	// that is used when creating the resources.
	// +optional
	apiGroup?: string @go(APIGroup) @protobuf(1,bytes,opt)

	// Resource is the type of resource being referenced, for example "pods".
	resource: string @go(Resource) @protobuf(3,bytes)

	// Name is the name of resource being referenced.
	name: string @go(Name) @protobuf(4,bytes)

	// UID identifies exactly one incarnation of the resource.
	uid: types.#UID @go(UID) @protobuf(5,bytes)
}

// ResourceClaimTemplate is used to produce ResourceClaim objects.
#ResourceClaimTemplate: {
	metav1.#TypeMeta

	// Standard object metadata
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// Describes the ResourceClaim that is to be generated.
	//
	// This field is immutable. A ResourceClaim will get created by the
	// control plane for a Pod when needed and then not get updated
	// anymore.
	spec: #ResourceClaimTemplateSpec @go(Spec) @protobuf(2,bytes)
}

// ResourceClaimTemplateSpec contains the metadata and fields for a ResourceClaim.
#ResourceClaimTemplateSpec: {
	// ObjectMeta may contain labels and annotations that will be copied into the PVC
	// when creating it. No other fields are allowed and will be rejected during
	// validation.
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// Spec for the ResourceClaim. The entire content is copied unchanged
	// into the ResourceClaim that gets created from this template. The
	// same fields as in a ResourceClaim are also valid here.
	spec: #ResourceClaimSpec @go(Spec) @protobuf(2,bytes)
}

// ResourceClaimTemplateList is a collection of claim templates.
#ResourceClaimTemplateList: {
	metav1.#TypeMeta

	// Standard list metadata
	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// Items is the list of resource claim templates.
	items: [...#ResourceClaimTemplate] @go(Items,[]ResourceClaimTemplate) @protobuf(2,bytes,rep)
}
