package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	_config: #Config
	_containers: [ ...corev1.#Container]

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   _config.metadata
	if _config.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use": "true"
	}
	spec: appsv1.#DeploymentSpec & {
		replicas: 1
		strategy: {
			type: "Recreate"
		}
		selector: matchLabels: "app.kubernetes.io/name": _config.metadata.name
		template: {
			metadata: {
				labels: "app.kubernetes.io/name": _config.metadata.name
				if _config.workload.provider == "azure" {
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
				serviceAccountName: _config.metadata.name
				hostNetwork:        _config.hostNetwork
				volumes: [{
					name: "data"
					if !_config.persistence.enabled {
						emptyDir: {}
					}
					if _config.persistence.enabled {
						persistentVolumeClaim: claimName: _config.metadata.name
					}
				}, {
					name: "tmp"
					if !_config.tmpfs.enabled {
						emptyDir: {}
					}
					if _config.tmpfs.enabled {
						emptyDir: {
							medium: "Memory"
							if _config.tmpfs.sizeLimit != _|_ {
								sizeLimit: _config.tmpfs.sizeLimit
							}
						}
					}
				}]
				containers: _containers
				affinity:   _config.affinity
				if _config.tolerations != _|_ {
					tolerations: _config.tolerations
				}
				if _config.imagePullSecrets != _|_ {
					imagePullSecrets: _config.imagePullSecrets
				}
			}
		}
	}
}
