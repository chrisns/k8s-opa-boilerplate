package simpleRegistryCheck

violation {
	image := input.request.object.spec.containers[_].image
	not startswith(image, "k8s.gcr.io/")
	not startswith(image, "docker.io/")
}
