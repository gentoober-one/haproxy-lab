# waf/Dockerfile
FROM owasp/modsecurity-crs:nginx

# Copia a configuração customizada do Nginx
COPY default.conf /etc/nginx/conf.d/custom.conf

# Copia apenas o unicode.mapping (não sobrescreve modsecurity.conf)
COPY unicode.mapping /etc/nginx/modsecurity.d/unicode.mapping

USER root
RUN chown -R nginx:nginx /etc/nginx/modsecurity.d
USER nginx

EXPOSE 80
