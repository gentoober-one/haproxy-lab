#!/bin/sh
set -e

echo "Iniciando HAProxy..."
haproxy -f /etc/haproxy/haproxy.cfg & 
HAPROXY_PID=$! 

echo "Aguardando HAProxy iniciar..."

sleep 2

echo "Iniciando Keepalived..."
exec keepalived --dont-fork --log-console --log-detail --vrrp -f /etc/keepalived/keepalived.conf

# wait $HAPROXY_PID
