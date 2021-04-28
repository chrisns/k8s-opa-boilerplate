# Boiler plate example of managing OPA with kustomize

[![Test the boilerplate](https://github.com/chrisns/k8s-opa-boilerplate/actions/workflows/test-the-boilerplate.yml/badge.svg)](https://github.com/chrisns/k8s-opa-boilerplate/actions/workflows/test-the-boilerplate.yml)
[![Test the rego](https://github.com/chrisns/k8s-opa-boilerplate/actions/workflows/test-the-rego.yml/badge.svg)](https://github.com/chrisns/k8s-opa-boilerplate/actions/workflows/test-the-rego.yml)

## Motivation

I wanted a boilerplate to help me write [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website) policy documents in [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/).

I'm a developer that cares about testing, and general code quality so to achieve that its important to seperate the Rego from being embedded in the yaml like much of the [official documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/howto) 😭

I also like simplicity and sticking with vanilla tooling so rather than using the kustomize generator custom generator plugin approach I've opted for a pretty hacky stringing together of yaml to get the Rego embedded in to the `Kind: ConstraintTemplate`. Hopefully something will emerge with kustomize that allows for piping in files like how the SecretGenerator and ConfigMapGenerator work. The annoying side effect is that you end up with a pointless `ConfigMap`, you could putt his in a separate namespace to be sure it won't pollute things.

I've included a test for the yaml to assert that works consistently.

## Usage

### Local testing

I've tested this with this: (I found it was handy to prepend with `watch -n 0.5` while I was coding)

```bash
$ opa test *.rego -v --explain full
data.simpleRegistryCheck_test.test_mix_of_good_and_bad_images: PASS (1.025336ms)
data.simpleRegistryCheck_test.test_bad_images: PASS (186.052µs)
data.simpleRegistryCheck_test.test_good_image_no_violation: PASS (163.964µs)
data.simpleRegistryCheck_test.test_good_images_no_violation: PASS (256.612µs)
--------------------------------------------------------------------------------
PASS: 4/4
```

### Automated testing / CI

Tests and coverage are monitored with a [github action](./.github/workflows/test-the-rego.yaml)

### Example compilation of Kubernetes resources

```bash
$ kubectl apply --dry-run=client -k . -o yaml
apiVersion: v1
items:
- apiVersion: v1
  data:
    myrego: "package simpleRegistryCheck\n\nviolation {\n\timage := input.request.object.spec.containers[_].image\n\tnot
      startswith(image, \"k8s.gcr.io/\")\n\tnot startswith(image, \"docker.io/\")\n}\n"
  kind: ConfigMap
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","data":{"myrego":"package simpleRegistryCheck\n\nviolation {\n\timage := input.request.object.spec.containers[_].image\n\tnot startswith(image, \"k8s.gcr.io/\")\n\tnot startswith(image, \"docker.io/\")\n}\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"myrego-dk457tft5k","namespace":"magicmirror"}}
    name: myrego-dk457tft5k
    namespace: magicmirror
- apiVersion: templates.gatekeeper.sh/v1beta1
  kind: ConstraintTemplate
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"templates.gatekeeper.sh/v1beta1","kind":"ConstraintTemplate","metadata":{"annotations":{},"name":"k8strustedimages"},"spec":{"crd":{"spec":{"names":{"kind":"K8sTrustedImages"}}},"targets":[{"rego":"package simpleRegistryCheck\n\nviolation {\n\timage := input.request.object.spec.containers[_].image\n\tnot startswith(image, \"k8s.gcr.io/\")\n\tnot startswith(image, \"docker.io/\")\n}\n","target":"admission.k8s.gatekeeper.sh"}]}}
    name: k8strustedimages
  spec:
    crd:
      spec:
        names:
          kind: K8sTrustedImages
    targets:
    - rego: "package simpleRegistryCheck\n\nviolation {\n\timage := input.request.object.spec.containers[_].image\n\tnot
        startswith(image, \"k8s.gcr.io/\")\n\tnot startswith(image, \"docker.io/\")\n}\n"
      target: admission.k8s.gatekeeper.sh
kind: List
metadata: {}
```
