# Juicebox Permission IDs

`@bananapus/permission-ids-v6` is the shared constant library for Juicebox V6 operator permissions. It gives every repo in the ecosystem the same numeric meaning for the same permission name.

## Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — how this library fits the V6 ecosystem
- [INVARIANTS.md](./INVARIANTS.md) — guarantees to integrators, per-symbol inventory, and the numbering-stability proof
- [USER_JOURNEYS.md](./USER_JOURNEYS.md) — how consumers (contracts, scripts, frontends) use the constants
- [RISKS.md](./RISKS.md) — coordination risks across downstream repos
- [ADMINISTRATION.md](./ADMINISTRATION.md) — release process and namespace governance
- [AUDIT_INSTRUCTIONS.md](./AUDIT_INSTRUCTIONS.md) — what to verify when auditing this repo
- [SKILLS.md](./SKILLS.md) — quick-reference index for AI agents
- [STYLE_GUIDE.md](./STYLE_GUIDE.md) — V6 ecosystem Solidity conventions
- [CHANGELOG.md](./CHANGELOG.md) - V5 to V6 permission-map changelog

## Overview

This library is intentionally simple: one Solidity file, no storage, no deployment, and no runtime logic. Its value is consistency.

`JBPermissions` stores operator permissions as packed bits. This package names those bit positions so integrations do not drift across repos.

Use this repo as the single source of truth for permission numbers. Do not redefine permission IDs locally in downstream repos.

If the question is "who can do this action?" you still need `JBPermissions` in `nana-core-v6`. This repo only tells you what the numbers mean.

## Current permission ranges

| Range | Area |
| --- | --- |
| `1` | global `ROOT` permission |
| `2-23` | core protocol permissions |
| `24-27` | 721 hook permissions |
| `28-30` | buyback hook and registry permissions |
| `31` | router terminal registry permission |
| `32-36` | sucker and omnichain deployment/lifecycle permissions |
| `37-39` | revnet-core loan permissions |
| `40` | currently unassigned; reserved for the next ecosystem permission |

The exact constants live in `src/JBPermissionIds.sol`.

Two IDs deserve extra attention:

- `SET_BUYBACK_HOOK` covers both setting and permanently locking the configured buyback hook
- `SET_ROUTER_TERMINAL` covers both setting and permanently locking the configured router terminal

## Mental model

This repo is a naming registry, not a behavior repo. Its job is to make every other package use the same permission names for the same bit positions.

## Read this file first

1. `src/JBPermissionIds.sol`

## Integration traps

- changing an existing numeric constant is an ecosystem breaking change
- adding a new permission ID without coordinating downstream repos creates semantic drift even if code still compiles
- wildcard project permissions are still dangerous even when the numeric IDs are correct

## Where meaning lives

- numeric permission labels: `JBPermissionIds.sol`
- runtime permission checks: `nana-core-v6/src/JBPermissions.sol`
- repo-specific uses of those IDs: the downstream repo that imports them

## For AI agents

- Treat this repo as a naming registry for permission bits, not as the runtime permission engine.
- If asked whether an action is allowed, inspect the downstream repo that checks the ID in addition to this file.

## Install

```bash
npm install @bananapus/permission-ids-v6
```

## Development

```bash
npm install
forge build
```

## Repository layout

```text
src/
  JBPermissionIds.sol
```

## Risks and notes

- `ROOT` is intentionally powerful and should be granted sparingly
- wildcard project scope is convenient but easy to misuse
- some IDs bundle configuration and irreversible locking authority, so their blast radius is larger than the short name suggests
- any change to this file has ecosystem-wide consequences because other repos assume the values stay stable

This repo is just numbers — but the numbers are load-bearing across every other V6 package.
