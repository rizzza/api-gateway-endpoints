FROM ghcr.io/infratographer/porton/porton@sha256:8bf86abdc150c5bd33d1d61a4e3add236eb731b5e417ec5098bafe9c2fa239b8

USER root

# Install the configuration file in the expected path
COPY krakendcfg/krakend.tmpl /etc/krakend-src/config/krakend.tmpl

RUN chown -R 1000:1000 /etc/krakend-src/config/krakend.tmpl

USER 1000:1000

# required flexible configuration to enable yaml
ENV FC_OUT=/tmp/krakend.yml

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend-src/config/krakend.tmpl" ]
