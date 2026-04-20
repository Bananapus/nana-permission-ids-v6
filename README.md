# Juicebox Permission IDs

`@bananapus/permission-ids-v6` is the shared constant library for Juicebox V6 operator permissions. It gives every repo in the ecosystem the same numeric meaning for the same permission name.

Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)  
User journeys: [USER_JOURNEYS.md](./USER_JOURNEYS.md)  
Skills: [SKILLS.md](./SKILLS.md)  
Risks: [RISKS.md](./RISKS.md)  
Administration: [ADMINISTRATION.md](./ADMINISTRATION.md)  
Audit instructions: [AUDIT_INSTRUCTIONS.md](./AUDIT_INSTRUCTIONS.md)

## Overview

The library is intentionally simple: one Solidity file, no storage, no deployment, and no runtime logic. Its value comes from consistency.

`JBPermissions` stores operator permissions as packed bits. This package names the bit positions so integrations do not drift across repos.

Use this repo as the single source of truth for permission numbers. Do not redefine permission IDs locally in downstream repos.

If the question is "who can do this action?" you will still need `JBPermissions` in `nana-core-v6`. This repo only tells you what the numeric labels mean.

## Current Permission Ranges

| Range | Area |
| --- | --- |
| `1` | global `ROOT` permission |
| `2-23` | core protocol permissions |
| `24-27` | 721 hook permissions |
| `28-30` | buyback hook and registry permissions |
| `31` | router terminal registry permission |
| `32-35` | sucker and omnichain-deployment permissions |
| `36-40` | revnet-core permissions (hidden tokens, loans) |

The exact constants live in `src/JBPermissionIds.sol`.

Two IDs deserve special attention:

- `SET_BUYBACK_HOOK` covers both setting and permanently locking the configured buyback hook
- `SET_ROUTER_TERMINAL` covers both setting and permanently locking the configured router terminal

## Mental Model

This repo is a coordination artifact, not a behavior repo. Its value is that every other package can import the same names and mean the same thing.

## Read This File First

1. `src/JBPermissionIds.sol`

## Integration Traps

- changing an existing numeric constant is a breaking ecosystem change, not an internal refactor
- adding a new permission ID without coordinating downstream repos creates semantic drift even if the code still compiles
- wildcard project permissions remain dangerous even when the numeric IDs themselves are correct

## Where Meaning Lives

- numeric permission labels live in `JBPermissionIds.sol`
- runtime permission checks live in `nana-core-v6/src/JBPermissions.sol`
- repo-specific uses of those IDs live in the downstream package that imports them

## For AI Agents

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

## Repository Layout

```text
src/
  JBPermissionIds.sol
```

## Risks And Notes

- `ROOT` is intentionally powerful and should be granted sparingly
- wildcard project scope is convenient but easy to misuse operationally
- some IDs intentionally bundle configuration and irreversible locking authority, so their blast radius is larger than their names first suggest
- any change to this file has ecosystem-wide consequences because other repos assume the values are stable
