# Juicebox Permission IDs

## Use This File For

- Use this file when you need the canonical numeric meaning of a Juicebox V6 permission constant or when reviewing changes that would affect permission numbering across the ecosystem.
- Start here, then open the constant file directly.

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

Single source of truth for Juicebox V6 permission ID constants. This repo has no runtime behavior; its value is ecosystem-wide coordination.

## Reference Files

- Open [`references/runtime.md`](./references/runtime.md) when you need the stability expectations and why changes here are ecosystem-wide.

## Working Rules

- Start in [`src/JBPermissionIds.sol`](./src/JBPermissionIds.sol). The file itself is the product.
- Treat any numeric change as a cross-repo breaking change until proven otherwise.
