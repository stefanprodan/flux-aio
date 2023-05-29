package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	_spec: #Config
	_containers: [ ...corev1.#Container]

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   _spec.metadata
	if _spec.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use": "true"
	}
	spec: appsv1.#DeploymentSpec & {
		replicas: 1
		strategy: {
			type: "Recreate"
		}
		selector: matchLabels: "app.kubernetes.io/name": _spec.metadata.name
		template: {
			metadata: {
				labels: "app.kubernetes.io/name": _spec.metadata.name
				if _spec.workload.provider == "azure" {
					labels: "azure.workload.identity/use": "true"
				}
				annotations: {
					"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
					"prometheus.io/scrape":                           "true"
				}
			}
			spec: corev1.#PodSpec & {
				priorityClassName:             "system-cluster-critical"
				terminationGracePeriodSeconds: 120
				securityContext: fsGroup: 1337
				serviceAccountName: _spec.metadata.name
				hostNetwork:        _spec.hostNetwork
				volumes: [{
					emptyDir: {}
					name: "data"
				}, {
					emptyDir: {}
					name: "tmp"
				}]
				containers: _containers
				if _spec.tolerations != _|_ {
					tolerations: _spec.tolerations
				}
				if _spec.affinity != _|_ {
					affinity: _spec.affinity
				}
				if _spec.imagePullSecrets != _|_ {
					imagePullSecrets: _spec.imagePullSecrets
				}
			}
		}
	}
}
