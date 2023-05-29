bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		flux: {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-aio"
				version: "2.0.0-rc.4"
			}
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "restricted"
			}
		}
	}
}
