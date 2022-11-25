package distribution

import (
	runtime "k8s.io/apimachinery/pkg/runtime"
)

#FluxAutoSyncSpec: {
	image:     string
	name:      *"flux" | string
	namespace: *"flux-system" | string
	interval:  *"10m" | string
	semver:    *"*" | string

	labels: *{
			"app.kubernetes.io/part-of": "flux"
	} | {[ string]: string}

	annotations: *{
			"app.kubernetes.io/role": "cluster-admin"
	} | {[ string]: string}
}

#FluxAutoSync: {
	spec: #FluxAutoSyncSpec

	resources: [ID=_]: runtime.#Object
	resources: {
		"\(spec.name)-source":        #FluxSource & {_spec:        spec}
		"\(spec.name)-kustomization": #FluxKustomization & {_spec: spec}
	}
}

#FluxSource: runtime.#Object & {
	_spec: #FluxAutoSyncSpec

	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       "OCIRepository"
	metadata: {
		name:        "\(_spec.name)-source"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		timeout:  "1m"
		interval: _spec.interval
		url:      "oci://\(_spec.image)"
		ref: semver: "\(_spec.semver)"
	}
}

#FluxKustomization: runtime.#Object & {
	_spec: #FluxAutoSyncSpec

	apiVersion: "kustomize.toolkit.fluxcd.io/v1beta2"
	kind:       "Kustomization"
	metadata: {
		name:        "\(_spec.name)-sync"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		interval:      "24h"
		timeout:       "2m"
		retryInterval: "1m"
		sourceRef: {
			kind: "OCIRepository"
			name: "\(_spec.name)-source"
		}
		path:  "./"
		prune: true
	}
}
