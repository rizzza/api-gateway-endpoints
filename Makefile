# TODO(jaosorior): Move this image to infratographer
APIHELPER_IMAGE=ghcr.io/jaormx/krakend-endpoints-tool/krakend-endpoints-tool
APIHELPER_IMAGE_TAG?=latest

GATEWAY_IMAGE=ghcr.io/infratographer/api-gateway-image
GATEWAY_IMAGE_TAG?=latest

# This is the default output path for the `aggregate` target.
# It uses `-` by default which means stdout.
DEBUG?=true

.PHONY: help
help: Makefile ## Print help
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/:.*##/#/' | column -c 2 -t -s#

.PHONY: verify
verify:	## Run lintings and verification on endpoints
	@echo "Verifying the endpoints..."
	@docker run --rm -t -v $(PWD)/endpoints:/endpoints $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) verify --debug=$(DEBUG) --endpoints /endpoints

.PHONY: aggregate
aggregate: 		## Aggregate the endpoints into a single file
	@echo "Aggregating the endpoints..."
	@docker run --rm -t -v $(PWD):/workdir $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) aggregate --debug=$(DEBUG) \
		--vhost \
		--endpoints /workdir/endpoints \
		--output "/workdir/endpoints.json"

.PHONY: generate
generate:	## Generate the krakend configuration
	@echo "Generating the krakend configuration..."
	@docker run --rm -t -v $(PWD):/workdir $(APIHELPER_IMAGE):$(APIHELPER_IMAGE_TAG) generate --debug=$(DEBUG) \
		--vhost \
		--endpoints /workdir/endpoints \
		--config /workdir/krakendcfg/krakend.tmpl \
		--output "/workdir/krakend.tmpl"
	@echo "\n\n* Generated krakend.tmpl"

.PHONY: gateway-image
gateway-image: generate	## Generate the krakend configuration and build the image
	@echo "building API image..."
	@docker build -t $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG) -f Dockerfile .
	@echo "endpoints image available in $(GATEWAY_IMAGE):$(GATEWAY_IMAGE_TAG)"
