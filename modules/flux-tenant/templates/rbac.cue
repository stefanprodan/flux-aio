package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#NamespaceAdmin: rbacv1.#RoleBinding & {
	_config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata:   _config.metadata
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      _config.fluxServiceAccount
			namespace: _config.metadata.namespace
		},
	]
}

#ClusterAdmin: rbacv1.#ClusterRoleBinding & {
	_config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:   "\(_config.metadata.name)-\(_config.metadata.namespace)"
		labels: _config.metadata.labels
		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      _config.fluxServiceAccount
			namespace: _config.metadata.namespace
		},
	]
}
