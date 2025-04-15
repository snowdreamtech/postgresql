FROM snowdreamtech/debian:12.10.0

# OCI annotations to image
LABEL org.opencontainers.image.authors="Snowdream Tech" \
    org.opencontainers.image.title="PostgreSQL Image Based On Debian" \
    org.opencontainers.image.description="Docker Images for PostgreSQL on Debian. (i386,amd64,arm32v5,arm32v7,arm64,mips64le,ppc64le,s390x)" \
    org.opencontainers.image.documentation="https://hub.docker.com/r/snowdreamtech/postgresql" \
    org.opencontainers.image.base.name="snowdreamtech/postgresql:debian" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/snowdreamtech/postgresql" \
    org.opencontainers.image.vendor="Snowdream Tech" \
    org.opencontainers.image.version="15.10.0" \
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

ENV POSTGRES_VERSION=15.10-0+deb12u1 \
    POSTGRES_PORT=5432 \
    POSTGRES_MAX_CONNECTIONS=100 \
    POSTGRES_ROOT_PASSWORD="" \
    POSTGRES_USER='' \
    POSTGRES_PASSWORD='' \
    POSTGRES_DB='' \
    POSTGRES_HOST_AUTH_METHOD='scram-sha-256'  \
    POSTGRES_DISALLOW_USER_LOGIN_REMOTELY=1

ENV PATH=${PATH}:/lib/rc/bin:/lib/rc/sbin

ARG GID=1000 \
    UID=1000  \
    USER=postgres \
    WORKDIR=/var/lib/postgresql

# Create a user with UID and GID
RUN set -eux \
    && if [ "${USER}" != "root" ]; then \
    addgroup --gid ${GID} ${USER}; \
    adduser --home ${WORKDIR} --uid ${UID} --gid ${GID} --gecos ${USER} --shell /bin/bash --disabled-password ${USER}; \
    # sed -i "/%sudo/c ${USER} ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers; \
    fi \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy --purge autoremove \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* 

# Enable CAP_NET_BIND_SERVICE
RUN set -eux \
    && if [ "${USER}" != "root" ] && [ "${CAP_NET_BIND_SERVICE}" -eq 1 ]; then \
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update; \
    DEBIAN_FRONTEND=noninteractive apt-get -qqy install --no-install-recommends libcap2-bin; \
    # setcap 'cap_net_bind_service=+ep' `which nginx`; \
    fi \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy --purge autoremove \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* 

RUN set -eux \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy update  \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy install --no-install-recommends \ 
    postgresql-15=${POSTGRES_VERSION}  \
    postgresql-client-15=${POSTGRES_VERSION} \
    postgresql-contrib \
    # Chown the files to USER
    && find /etc  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    # && chown -Rv ${USER}:${USER} clusterdb createdb createlang createuser dropdb dropuser droplang pgbench psql reindexdb vacuumdb vacuumlo \
    && find /usr/bin  -name "pg_*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /usr/lib  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /usr/share  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/log  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/lib  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/cache  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /var/run  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    && find /run  -name "*postgresql*" -exec chown -Rv ${USER}:${USER} {} \; \
    # && ls -l /usr/share/postgresql-common | awk '{print $9}'| xargs -I {} chown -Rfv ${USER}:${USER} /usr/bin/{} \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy --purge autoremove \
    && DEBIAN_FRONTEND=noninteractive apt-get -qqy clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Switch to the user
USER root
# USER ${USER}

# Set the workdir
WORKDIR ${WORKDIR}

COPY --chown=${USER}:${USER} docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]