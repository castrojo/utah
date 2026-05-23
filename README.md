# Bluespeed

> **[PLACEHOLDER: 2-3 sentences. What is Bluespeed? What does it do for the user? Who is it for?]**

---

## The Bundle

Bluespeed ships with **[knuckle](https://github.com/projectbluefin/knuckle)** as its installer.

knuckle is the standalone, upstream-track TUI installer for [Flatcar Container Linux](https://www.flatcar.org/) — neutral, minimal, and built to be what Flatcar's official installer could be. It lives in its own repo, has its own release cycle, and accepts no homelab opinions.

Bluespeed takes knuckle and adds one opinionated layer on top: when you boot a Bluespeed ISO, you get knuckle's install wizard plus a Bluespeed-specific post-install configuration screen. After knuckle hands off to a running Flatcar system, Bluespeed takes over.

**knuckle:** installs Flatcar  
**Bluespeed:** configures everything you actually want on it

---

## What Bluespeed Adds

> **[PLACEHOLDER: feature list — homelab mode, KubeSteller, KubeVirt, ZFS, HomeAssistant, node management, app store (linuxserver.io), reference architectures, etc.]**

---

## Architecture

```
Bluespeed ISO
└── knuckle (bundled, unmodified)
    └── Flatcar install wizard
        └── flatcar-install → running Flatcar node
            └── Bluespeed post-install
                └── [PLACEHOLDER: what happens here]
```

> Bluespeed tracks knuckle releases. The knuckle binary inside a Bluespeed ISO is always a tagged knuckle release — never a fork, never patched.

---

## Status

> **[PLACEHOLDER: alpha / pre-release / roadmap note]**

---

## Getting Started

> **[PLACEHOLDER: how to download, boot, and use Bluespeed]**

---

## Relationship to Flatcar and Project Bluefin

> **[PLACEHOLDER: how this fits in the broader ecosystem]**

---

## Contributing

> **[PLACEHOLDER: contribution guidelines, code of conduct pointer, issue filing]**

---

## License

Apache-2.0 — see [LICENSE](LICENSE)
