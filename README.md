# Webserver

An Apache webserver image including `mod_auth_openidc` and self-signed certificates that can be overridden with "real" certs by mounting them as volumes.

This image is useful if you would like to protect some web content with an OIDC provider, like [Keycloak](https://www.keycloak.org/). For more information, see [the original repository](https://github.com/zmartzone/mod_auth_openidc).

## Minimal httpd.conf for a keycloak reverse proxy

```
ServerName my.server

Listen 8099

LogLevel debug

LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule headers_module modules/mod_headers.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule unixd_module modules/mod_unixd.so

LoadModule auth_openidc_module /usr/lib/apache2/modules/mod_auth_openidc.so

# OIDC Configuration
OIDCProviderMetadataURL https://my-domain/auth/realms/my-realm/.well-known/openid-configuration
OIDCClientID my-client-id
OIDCClientSecret v3rys3cr3t
OIDCRedirectURI redirect.uri
OIDCCryptoPassphrase sup3rs3cr3t
OIDCScope "openid email profile roles"

# Reverse proxy configuration
ProxyPreserveHost On
ProxyRequests Off
ProxyPass / http://proxy:8089/
ProxyPassReverse / http://proxy:8089/

<Location />
    AuthType openid-connect
    Require valid-user
</Location>
```
