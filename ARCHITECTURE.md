# Architecture

## Purpose

`nana-permission-ids-v6` is the shared permission namespace for the V6 ecosystem. It makes sure every repo agrees on what each permission bit means when interacting with `JBPermissions`.

## System Overview

This repo intentionally contains almost no logic. Other repos import `JBPermissionIds` and compare permission bits against these constants.

## Core Invariants

- Existing IDs must stay stable once deployed contracts or integrations use them.
- New IDs should be appended intentionally, not reused or repurposed.
- Numeric stability matters more than naming convenience.
- `ROOT` must stay aligned with `JBPermissions` expectations in `nana-core-v6`.

## Modules

| Module | Responsibility | Notes |
| --- | --- | --- |
| `JBPermissionIds` | Defines canonical `uint8` permission IDs | Entire repo value |

## Trust Boundaries

- This repo has no runtime authority by itself.
- It is tightly coupled to `nana-core-v6` and every repo that performs permission checks.

## Critical Flows

There is no runtime flow. Other repos import the library and use the constants in permission checks.

## Accounting Model

No accounting lives here.

## Security Model

- The code is trivial, but the coordination burden is not.
- A rename or reorder here can silently break permissions across the ecosystem.
- The real blast radius comes from deployed contracts that already use these values.
- There is very little meaningful local runtime test surface in this repo.

## Safe Change Guide

- Treat any ID change as a cross-repo protocol change.
- When adding a permission, update downstream repos and docs in the same change set.
- Do not add aliases that hide the one-to-one mapping between bit position and meaning.

## Source Map

- `src/JBPermissionIds.sol`
- `references/runtime.md`
