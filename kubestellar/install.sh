#!/usr/bin/env bash
# KubeStellar Console install script — runs on ghost (192.168.1.102)
# Called by: just install-kubestellar-console
set -euo pipefail

PORT="${KC_PORT:-8090}"
KUBECONFIG_SRC="${KUBECONFIG_SRC:-/tmp/exo-knuckle-kubeconfig.yaml}"
CONSOLE_DIR="$HOME/kubestellar-console"
CONFIG_DIR="$HOME/.config/bluespeed"

echo "→ KubeStellar Console install (port $PORT)"

# 1. Download binaries if missing
mkdir -p "$CONSOLE_DIR"
cd "$CONSOLE_DIR"
if [[ ! -x ./console || ! -x ./kc-agent ]]; then
    echo "  Downloading binaries via start.sh..."
    # Run start.sh in background, let it download, then kill the spawned processes
    bash <(curl -sSL https://raw.githubusercontent.com/kubestellar/console/main/start.sh) \
        --port "$PORT" &
    START_PID=$!
    # Wait for binaries to appear (up to 120s)
    for i in $(seq 1 24); do
        sleep 5
        if [[ -x ./console && -x ./kc-agent ]]; then
            echo "  Binaries downloaded."
            break
        fi
    done
    kill "$START_PID" 2>/dev/null || true
    pkill -f "kubestellar-console/console" 2>/dev/null || true
    pkill -f "kubestellar-console/kc-agent" 2>/dev/null || true
    sleep 2
fi

[[ -x ./console ]] || { echo "ERROR: console binary not found"; exit 1; }
[[ -x ./kc-agent ]] || { echo "ERROR: kc-agent binary not found"; exit 1; }
echo "  ✅ Binaries present: $(ls -lh console kc-agent | awk '{print $NF, $5}')"

# 2. Permanent kubeconfig
mkdir -p "$CONFIG_DIR"
if [[ -f "$KUBECONFIG_SRC" ]]; then
    cp "$KUBECONFIG_SRC" "$CONFIG_DIR/kubeconfig"
    chmod 600 "$CONFIG_DIR/kubeconfig"
    echo "  ✅ Kubeconfig copied from $KUBECONFIG_SRC"
elif [[ -f "$CONFIG_DIR/kubeconfig" ]]; then
    echo "  ✅ Kubeconfig already at $CONFIG_DIR/kubeconfig"
else
    echo "ERROR: no kubeconfig found at $KUBECONFIG_SRC or $CONFIG_DIR/kubeconfig"
    exit 1
fi

# 3. Persistent KC_AGENT_TOKEN
if [[ ! -f "$CONFIG_DIR/kc-agent-token" ]]; then
    openssl rand -hex 32 > "$CONFIG_DIR/kc-agent-token"
    chmod 600 "$CONFIG_DIR/kc-agent-token"
    echo "  ✅ Generated new KC_AGENT_TOKEN"
else
    echo "  ✅ KC_AGENT_TOKEN already set"
fi
KC_TOKEN=$(cat "$CONFIG_DIR/kc-agent-token")

# 4. Env file
cat > "$CONFIG_DIR/kc-agent-env" << ENVEOF
KUBECONFIG=$CONFIG_DIR/kubeconfig
KC_AGENT_TOKEN=$KC_TOKEN
ENVEOF
echo "  ✅ Env file written to $CONFIG_DIR/kc-agent-env"

# 5. systemd user service: kc-agent
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/kubestellar-agent.service" << SVCEOF
[Unit]
Description=KubeStellar Console kc-agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=%h/kubestellar-console
EnvironmentFile=%h/.config/bluespeed/kc-agent-env
ExecStart=%h/kubestellar-console/kc-agent
Restart=on-failure
RestartSec=5
StandardOutput=append:%h/kubestellar-console/kc-agent.log
StandardError=append:%h/kubestellar-console/kc-agent.log

[Install]
WantedBy=default.target
SVCEOF

# 6. systemd user service: console UI
cat > "$HOME/.config/systemd/user/kubestellar-console.service" << SVCEOF
[Unit]
Description=KubeStellar Console UI
After=kubestellar-agent.service
Requires=kubestellar-agent.service

[Service]
Type=simple
WorkingDirectory=%h/kubestellar-console
EnvironmentFile=%h/.config/bluespeed/kc-agent-env
ExecStart=%h/kubestellar-console/console --port $PORT
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
SVCEOF

echo "  ✅ systemd units written"

# 7. Enable and start
systemctl --user daemon-reload
systemctl --user enable kubestellar-agent.service kubestellar-console.service
systemctl --user restart kubestellar-agent.service
sleep 2
systemctl --user restart kubestellar-console.service
sleep 2

# 8. Linger (survive logout)
loginctl enable-linger "$(id -un)"

# Verify
GHOST_IP=$(hostname -I | awk '{print $1}')
if curl -sf "http://localhost:$PORT/" > /dev/null; then
    echo ""
    echo "✅ KubeStellar Console running"
    echo "   URL:    http://$GHOST_IP:$PORT"
    echo "   Agent:  $(systemctl --user is-active kubestellar-agent.service)"
    echo "   UI:     $(systemctl --user is-active kubestellar-console.service)"
    echo "   Token:  $(head -c 16 "$CONFIG_DIR/kc-agent-token")..."
else
    echo "❌ Console not responding on port $PORT"
    journalctl --user -u kubestellar-console --no-pager -n 20
    exit 1
fi
