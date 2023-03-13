FROM ghcr.io/infratographer/porton/porton@sha256:2f3beaad98c6083ce950ffd69a32ce065fb57f32f6f1cbd13de26fc636f776b9

# Install the configuration file in the expected path
COPY krakend.tmpl /etc/krakend-src/config/krakend.tmpl

RUN chown -R 1000:1000 /etc/krakend-src/config/krakend.tmpl

USER 1000:1000

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend-src/config/krakend.tmpl" ]