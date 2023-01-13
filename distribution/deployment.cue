package distribution

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	_spec: #FluxSpec
	_containers: [ ...corev1.#Container]

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:        _spec.name
		namespace:   "\(_spec.name)-system"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: appsv1.#DeploymentSpec & {
		replicas: 1
		strategy: {
			type: "Recreate"
		}
		selector: matchLabels: "app.kubernetes.io/name": _spec.name
		template: {
			metadata: {
				labels: "app.kubernetes.io/name": _spec.name
				annotations: {
					"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
					"prometheus.io/scrape":                           "true"
				}
			}
			spec: corev1.#PodSpec & {
				terminationGracePeriodSeconds: 120
				securityContext: fsGroup: 1337
				serviceAccountName: _spec.name
				hostNetwork:        true
				tolerations: [{
					operator: "Exists"
				}]
				volumes: [{
					emptyDir: {}
					name: "data"
				}, {
					emptyDir: {}
					name: "tmp"
				}]
				containers: _containers
				if _spec.affinity != _|_ {
					affinity: _spec.affinity
				}
			}
		}
	}
}
