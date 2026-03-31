# Juicebox Permission IDs

`@bananapus/permission-ids-v6` is the shared constant library for Juicebox V6 operator permissions. It gives every repo in the ecosystem the same numeric meaning for the same permission name.

Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)

## Overview

The library is intentionally simple: one Solidity file, no storage, no deployment, and no runtime logic. Its value comes from consistency.

`JBPermissions` stores operator permissions as packed bits. This package names the bit positions so integrations do not drift across repos.

Use this repo as the single source of truth for permission numbers. Do not redefine permission IDs locally in downstream repos.

If the question is "who can do this action?" you will still need `JBPermissions` in `nana-core-v6`. This repo only tells you what the numeric labels mean.

## Current Permission Ranges

| Range | Area |
| --- | --- |
| `1` | global `ROOT` permission |
| `2-22` | core protocol permissions |
| `23-26` | 721 hook permissions |
| `27-29` | buyback hook permissions |
| `30` | router terminal permission |
| `31-34` | sucker and omnichain permissions |

The exact constants live in `src/JBPermissionIds.sol`.

## Mental Model

This repo is a coordination artifact, not a behavior repo. Its value is that every other package can import the same names and mean the same thing.

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
- any change to this file has ecosystem-wide consequences because other repos assume the values are stable
