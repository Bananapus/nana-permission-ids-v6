# Juicebox Permission IDs

## Use This File For

- Use this file when you need the canonical numeric meaning of a Juicebox V6 permission constant.
- Start here when reviewing changes that could affect permission numbering across the ecosystem.

## Read This Next

| If you need... | Open this next |
|---|---|
| Repo overview and scope | [`README.md`](./README.md), [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| The actual constants | [`src/JBPermissionIds.sol`](./src/JBPermissionIds.sol) |

## Repo Map

| Area | Where to look |
|---|---|
| Constants | [`src/JBPermissionIds.sol`](./src/JBPermissionIds.sol) |

## Purpose

This repo is the single source of truth for Juicebox V6 permission ID constants. It has no runtime behavior. Its value is ecosystem-wide coordination.

## Reference Files

- Open [`references/runtime.md`](./references/runtime.md) when you need the stability expectations and why changes here affect the whole ecosystem.

## Working Rules

- Start in [`src/JBPermissionIds.sol`](./src/JBPermissionIds.sol). The file itself is the product.
- Treat any numeric change as a cross-repo breaking change until proven otherwise.
