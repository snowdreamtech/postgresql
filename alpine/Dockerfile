FROM snowdreamtech/alpine:3.21.3

# OCI annotations to image
LABEL org.opencontainers.image.authors="Snowdream Tech" \
    org.opencontainers.image.title="PostgreSQL Image Based On Alpine" \
    org.opencontainers.image.description="Docker Images for PostgreSQL on Alpine. (i386, amd64, arm32v6, arm32v7, arm64, ppc64le,riscv64, s390x)" \
    org.opencontainers.image.documentation="https://hub.docker.com/r/snowdreamtech/postgresql" \
    org.opencontainers.image.base.name="snowdreamtech/postgresql:alpine" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/snowdreamtech/postgresql" \
    org.opencontainers.image.vendor="Snowdream Tech" \
    org.opencontainers.image.version="15.12.0" \
    org.opencontainers.image.url="https://github.com/snowdreamtech/postgresql"

# Switch to the user
USER root

# Set the workdir
WORKDIR /root

# keep the docker container running
ENV KEEPALIVE=1 \
    # The cap_net_bind_service capability in Linux allows a process to bind a socket to Internet domain privileged ports, 
    # which are port numbers less than 1024. 
    CAP_NET_BIND_SERVICE=0 

ENV POSTGRES_VERSION=15.12-r0 \
    POSTGRES_PORT=5432 \
    POSTGRES_MAX_CONNECTIONS=100 \
    POSTGRES_ROOT_PASSWORD="" \
    POSTGRES_USER='' \
    POSTGRES_PASSWORD='' \
    POSTGRES_DB='' \
    POSTGRES_HOST_AUTH_METHOD='scram-sha-256'  \
    POSTGRES_DISALLOW_USER_LOGIN_REMOTELY=1

ENV PATH=${PATH}:/usr/libexec/rc/bin:/usr/libexec/rc/sbin

ARG GID=1000 \
    UID=1000  \
    USER=postgres \
    WORKDIR=/var/lib/postgresql

# Create a user with UID and GID
RUN if [ "${USER}" != "root" ]; then \
    addgroup -g ${GID} ${USER}; \
    adduser -h ${WORKDIR} -u ${UID} -g ${USER} -G ${USER} -s /bin/sh -D ${USER}; \
    # sed -i "/%sudo/c ${USER} ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers; \
    fi

# Enable CAP_NET_BIND_SERVICE
RUN if [ "${USER}" != "root" ] && [ "${CAP_NET_BIND_SERVICE}" -eq 1 ]; then \
    apk add --no-cache libcap; \
    # setcap 'cap_net_bind_service=+ep' `which nginx`; \
    fi

RUN apk add --no-cache \
    openrc \
    postgresql15=${POSTGRES_VERSION}  \
    postgresql15-client=${POSTGRES_VERSION} \
    postgresql15-contrib=${POSTGRES_VERSION} \
    # touch /tmp/service_values 
    && touch /tmp/service_values \
    # Chown the files to USER
    && find /etc  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /usr/lib  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /usr/share  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /usr/libexec  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/log  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/lib  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && ls -l /usr/libexec/postgresql/ | awk '{print $9}'| xargs -I {} chown -Rfv ${USER}:${USER} /usr/bin/{}


# Switch to the user
USER root
# USER ${USER}

# Set the workdir
WORKDIR ${WORKDIR}

COPY --chown=${USER}:${USER} docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]