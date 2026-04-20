# Architecture

## Purpose

`nana-permission-ids-v6` is the shared permission namespace for the V6 ecosystem. It ensures every repo agrees on what each permission bit means when interacting with `JBPermissions`.

## System Overview

The repo intentionally contains almost no logic. Its value is stable coordination across the stack. Other repos import `JBPermissionIds` and compare permission bits against these constants.

## Core Invariants

- Existing IDs must remain stable once consumed by deployed contracts or integrations.
- New IDs should be appended intentionally, not reused or repurposed.
- Numeric stability matters more than naming convenience; changing a value while keeping a familiar name is still a protocol break.
- `ROOT` must stay aligned with `JBPermissions` expectations in `nana-core-v6`.

## Modules

| Module | Responsibility | Notes |
| --- | --- | --- |
| `JBPermissionIds` | Defines canonical `uint8` permission IDs | Entire repo value |

## Trust Boundaries

- This repo has no runtime authority by itself.
- It is semantically coupled to `nana-core-v6` and every repo that performs permission checks.

## Critical Flows

There is no runtime flow. Other repos import the library and use the constants in permission checks.

## Accounting Model

No accounting lives here.

## Security Model

- The code is trivial, but the coordination burden is not.
- A seemingly harmless rename or reorder here can silently break permissions across the ecosystem.
- This repo's real blast radius comes from deployed contracts that have already baked these values into their runtime behavior.
- There is no meaningful local runtime test surface in this repo today; correctness is mostly enforced by downstream compatibility and reviewer discipline.

## Safe Change Guide

- Treat any ID change as a cross-repo protocol change.
- When adding a permission, update downstream repos and docs in the same change set.
- Do not add aliases that obscure the one-to-one mapping between bit position and meaning.

## Source Map

- `src/JBPermissionIds.sol`
- `references/runtime.md`
