# API Gateway Endpoint Definitions Template

This repository contains the API Gateway endpoint definitions as well as the
configurations to run in the all-in-one image.

These definitions are used to generate the API Gateway configuration for the services. The
[`Dockerfile`](Dockerfile) in this repository is used to build a container image that contains
the krakend configuration and the krakend binary and plugins.

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

In order to locally verify that the endpoint definitions are valid, you can run the following
command:

```bash
make check_generate
```

This will ensure that any endpoints you create within the `krakendcfg/templates` directory are valid.

Finally, if you want to create a container image like the one we ship with the API Gateway, you
can run the following command:

```bash
make gateway-image
```

## Running locally

Some features are only supported by the enterprise version.  You can run locally with a license.  If you
don't have access to a license, you can run without virtual hosting by removing the`--vhost` in the
Makefile `generate` target temporarily. Also, you will need local certificates:

```bash
mkdir cert
openssl req -newkey rsa:2048 -new -nodes -x509 -days 365 -out cert/tls.crt -keyout cert/tls.key \
    -subj "/C=US/ST=California/L=Mountain View/O=Your Organization/OU=Your Unit/CN=localhost"
```

and then you can run with docker:

```bash
docker run \
  -e "KRAKEND_PORT=8080" \
  -v "`pwd`/cert:/cert" \
  -p 8080:8080 -p 8090:8090 -p 9091:9091 \
  ghcr.io/infratographer/api-gateway-image:latest
```
