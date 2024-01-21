package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#NamespaceAdmin: rbacv1.#RoleBinding & {
	#config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata:   #config.metadata
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      #config.fluxServiceAccount
			namespace: #config.metadata.namespace
		},
	]
}

#ClusterAdmin: rbacv1.#ClusterRoleBinding & {
	#config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:   "\(#config.metadata.name)-\(#config.metadata.namespace)"
		labels: #config.metadata.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
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
			name:      #config.fluxServiceAccount
			namespace: #config.metadata.namespace
		},
	]
}
