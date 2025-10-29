@if(debug)

package main

// Values used by debug_tool.cue.
// Eval example:
// cue -t debug -t name=flux -t namespace=flux-system -t mv=2.0.0 -t kv=1.28.0 eval -c -e timoni.instance.objects.deployment
values: {
	version: "v2.7.3"
	controllers: {
		source: {
			image: {
				repository: "ghcr.io/fluxcd/source-controller"
				tag:        "v1.7.3"
				digest:     ""
			}
			resources: {
				requests: {
					cpu:    "150m"
					memory: "128Mi"
				}
				limits: {
					cpu:    "1000m"
					memory: "1Gi"
				}
			}
			featureGates: "ObjectLevelWorkloadIdentity=true"
		}
		kustomize: {
			image: {
				repository: "ghcr.io/fluxcd/kustomize-controller"
				tag:        "v1.7.2"
				digest:     ""
			}
			resources: limits: {
				cpu:    "2000m"
				memory: "1Gi"
			}
		}
		notification: {
			image: {
				repository: "ghcr.io/fluxcd/notification-controller"
				tag:        "v1.7.4"
				digest:     ""
			}
			resources: limits: {
				cpu:    "1000m"
				memory: "500Mi"
			}
			featureGates: "ObjectLevelWorkloadIdentity=true"
		}
		helm: {
			image: {
				repository: "ghcr.io/fluxcd/helm-controller"
				tag:        "v1.4.3"
				digest:     ""
			}
			resources: limits: {
				cpu:    "2000m"
				memory: "1Gi"
			}
			featureGates: "DisableChartDigestTracking=true,OOMWatch=true,ExternalArtifact=true"
		}
		watcher: {
			image: {
				repository: "ghcr.io/fluxcd/source-watcher"
				tag:        "v2.0.2"
			}
		}
	}
	workload: {
		identity: "arn:aws:iam::111122223333:role/my-role"
		provider: "aws"
	}
	hostNetwork:        true
	podSecurityProfile: "privileged"
	securityProfile:    "privileged"
	resources: {
		requests: {
			cpu:    "250m"
			memory: "512Mi"
		}
		limits: {
			cpu:    "250m"
			memory: "512Mi"
		}
	}
	expose: {
		webhookReceiver:    true
		notificationServer: true
		sourceServer:       true
	}
	persistence: enabled: true
	proxy: http:          "http://my.proxy"
	env: {
		"TEST_KEY1": "VAL1"
		"TEST_KEY2": "VAL2"
	}
	tolerations: [{
		operator: "Exists"
		key:      ""
	}]
	imagePullSecret: {
		registry: "ghcr.io"
		username: "flux"
		password: "test"
	}
}
