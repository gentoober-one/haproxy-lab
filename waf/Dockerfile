FROM owasp/modsecurity-crs:nginx

COPY default.conf /etc/nginx/conf.d/custom.conf

COPY unicode.mapping /etc/nginx/modsecurity.d/unicode.mapping

USER root
RUN chown -R nginx:nginx /etc/nginx/modsecurity.d
USER nginx

EXPOSE 80
