package distribution

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	_spec:      #FluxSpec
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:        _spec.name
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      _spec.name
			namespace: "\(_spec.name)-system"
		},
	]
}
