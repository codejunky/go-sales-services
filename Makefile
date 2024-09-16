# Check to see if we can use ash, in Alpine images, or default BASH
SHELL_PATH = /bin/ash
SHEL = $(if $(wildcard $SHELL_PATH)),/bin/ash,/bin/bash

run:
		go run app/services/sales-api/main.go | go run app/tooling/logfmt/main.go

# ==============================================================================
# Define dependencies

GOLANG          := golang:1.22
ALPINE          := alpine:3.20
KIND            := kindest/node:v1.30.0
POSTGRES        := postgres:16.3
GRAFANA         := grafana/grafana:10.4.0
PROMETHEUS      := prom/prometheus:v2.52.0
TEMPO           := grafana/tempo:2.5.0
LOKI            := grafana/loki:2.9.0
PROMTAIL        := grafana/promtail:2.9.0

KIND_CLUSTER    := ardan-starter-cluster
NAMESPACE       := sales-system
SERVICE_NAME    := sales-api
APP             := sales
# AUTH_APP        := auth
BASE_IMAGE_NAME := ardanlabs/service
VERSION         := 0.0.1
SERVICE_IMAGE   := $(BASE_IMAGE_NAME)/$(SERVICE_NAME):$(VERSION)
METRICS_IMAGE   := $(BASE_IMAGE_NAME)/${SERVICE_NAME}-metrics:$(VERSION)
# AUTH_IMAGE      := $(BASE_IMAGE_NAME)/$(AUTH_APP):$(VERSION)

# ==============================================================================
# Building containers

all: sales

sales:
	docker build \
		-f zarf/docker/dockerfile.service \
		-t $(SERVICE_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		.

# ==============================================================================
# Running from within k8s/kind

dev-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

dev-down:
	kind delete cluster --name ${KIND_CLUSTER}

# ------------------------------------------------------------------------------

dev-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces