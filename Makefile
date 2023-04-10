GATEWAY_IMAGE=ghcr.io/infratographer/api-gateway-image
GATEWAY_IMAGE_TAG?=latest

# This is the default output path for the `aggregate` target.
# It uses `-` by default which means stdout.
DEBUG?=true

# Override the default docker run arguments. this is useful for running the
# commands as a non-root user.
LOCAL_RUN_ARGS?=--userns host -u $(shell id -u):$(shell id -g)

.PHONY: help
help: Makefile ## Print help
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/:.*##/#/' | column -c 2 -t -s#

.PHONY:
check_generate:	## Run lintings and verification on endpoints
	@echo "Verifying the endpoints and config"
	@docker run \
		--rm -t \
		-v $(PWD)/krakendcfg:/etc/krakend/ \
		-e FC_ENABLE=1 -e KRAKEND_PORT=8888 \
		-e FC_SETTINGS=/etc/krakend/settings \
		-e FC_PARTIALS=/etc/krakend/partials \
		-e FC_TEMPLATES=/etc/krakend/templates \
		-e FC_OUT=krakend.yml \
		devopsfaith/krakend check -dtc krakend.tmpl

.PHONY: gateway-image
gateway-image: check_generate	## Generate the krakend configuration and build the image
	@echo "building API image..."
	@docker build -t $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG) -f Dockerfile .
	@echo "endpoints image available in $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG)"
