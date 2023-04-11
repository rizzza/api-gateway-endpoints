FROM ghcr.io/infratographer/porton/porton@sha256:3c292594745624ba316ca3be1cf74142b9cec7e0ab9c5a787e1098418b1d810d

USER root

# Install the configuration file in the expected path
COPY krakend.tmpl /etc/krakend-src/config/krakend.tmpl

RUN chown -R 1000:1000 /etc/krakend-src/config/krakend.tmpl

USER 1000:1000

ENTRYPOINT [ "/usr/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend-src/config/krakend.tmpl" ]