# appserver1/Dockerfile e appserver2/Dockerfile
FROM httpd:2.4

COPY index.html /usr/local/apache2/htdocs/index.html

# Não há necessidade de configurar SSL aqui, pois o HAProxy cuidará disso.
