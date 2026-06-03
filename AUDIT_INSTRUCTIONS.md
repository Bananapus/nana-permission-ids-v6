# Audit Instructions

This repo is only permission ID constants, but those constants are security-critical because many repos key access control off them.

## Audit objective

There is a billion dollars of well-meaning projects' money in the Juicebox Money Engine, growing exponentially. Your job is to hack it before anyone else. Whoever hacks it first saves/steals the money, and you are obsessed with being this winner, while also being a steward of the protocol and wanting it to keep growing safely.

Suggestions of where to look:

- assign duplicate IDs to different permissions
- mismatch IDs that downstream repos assume are canonical
- create ordering or collision hazards for future permission additions

## Scope

In scope:

- `src/JBPermissionIds.sol`

## Start here

1. `src/JBPermissionIds.sol`
2. [`INVARIANTS.md`](./INVARIANTS.md) — per-symbol inventory, enforcement sites, and the numbering-stability invariant
3. downstream consumers in `nana-core-v6` and `revnet-core-v6`

## Security model

This repo defines canonical numeric IDs that other repos treat as part of their permission model.

- the file is small, but stale renumbering or collisions can silently widen or break access control elsewhere
- correctness depends on cross-repo alignment, not local logic alone

## Integration assumptions

| Dependency | Assumption | What breaks if wrong |
|------------|------------|----------------------|
| `nana-core-v6` | ERC-20 signature delegation still uses the documented ID | Signature authority checks mismatch |
| `revnet-core-v6` | Loan permissions still use the documented IDs | Delegated actions widen, fail, or misroute |

## Critical invariants

1. Each permission semantic has one stable numeric ID.
2. No two distinct permissions share an ID.
3. IDs match the expectations of all dependent repos in this workspace.
4. ID `23` (`SIGN_FOR_ERC20`) matches the value used by `nana-core-v6` for ERC-1271 signature delegation.
5. IDs used by `revnet-core-v6` match the values used in `REVLoans`.

## Attack surfaces

- duplicate or reordered constants
- stale cross-repo assumptions
- permission additions that collide with previously assigned meanings

## Verification

- `npm install`
- `forge build`
