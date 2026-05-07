# Audit Instructions

This repo is only permission ID constants, but those constants are security-critical because many repos key access control off them.

## Audit Objective

Find issues that:

- assign duplicate IDs to different permissions
- mismatch IDs that downstream repos assume are canonical
- create ordering or collision hazards for future permission additions

## Scope

In scope:

- `src/JBPermissionIds.sol`

## Start Here

1. `src/JBPermissionIds.sol`
2. downstream consumers in `nana-core-v6` and `revnet-core-v6`

## Security Model

This repo defines canonical numeric IDs that other repos treat as part of their permission model.

- the file is small, but stale renumbering or collisions can silently widen or break access control elsewhere
- correctness depends on cross-repo alignment, not local logic alone

## Integration Assumptions

| Dependency | Assumption | What breaks if wrong |
|------------|------------|----------------------|
| `nana-core-v6` | ERC-20 signature delegation still uses the documented ID | Signature authority checks mismatch |
| `revnet-core-v6` | Loan and hidden-token permissions still use the documented IDs | Delegated actions widen, fail, or misroute |

## Critical Invariants

1. Each permission semantic has one stable numeric ID.
2. No two distinct permissions share an ID.
3. IDs match the expectations of all dependent repos in this workspace.
4. ID `23` (`SIGN_FOR_ERC20`) matches the value used by `nana-core-v6` for ERC-1271 signature delegation.
5. IDs `36-40` used by `revnet-core-v6` match the values used in `REVHiddenTokens` and `REVLoans`.

## Attack Surfaces

- duplicate or reordered constants
- stale cross-repo assumptions
- permission additions that collide with previously assigned meanings

## Verification

- `npm install`
- `forge build`
