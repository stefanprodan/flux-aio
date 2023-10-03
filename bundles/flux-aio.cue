bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-aio" @timoni(runtime:string:FLUX_MODULE_URL)
				version: "latest"
			}
			namespace: "flux-system"
			values: {
				hostNetwork:     true
				securityProfile: "privileged"
			}
		}
		"cluster-addons": {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-git-sync" @timoni(runtime:string:FLUX_SYNC_MODULE_URL)
				version: "latest"
			}
			namespace: "flux-system"
			values: git: {
				url:  "https://github.com/stefanprodan/flux-aio"
				ref:  "refs/head/main" @timoni(runtime:string:FLUX_SYNC_REF)
				path: "./test/cluster-addons"
			}
		}
	}
}
