# Architecture

## Purpose

`nana-permission-ids-v6` is the shared permission namespace for the ecosystem. It exists so every repo can agree on what permission bit means what.

## Boundaries

- This repo intentionally contains almost no logic.
- Its value is stability, not sophistication.
- The constants here are coupled to checks spread across many sibling repos.

## Main Components

| Component | Responsibility |
| --- | --- |
| `JBPermissionIds` | Defines the canonical `uint8` IDs used with `JBPermissions` |

## Runtime Model

There is no runtime state. Other repos import this library and compare permission bits against these constants.

## Critical Invariants

- Existing IDs must remain stable once consumed by deployed contracts and integrations.
- New IDs should only be appended intentionally; repurposing an old ID is ecosystem-breaking.
- `ROOT` stays special and must remain consistent with `JBPermissions` expectations.

## Where Complexity Lives

- The code is trivial; the coordination burden is not.
- Mistakes here look like harmless renames until they land in downstream permission checks.

## Dependencies

- Semantically coupled to `nana-core-v6` and every repo that performs permission checks

## Safe Change Guide

- Treat every ID change as a cross-repo protocol change.
- When adding a permission, update the docs and downstream repos in the same change set.
- Do not add convenience aliases that obscure the one-to-one mapping between bit position and meaning.
