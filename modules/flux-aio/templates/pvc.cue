package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PVC: corev1.#PersistentVolumeClaim & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata:   _config.metadata
	spec:       corev1.#PersistentVolumeClaimSpec & {
		storageClassName: _config.persistence.storageClass
		resources: requests: storage: _config.persistence.size
		accessModes: ["ReadWriteOnce"]
	}
}
