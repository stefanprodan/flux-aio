package main

import (
	"tool/cli"
	"tool/exec"
	"encoding/yaml"
	"text/tabwriter"
)

command: gen: {
	task: print: cli.Print & {
		text: yaml.MarshalStream([ for x in resources {x}])
	}
}

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"RESOURCE \tAPI VERSION",
			for r in resources {
				if r.metadata.namespace == _|_ {
					"\(r.kind)/\(r.metadata.name) \t\(r.apiVersion)"
				}
				if r.metadata.namespace != _|_ {
					"\(r.kind)/\(r.metadata.namespace)/\(r.metadata.name)  \t\(r.apiVersion)"
				}
			},
		])
	}
}

command: install: {
	apply: exec.Run & {
		stdin: yaml.MarshalStream([ for r in resources {r}])
		cmd: [
			"kubectl",
			"apply",
			"--server-side",
			"-f-",
		]
	}
	wait: exec.Run & {
		$after: apply
		cmd: [
			"kubectl",
			"-n=flux-system",
			"rollout",
			"status",
			"deployment",
			"flux",
			"--timeout=90s",
		]
	}
}
