#!/bin/sh

kubectl kustomize . | diff -  $(dirname "$0")/expected.yaml