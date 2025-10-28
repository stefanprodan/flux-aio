package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	#config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:        #config.metadata.name
		labels:      #config.metadata.labels
		annotations: #config.metadata.annotations
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      #config.metadata.name
			namespace: #config.metadata.namespace
		},
	]
}

#ClusterRole: rbacv1.#ClusterRole & {
	#config:    #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name:        "\(#config.metadata.name)-view"
		annotations: #config.metadata.annotations
		labels:      #config.metadata.labels
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
			"source.extensions.fluxcd.io",
		]
		resources: ["*"]
		verbs: [
			"get",
			"list",
			"watch",
		]
	}]
}
