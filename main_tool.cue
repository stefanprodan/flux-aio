package main

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"encoding/yaml"
	"text/tabwriter"
)

command: gen: {
	task: print: cli.Print & {
		text: yaml.MarshalStream([ for x in aio.resources {x}])
	}
}

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"RESOURCE \tAPI VERSION",
			for r in aio.resources {
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
		stdin: yaml.MarshalStream([ for r in aio.resources {r}])
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

command: publish: {
	mkdir: file.MkdirAll & {
		path: "dist"
	}
	build: file.Create & {
		$after:   mkdir
		filename: "dist/aio.yaml"
		contents: yaml.MarshalStream([ for r in aio.resources {r}])
	}
	push: exec.Run & {
		$after: build
		cmd: [
			"flux",
			"push",
			"artifact",
			"oci://\(auto.spec.image):\(aio.spec.version)",
			"--path=./dist",
			"--source=https://github.com/fluxcd/flux2",
			"--revision=\(aio.spec.version)",
		]
	}
}

command: automate: {
	apply: exec.Run & {
		stdin: yaml.MarshalStream([ for r in auto.resources {r}])
		cmd: [
			"kubectl",
			"apply",
			"--server-side",
			"-f-",
		]
	}
	waitSync: exec.Run & {
		$after: apply
		cmd: [
			"kubectl",
			"-n=\(auto.spec.namespace)",
			"wait",
			"ks",
			"\(auto.spec.name)-sync",
			"--for=condition=ready",
			"--timeout=90s",
		]
	}
}

command: deautomate: {
	suspend: exec.Run & {
		cmd: [
			"flux",
			"suspend",
			"kustomization",
			"\(auto.spec.name)-sync",
		]
	}
	delete: exec.Run & {
		$after: suspend
		cmd: [
			"flux",
			"delete",
			"kustomization",
			"\(auto.spec.name)-sync",
			"--silent",
		]
	}
	deleteSource: exec.Run & {
		$after: suspend
		cmd: [
			"flux",
			"delete",
			"source",
			"oci",
			"\(auto.spec.name)-source",
			"--silent",
		]
	}
}
