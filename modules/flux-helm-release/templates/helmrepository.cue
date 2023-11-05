package templates

import (
	"strings"

	fluxv1 "source.toolkit.fluxcd.io/helmrepository/v1beta2"
)

#HelmRepository: fluxv1.#HelmRepository & {
	_config:  #Config
	metadata: _config.metadata
	spec:     fluxv1.#HelmRepositorySpec & {
		interval: "12h"
		url:      _config.repository.url
		if strings.HasPrefix(_config.repository.url, "oci") {
			type: "oci"
		}
	}
}
