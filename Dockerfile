# TODO: Add renovate configuration that will track GitHub releases
# The intent is to use release tags instead of commit hashes
FROM ghcr.io/infratographer/porton/porton:latest

# Install the configuration file in the expected path
COPY krakend.tmpl /etc/krakend-src/config/krakend.tmpl

RUN chown -R 1000:1000 /etc/krakend-src/config/krakend.tmpl

USER 1000:1000

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend-src/config/krakend.tmpl" ]