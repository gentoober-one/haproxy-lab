#!/bin/sh
set -e

echo "Iniciando HAProxy..."
haproxy -f /etc/haproxy/haproxy.cfg & 
HAPROXY_PID=$! 

echo "Aguardando HAProxy iniciar..."

sleep 2

echo "Iniciando Keepalived..."
# Inicia o Keepalived em primeiro plano.
# O '-n' impede que ele se torne um daemon, mantendo o contêiner em execução.
# O '--log-console' envia logs para o stdout/stderr do contêiner.
# O '--debug' para logs ainda mais detalhados (se os outros não forem suficientes).
exec keepalived --dont-fork --log-console --log-detail --vrrp -f /etc/keepalived/keepalived.conf

# wait $HAPROXY_PID
