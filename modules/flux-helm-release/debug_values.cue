@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	repository: {
		url: "oci://ghcr.io/stefanprodan/charts"
		auth: {
			username: "stefanprodan"
			password: "GITHUB_TOKEN"
		}
	}

	chart: {
		name:    "podinfo"
		version: "6.x"
	}

	helmValuesFrom: [{
		kind:       "ConfigMap"
		name:       "example-values"
		valuesKey:  "values.yaml"
		targetPath: "values"
	}]

	driftDetection: "enabled"
}
