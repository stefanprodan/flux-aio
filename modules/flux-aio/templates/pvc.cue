package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PVC: corev1.#PersistentVolumeClaim & {
	_spec:      #Config
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata:   _spec.metadata
	spec:       corev1.#PersistentVolumeClaimSpec & {
		storageClassName: _spec.persistence.storageClass
		resources: requests: storage: _spec.persistence.size
		accessModes: ["ReadWriteOnce"]
	}
}
