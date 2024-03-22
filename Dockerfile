FROM httpd:2.4.58

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates libapache2-mod-auth-openidc
