@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	artifact: {
		url:    "oci://ghcr.io/stefanprodan/manifests/podinfo"
		semver: ">1.0.0"
	}
	auth: credentials: {
		username: "flux"
		password: "test"
	}
	tls: ca: "test"
	sync: {
		targetNamespace: "default"
	}
	dependsOn: [{
		name:      "test"
		namespace: "test"
	}]
}
