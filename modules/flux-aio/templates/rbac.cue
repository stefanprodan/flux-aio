package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	_config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:        _config.metadata.name
		labels:      _config.metadata.labels
		annotations: _config.metadata.annotations
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      _config.metadata.name
			namespace: _config.metadata.namespace
		},
	]
}

#ClusterRole: rbacv1.#ClusterRole & {
	_config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name:        "\(_config.metadata.name)-view"
		annotations: _config.metadata.annotations
		labels:      _config.metadata.labels
		labels: {
			"rbac.authorization.k8s.io/aggregate-to-admin": "true"
			"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
			"rbac.authorization.k8s.io/aggregate-to-view":  "true"
		}
	}
	rules: [{
		apiGroups: [
			"notification.toolkit.fluxcd.io",
			"source.toolkit.fluxcd.io",
			"helm.toolkit.fluxcd.io",
			"image.toolkit.fluxcd.io",
			"kustomize.toolkit.fluxcd.io",
		]
		resources: ["*"]
		verbs: [
			"get",
			"list",
			"watch",
		]
	}]
}
