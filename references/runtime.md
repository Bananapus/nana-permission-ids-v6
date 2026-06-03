# Permission IDs Runtime

Use this file when you need to confirm the canonical numeric labels, not when you need to understand enforcement behavior.

## Core role

- [`src/JBPermissionIds.sol`](../src/JBPermissionIds.sol) defines the canonical numeric labels used by the rest of the ecosystem.

## High-risk areas

- Numeric drift: a local redefinition or renumbering breaks cross-repo assumptions.
- Permission scope confusion: this repo names IDs, but enforcement still lives elsewhere.

## Change checklist

- If you edit a constant, review every dependent repo that imports it.
- If you need to know who can exercise a permission, follow the usage into the enforcing repo rather than stopping here.
- There are no repo-local tests here, so downstream compile and behavior reviews matter more than this package in isolation.
