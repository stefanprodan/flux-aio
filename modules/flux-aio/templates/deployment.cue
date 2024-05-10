package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config: #Config
	_containers: [...corev1.#Container]

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #config.metadata
	if #config.workload.provider == "azure" {
		metadata: labels: "azure.workload.identity/use": "true"
	}
	spec: appsv1.#DeploymentSpec & {
		replicas: 1
		strategy: {
			type: "Recreate"
		}
		selector: matchLabels: #config.selector.labels
		template: {
			metadata: {
				labels: #config.selector.labels
				if #config.workload.provider == "azure" {
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
				if #config.compatibility == "kubernetes" {
					securityContext: fsGroup: 1337
				}
				serviceAccountName: #config.metadata.name
				hostNetwork:        #config.hostNetwork
				volumes: [{
					name: "data"
					if !#config.persistence.enabled {
						emptyDir: {}
					}
					if #config.persistence.enabled {
						persistentVolumeClaim: claimName: #config.metadata.name
					}
				}, {
					name: "tmp"
					if !#config.tmpfs.enabled {
						emptyDir: {}
					}
					if #config.tmpfs.enabled {
						emptyDir: {
							medium: "Memory"
							if #config.tmpfs.sizeLimit != _|_ {
								sizeLimit: #config.tmpfs.sizeLimit
							}
						}
					}
				}]
				containers: _containers
				affinity:   #config.affinity
				if #config.tolerations != _|_ {
					tolerations: #config.tolerations
				}
				if #config.imagePullSecrets != _|_ {
					imagePullSecrets: #config.imagePullSecrets
				}
				if #config.imagePullSecret != _|_ {
					imagePullSecrets: [{
						name: #config.metadata.name + "-image-pull"
					}]
				}
			}
		}
	}
}
