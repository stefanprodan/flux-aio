bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-tenants"
	instances: {
		"dev-team": {
			module: {
				url: "oci://ghcr.io/stefanprodan/modules/flux-tenant" @timoni(runtime:string:FLUX_TENANT_MODULE_URL)
			}
			namespace: "dev-team-apps"
			values: role: "namespace-admin"
		}
		"podinfo-ks-oci": {
			module: {
				url: "oci://ghcr.io/stefanprodan/modules/flux-oci-sync" @timoni(runtime:string:FLUX_OCI_MODULE_URL)
			}
			namespace: "dev-team-apps"
			values: {
				artifact: {
					url:    "oci://ghcr.io/stefanprodan/manifests/podinfo"
					semver: ">=1.0.0"
				}
				sync: {
					serviceAccountName: "flux"
					targetNamespace:    namespace
					wait:               true
				}
			}
		}
		"podinfo-hr": {
			module: {
				url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release" @timoni(runtime:string:FLUX_HR_MODULE_URL)
			}
			namespace: "dev-team-apps"
			values: {
				repository: url: "https://stefanprodan.github.io/podinfo"
				chart: name:     "podinfo"
				sync: {
					serviceAccountName: "flux"
					retries:            1
				}
				helmValues: {
					replicaCount: 2
					resources: requests: {
						cpu:    "100m"
						memory: "32Mi"
					}
					hpa: {
						enabled: true
						cpu:     99
					}
				}
			}
		}
		"podinfo-hr-oci": {
			module: {
				url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release" @timoni(runtime:string:FLUX_HR_MODULE_URL)
			}
			namespace: "dev-team-apps"
			values: {
				repository: url:          "oci://ghcr.io/stefanprodan/charts"
				chart: name:              "podinfo"
				sync: serviceAccountName: "flux"
				helmValues: replicaCount: 2
			}
		}
	}
}
