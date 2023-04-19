# TODO(jaosorior): Move this image to infratographer
APIHELPER_IMAGE=ghcr.io/infratographer/krakend-endpoints-tool/krakend-endpoints-tool
APIHELPER_IMAGE_TAG?=latest

GATEWAY_IMAGE=ghcr.io/infratographer/api-gateway-image
GATEWAY_IMAGE_TAG?=latest

# This is the default output path for the `aggregate` target.
# It uses `-` by default which means stdout.
DEBUG?=true

KRAKEND_PORT?=8080
SETTINGS_ENV?=dev

# Override the default docker run arguments. this is useful for running the
# commands as a non-root user.
LOCAL_RUN_ARGS?=--userns host -u $(shell id -u):$(shell id -g)

.PHONY: help
help: Makefile ## Print help
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/:.*##/#/' | column -c 2 -t -s#

.PHONY: verify
verify:	## Run lintings and verification on endpoints
	@echo "Verifying the endpoints..."
	@docker run --rm -t \
		-v $(PWD)/endpoints:/endpoints \
		-v $(PWD)/krakendcfg:/etc/krakend/ \
		-e FC_ENABLE=1 \
		-e FC_SETTINGS=/etc/krakend/settings/${SETTINGS_ENV} \
		-e FC_PARTIALS=/etc/krakend/partials \
		$(LOCAL_RUN_ARGS) $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) \
		verify --debug=$(DEBUG) --endpoints /endpoints

.PHONY: aggregate
aggregate: 		## Aggregate the endpoints into a single file
	@echo "Aggregating the endpoints..."
	@docker run --rm -t \
		-v $(PWD):/workdir \
		-v $(PWD)/krakendcfg:/etc/krakend/ \
		-e FC_ENABLE=1 \
		-e FC_SETTINGS=/etc/krakend/settings/${SETTINGS_ENV} \
		-e FC_PARTIALS=/etc/krakend/partials \
		$(LOCAL_RUN_ARGS) $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) \
		aggregate --debug=$(DEBUG) \
		--endpoints /workdir/endpoints \
		--output "/workdir/endpoints.json"

.PHONY: generate
generate:	## Generate the krakend configuration
	@echo "Generating the krakend configuration..."
	@docker run --rm -t \
		-v $(PWD):/workdir \
		-v $(PWD)/krakendcfg:/etc/krakend/ \
		-e FC_ENABLE=1 \
		-e FC_SETTINGS=/etc/krakend/settings/${SETTINGS_ENV} \
		-e FC_PARTIALS=/etc/krakend/partials \
		$(LOCAL_RUN_ARGS) $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) \
		generate --debug=$(DEBUG) \
		--endpoints /workdir/endpoints \
		--config /workdir/krakendcfg/krakend.tmpl \
		--output "/workdir/krakend.tmpl"
	@echo "\n\n* Generated krakend.tmpl"

.PHONY: gateway-image
gateway-image: generate	## Generate the krakend configuration and build the image
	@echo "building API image..."
	@docker build -t $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG) -f Dockerfile .
	@echo "endpoints image available in $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG)"

.PHONY: run-local
run-local: gateway-image ## Build and run local api gateway
	@echo Starting api gateway...
	@docker run --rm \
		-v "$(PWD)/cert:/cert" \
		-e KRAKEND_PORT=${KRAKEND_PORT} \
		-p ${KRAKEND_PORT}:${KRAKEND_PORT} ghcr.io/infratographer/api-gateway-image

.PHONY: dev-verify
dev-verify:  ## Run lintings and verification on endpoints in the devcontainer
	@echo "Verifying the endpoints..."
	@krakend-endpoints-tool verify --debug=$(DEBUG) --endpoints /workspace/endpoints

.PHONY: dev-aggregate
dev-aggregate:  ## Aggregate the endpoints into a single file in the devcontainer
	@echo "Aggregating the endpoints..."
	@krakend-endpoints-tool aggregate --debug=$(DEBUG) \
		--endpoints /workspace/endpoints \
		--output "/workspace/endpoints.json"

.PHONY: dev-generate
dev-generate:  ## Generate the krakend configuration in the devcontainer
	@echo "Generating the krakend configuration..."
	@krakend-endpoints-tool  generate --debug=$(DEBUG) \
		--endpoints /workspace/endpoints \
		--config /workspace/krakendcfg/krakend.tmpl \
		--output "/workspace/krakend.tmpl"
	@echo "\n\n* Generated krakend.tmpl"

.PHONY: dev-run
dev-run:  ## Run the gateway in the devcontainer
	@echo "* Running a local container with the generated configuration..."
	@krakend run -c /workspace/krakend.tmpl
