package templates

#ContainerEnv: {
	_config: #Config
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
			name:  "TUF_ROOT"
			value: "/tmp/.sigstore"
		},
		{
			name:  "NO_PROXY"
			value: _config.proxy.no
		},
		if _config.proxy.https != _|_ {
			{
				name:  "HTTPS_PROXY"
				value: _config.proxy.https
			}},
		if _config.proxy.http != _|_ {
			{
				name:  "HTTP_PROXY"
				value: _config.proxy.http
			}},
	]

	extraEnv: [...]
	if _config.env != _|_ {
		extraEnv: [ for k , v in _config.env {name: k, value: v}]
	}

	env: defaultEnv + extraEnv
}
