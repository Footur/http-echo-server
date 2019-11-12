FROM oracle/graalvm-ce:19.2.1 as builder

COPY target/http-echo-server.jar /http-echo-server.jar
RUN gu install native-image
RUN native-image -jar /http-echo-server.jar
RUN mkdir -p /tmp/ssl-libs/lib \
  && cp $JAVA_HOME/jre/lib/security/cacerts /tmp/ssl-libs \
  && cp $JAVA_HOME/jre/lib/amd64/libsunec.so /tmp/ssl-libs/lib/



FROM frolvlad/alpine-glibc:glibc-2.30

ARG TAG=latest
ENV TAG=$TAG
COPY --from=builder /tmp/ssl-libs/ /opt/
COPY --from=builder /echo-server /echo-server
COPY start.sh /start.sh
RUN chmod 777 /start.sh

LABEL org.label-schema.schema-version="1.0.0"
LABEL org.label-schema.name="http-echo-server"
LABEL org.label-schema.description="Simple HTTP server that echoes whatever it receives"
LABEL org.label-schema.url="https://github.com/kosprov/http-echo-server"
LABEL org.label-schema.vcs-url="https://github.com/kosprov/http-echo-server"
LABEL org.label-schema.vendor="Kos Prov (kosprov@gmail.com)"
LABEL org.label-schema.version="${TAG}"
LABEL org.label-schema.docker.cmd="docker run --rm -it -e PORT=3000 -p 3000:3000 kosprov/http-echo-server"
LABEL org.label-schema.docker.cmd.help="docker run --rm kosprov/http-echo-server --help"

EXPOSE 3000/tcp
ENTRYPOINT ["/start.sh"]