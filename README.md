# Infratographer API Gateway Endpoint Definitions Template

This repo contains the api-gateway and endpoint tempalte definitions for infratographer. This is the API that all infratographer eco systems tools are being built against.

These definitions are used to generate the API Gateway configuration for the services. The
[`Dockerfile`](Dockerfile) in this repository is used to build a container image that contains
the krakend configuration and the krakend binary and plugins.

The goal is to provide an easy way for end users to add additional endpoints for custom components as well as replace infratographer provided components with components that provide the same API interfaces.

## Usage

### Adding endpoints

All the definitions are in the `krakendcfg/templates` directory. Once you create your endpoint file, add it's reference to the `krakendcfg/templates/_endpoints.tmpl` file. The format of the files follows the
[Lura](https://luraproject.org/) [endpoint configuration format](https://www.krakend.io/docs/endpoints/).
Specifically, each file may be a single endpoint definition or an array of endpoint definitions.

The name of the file should be the name of the endpoint.

The file in `krakendcfg/templates/loadbalancer_api_v1.tmpl` serves as an example.

## Distribution

Endpoints are aggregated and set up in a complete krakend configuration. The base
of the krakend configuration is available in the
[`krakend.tmpl`](krakendcfg/krakend.tmpl) file. The configuration is then
embedded and distributed as a container image that also contains the API
Gateway binary and plugins.

The resulting image is `ghcr.io/infratographer/api-gateway-image`.

## Testing

Note that `docker` is required to run verifications and the tests.

In order to locally verify that the endpoint definitions and config are valid, you can run the following
command:

```bash
make check
```

Finally, if you want to create a container image like the one we ship with the API Gateway, you
can run the following command:

```bash
make gateway-image
```

## Running locally

```bash
make run-local
```

### Dev container

```bash
make dev-run
```
