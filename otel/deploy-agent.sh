#!/usr/bin/env bash
# Deploy OTel Collector agent to a node.
# Usage: ./deploy-agent.sh jorge@192.168.1.247
set -euo pipefail

HOST=${1:?usage: deploy-agent.sh user@host}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Installing agent config..."
ssh "$HOST" "sudo mkdir -p /etc/otelcol"
scp "${SCRIPT_DIR}/agent/otelcol-agent-config.yaml" "${HOST}:/tmp/otelcol-agent-config.yaml"
ssh "$HOST" "sudo cp /tmp/otelcol-agent-config.yaml /etc/otelcol/config.yaml && rm /tmp/otelcol-agent-config.yaml"

echo "→ Installing Quadlet..."
ssh "$HOST" "mkdir -p ~/.config/containers/systemd"
scp "${SCRIPT_DIR}/agent/otelcol-agent.container" "${HOST}:~/.config/containers/systemd/"

echo "→ Starting agent..."
ssh "$HOST" "systemctl --user daemon-reload && systemctl --user enable --now otelcol-agent.service"

echo "→ Verifying agent started..."
sleep 5
ssh "$HOST" "systemctl --user is-active otelcol-agent.service && echo '  ✅ Agent running' || echo '  ❌ Agent failed — check: journalctl --user -u otelcol-agent -n 30'"

echo "✅ OTel agent deployed to ${HOST}"
