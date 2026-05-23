# Contributing to Bluespeed

## Philosophy

Bluespeed is a CNCF-native homelab factory. Before proposing any new tool or service, check whether a CNCF project covers the use case at [landscape.cncf.io](https://landscape.cncf.io/).

If a CNCF tool exists — use it. Don't build custom. This is non-negotiable.

## Setting Up Your Own Lab

> **[PLACEHOLDER: hardware requirements, network setup, Flatcar install steps]**

```bash
# Clone and deploy
git clone https://github.com/projectbluefin/bluespeed
cd bluespeed
just setup CENTRAL=user@your-central-node NODE=user@your-other-node
```

## Development Workflow

```bash
just                        # list all recipes
just setup-otel HOST=...    # deploy observability stack
just otel-status HOST=...   # check stack health
just otel-logs HOST=...     # tail service logs
```

## Adding a New Stack Component

1. Check [landscape.cncf.io](https://landscape.cncf.io/) — CNCF tool must exist
2. Add a `just` recipe in `Justfile`
3. Add deployment scripts under a new top-level directory (e.g. `kubevirt/`)
4. Document ports used — no conflicts with existing services:
   - 3100 Loki, 4317/4318 OTel, 9090 Prometheus, 8082 Perses
5. Update the stack table in `README.md`
6. Update `docs/CONTRIBUTING.md` with the new port

## Porting to New Hardware

The stack is designed to be hardware-agnostic. To deploy on different hardware:
- Update the `endpoint` in `otel/agent/otelcol-agent-config.yaml` to your central node IP
- Run `just setup CENTRAL=user@your-ip NODE=user@your-node-ip`

## Issues

File issues at: https://github.com/projectbluefin/bluespeed/issues
