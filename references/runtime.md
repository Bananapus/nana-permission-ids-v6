# Permission IDs Runtime

## Core Role

- [`src/JBPermissionIds.sol`](../src/JBPermissionIds.sol) defines the canonical numeric labels used by the rest of the ecosystem.

## High-Risk Areas

- Numeric drift: a local redefinition or renumbering breaks cross-repo assumptions.
- Permission scope confusion: this repo names IDs, but enforcement still lives elsewhere.

## Change Checklist

- If you edit a constant, audit every dependent repo that imports it.
- If you need to know who can exercise a permission, follow the usage into the enforcing repo rather than stopping here.
