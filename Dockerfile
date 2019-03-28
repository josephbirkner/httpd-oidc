FROM httpd:2.4
LABEL maintainer "Nico Bellack <nico.bellack@daqana.com>"

ARG MOD_AUTH_OPENIDC_VERSION=2.3.11

RUN \
    BUILD_DEPS="\
        apache2-bin \
        ca-certificates \
        curl \
        libcjose0 \
        libhiredis0.13 \
        libjansson4" \
    && MOD_AUTH_OPENIDC_URL=https://github.com/zmartzone/mod_auth_openidc/releases/download/v"$MOD_AUTH_OPENIDC_VERSION"/libapache2-mod-auth-openidc_"$MOD_AUTH_OPENIDC_VERSION"-1.stretch+1_amd64.deb \
    && apt update \
    && apt install -y --no-install-recommends \
        $BUILD_DEPS \
    && rm -r /var/lib/apt/lists/* \
    && curl --location "$MOD_AUTH_OPENIDC_URL" -o /tmp/mod_auth_openidc.deb \
    && dpkg -i /tmp/mod_auth_openidc.deb \
    && ln -s /usr/lib/apache2/modules/mod_auth_openidc.so /usr/local/apache2/modules/mod_auth_openidc.so \
    && apt purge -y --auto-remove \
        $BUILD_DEPS \
    && apt clean \
    && rm -rf \
        /tmp/* \
        /var/log/dpkg.log \
        /var/log/alternatives.log \
        /var/log/apt \
        /var/lib/apt/lists/*

COPY self-signed.crt /usr/local/apache2/conf/server.crt
COPY self-signed.crt /usr/local/apache2/conf/server-ca.crt
COPY self-signed.key /usr/local/apache2/conf/server.key