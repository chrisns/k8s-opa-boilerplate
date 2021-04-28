#!/bin/sh

kubectl kustomize . > $(dirname "$0")/expected.yaml