#!/usr/bin/env bash
# Deploy OTel observability stack to the central (ghost) node.
# Usage: ./deploy.sh jorge@192.168.1.102
set -euo pipefail

HOST=${1:?usage: deploy.sh user@host}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_DIR="/var/home/jorge/bluespeed/otel"
IP=$(echo "$HOST" | cut -d@ -f2)

echo "→ Creating remote directories..."
ssh "$HOST" "mkdir -p ${REMOTE_DIR}/{loki-data,prometheus-data} && chmod 777 ${REMOTE_DIR}/{loki-data,prometheus-data}"

echo "→ Copying configs..."
scp "${SCRIPT_DIR}/ghost/config/otelcol-config.yaml" "${HOST}:${REMOTE_DIR}/config/"
scp "${SCRIPT_DIR}/ghost/config/loki-config.yaml"    "${HOST}:${REMOTE_DIR}/config/"
scp "${SCRIPT_DIR}/ghost/config/prometheus.yml"       "${HOST}:${REMOTE_DIR}/config/"

echo "→ Installing Quadlets..."
ssh "$HOST" "mkdir -p ~/.config/containers/systemd"
scp "${SCRIPT_DIR}/ghost/quadlets/observability.network" "${HOST}:~/.config/containers/systemd/"
scp "${SCRIPT_DIR}/ghost/quadlets/loki.container"        "${HOST}:~/.config/containers/systemd/"
scp "${SCRIPT_DIR}/ghost/quadlets/prometheus.container"  "${HOST}:~/.config/containers/systemd/"
scp "${SCRIPT_DIR}/ghost/quadlets/otelcol.container"     "${HOST}:~/.config/containers/systemd/"

echo "→ Reloading systemd..."
ssh "$HOST" "systemctl --user daemon-reload"

echo "→ Starting services (in order)..."
ssh "$HOST" "
  systemctl --user start loki.service && sleep 5
  systemctl --user start prometheus.service && sleep 5
  systemctl --user start otelcol.service && sleep 8
"

echo "→ Waiting for services to be ready (30s)..."
sleep 30

echo "→ Verifying health..."
curl -sf "http://${IP}:3100/ready"  > /dev/null && echo "  ✅ Loki ready"       || echo "  ⚠️  Loki not yet ready — check: ssh ${HOST} journalctl --user -u loki -n 20"
curl -sf "http://${IP}:9090/-/ready" > /dev/null && echo "  ✅ Prometheus ready" || echo "  ⚠️  Prometheus not yet ready"
curl -sf "http://${IP}:8888/metrics" > /dev/null && echo "  ✅ OTel Collector ready" || echo "  ⚠️  OTel Collector not yet ready"
echo ""
echo "✅ Observability stack deployed to ${IP}"
echo ""
echo "   KubeStellar Console (dashboards): http://${IP}:8090"
echo "   Prometheus (metrics): http://${IP}:9090"
echo "   Loki (logs):         http://${IP}:3100"
