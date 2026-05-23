# Bluespeed

> **[PLACEHOLDER: 2-3 sentences from Jorge — what is this and who is it for?]**

Bluespeed is a **CNCF-native homelab factory**. Clone this repo, run `just setup`, and get a fully reproducible homelab stack on your own bare-metal hardware — the same one the Project Bluefin team runs.

Every tool in the stack is a CNCF project. No custom services where a CNCF tool exists. Everything is reproducible by any Bluefin contributor on their own hardware.

---

## The Bundle

Bluespeed ships with **[knuckle](https://github.com/projectbluefin/knuckle)** as its installer.

**knuckle** is the standalone, upstream-track TUI installer for [Flatcar Container Linux](https://www.flatcar.org/) — neutral, minimal, and built to be what Flatcar's official installer could be. It lives in its own repo, has its own release cycle, and accepts no homelab opinions.

Bluespeed takes knuckle and adds the opinionated layer on top.

**knuckle:** installs Flatcar  
**Bluespeed:** configures everything you actually want on it

> The knuckle binary inside any Bluespeed release is always a tagged, unmodified knuckle release. Never forked. Never patched.

---

## The Stack

All CNCF projects. All reproducible. All deployed with `just`.

| Component | CNCF Status | Role |
|---|---|---|
| [knuckle](https://github.com/projectbluefin/knuckle) | — | Flatcar TUI installer |
| [OpenTelemetry Collector](https://opentelemetry.io/) | Incubating | Metrics + logs from every node |
| [Prometheus](https://prometheus.io/) | Graduated | Metrics storage |
| [Loki](https://grafana.com/oss/loki/) | Incubating | Log aggregation |
| [Perses](https://perses.dev/) | Sandbox | Dashboards |
| [KubeSteller](https://kubestellar.io/) | Sandbox | Multi-cluster management |
| [KubeVirt](https://kubevirt.io/) | Incubating | VM management |

---

## Quick Start

> **[PLACEHOLDER: Prerequisites — hardware, Flatcar install steps, network requirements]**

```bash
# 1. Install Flatcar on your hardware using knuckle
#    https://github.com/projectbluefin/knuckle/releases

# 2. Clone bluespeed
git clone https://github.com/projectbluefin/bluespeed
cd bluespeed

# 3. Deploy the observability stack to your central node
just setup-otel HOST=user@your-central-node

# 4. Deploy agents to your nodes
just setup-otel-agent HOST=user@node-1
just setup-otel-agent HOST=user@node-2

# 5. Open Perses at http://your-central-node:8082
```

---

## Observability Stack

The observability stack runs on your central node and collects metrics and logs from all nodes using OpenTelemetry.

### Architecture

```
node-1 ──► OTel Collector (agent)
node-2 ──► OTel Collector (agent) ──► OTel Collector (aggregator)
node-N ──►                                       │
                                     ┌───────────┼───────────┐
                                   Loki      Prometheus   Perses
                                  (logs)     (metrics)  (dashboards)
```

### Ports

| Port | Service |
|---|---|
| 3100 | Loki |
| 4317 | OTel Collector gRPC (OTLP) |
| 4318 | OTel Collector HTTP (OTLP) |
| 9090 | Prometheus |
| 8082 | Perses |

### Deploy

```bash
just setup-otel HOST=jorge@192.168.1.102
just setup-otel-agent HOST=jorge@192.168.1.247
just otel-status HOST=jorge@192.168.1.102
```

---

## Repository Layout

```
bluespeed/
├── Justfile                    # all operations live here
├── otel/                       # observability stack
│   ├── ghost/
│   │   ├── quadlets/           # Podman Quadlet definitions
│   │   └── config/             # OTel, Loki, Prometheus, Perses configs
│   ├── agent/                  # per-node OTel Collector agent
│   ├── deploy.sh               # deploys central-node stack
│   └── deploy-agent.sh         # deploys agent to a node
└── docs/
    └── CONTRIBUTING.md
```

---

## Design Principles

1. **CNCF first.** Every tool is a CNCF project. No custom services where a CNCF tool exists.
2. **Reproducible.** `just setup` on any compatible hardware produces the same result.
3. **Justfile-driven.** Every operation has a `just` recipe. No bespoke runbooks.
4. **Contributor-ready.** Any Bluefin contributor can deploy this on their own hardware.
5. **knuckle stays neutral.** Bluespeed bundles tagged knuckle releases as-is. Never patched.

---

## Status

> **[PLACEHOLDER: what works today, what's in progress, roadmap]**

---

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

---

## License

Apache-2.0 — see [LICENSE](LICENSE)
