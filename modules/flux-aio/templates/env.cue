package templates

import "list"

#ContainerEnv: {
	#config: #Config
	defaultEnv: [
		{
			name:  "SOURCE_CONTROLLER_LOCALHOST"
			value: "localhost:9790"
		},
		{
			name: "RUNTIME_NAMESPACE"
			valueFrom: fieldRef: fieldPath: "metadata.namespace"
		},
		{
			name: "GOMAXPROCS"
			valueFrom: resourceFieldRef: resource: "limits.cpu"
		},
		{
			name: "GOMEMLIMIT"
			valueFrom: resourceFieldRef: resource: "limits.memory"
		},
		{
			name:  "TUF_ROOT"
			value: "/tmp/.sigstore"
		},
		{
			name:  "NO_PROXY"
			value: #config.proxy.no
		},
		if #config.proxy.https != _|_ {
			{
				name:  "HTTPS_PROXY"
				value: #config.proxy.https
			}},
		if #config.proxy.http != _|_ {
			{
				name:  "HTTP_PROXY"
				value: #config.proxy.http
			}},
	]

	extraEnv: [...]
	if #config.env != _|_ {
		extraEnv: [for k , v in #config.env {name: k, value: v}]
	}

	env: list.Concat([defaultEnv, extraEnv])
}
