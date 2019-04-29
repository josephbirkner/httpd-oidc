# Webserver

An Apache webserver image including `mod_auth_openidc` and self-signed certificates that can be overridden with "real" certs by mounting them as volumes.

This image is useful if you would like to protect some web content with an OIDC provider, like [Keycloak](https://www.keycloak.org/). For more information, see [the original repository](https://github.com/zmartzone/mod_auth_openidc).

## How To

1. Pull the image from DockerHub:
    ```
    docker pull bellackn/httpd_oidc
    ```
2. Adapt the configuration file to your needs. For example, you could do the following:
    ```
    docker run --rm -d --name foo bellackn/httpd_oidc
    docker cp foo:/usr/local/apache2/conf/httpd.conf httpd.conf
    docker stop foo
    nano httpd.conf
    ```
    (same applies to the SSL config file at `/usr/local/apache2/conf/extra/httpd-ssl.conf`)
3. Optional: Get some real SSL certificates, e.g. from [Let's Encrypt](https://letsencrypt.org/), and mount them into the container to replace the self-signed ones.
4. Optional: You can either hardcode the variables that `mod_auth_openidc` needs for authentication in your config files, or you could mount them into the container as an `.env` file (see example below).

## Example Setup with Docker Compose and Keycloak

If you want to serve some content under `/someuri` and protect it with your Keycloak instance, this is a way you could do it.

docker-compose.yml:
```
version: "3.7"

services:

    web:
        image: bellackn/httpd_oidc
        restart: always
        env_file: .env
        ports:
            - "80:80"
            - "443:443"
        volumes:
            - ./httpd.conf:/usr/local/apache2/conf/httpd.conf
            - ./httpd-ssl.conf:/usr/local/apache2/conf/extra/httpd-ssl.conf
```

.env:
```
OIDC_PROVIDER=http://your.keycloak/auth/realms/
OIDC_REALM=realm
OIDC_CRYPT=much-s3cr3t
OIDC_CLIENT=testing
OIDC_SECRET=v3ry-l0ng-s3cr3t
```

httpd.conf:
```
[...]

<IfModule auth_openidc_module>
    OIDCProviderIssuer ${OIDC_PROVIDER}${OIDC_REALM}
    OIDCProviderAuthorizationEndpoint ${OIDC_PROVIDER}${OIDC_REALM}/protocol/openid-connect/auth
    OIDCProviderJwksUri ${OIDC_PROVIDER}${OIDC_REALM}/protocol/openid-connect/certs
    OIDCProviderTokenEndpoint ${OIDC_PROVIDER}${OIDC_REALM}/protocol/openid-connect/token
    OIDCProviderUserInfoEndpoint ${OIDC_PROVIDER}${OIDC_REALM}/protocol/openid-connect/userinfo
    OIDCSSLValidateServer Off
    OIDCRedirectURI http://${SERVER_NAME}/someuri/redirect_uri
    OIDCCryptoPassphrase ${OIDC_CRYPT}
    OIDCClientID ${OIDC_CLIENT}
    OIDCClientSecret ${OIDC_SECRET}
    OIDCRemoteUserClaim preferred_username
    OIDCInfoHook userinfo
</IfModule>

[...]
```

httpd-ssl.conf:
```
[...]

Alias /someuri "/usr/local/apache2/htdocs/someuri"

<Location /someuri>
    AuthType openid-connect
    Require valid-user
</Location>

[...]
```