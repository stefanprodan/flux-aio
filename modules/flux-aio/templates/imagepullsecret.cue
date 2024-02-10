package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#PullSecret: timoniv1.#ImagePullSecret & {
	#config:   #Config
	#Meta:     #config.metadata
	#Suffix:   "-image-pull"
	#Registry: #config.imagePullSecret.registry
	#Username: #config.imagePullSecret.username
	#Password: #config.imagePullSecret.password
}
