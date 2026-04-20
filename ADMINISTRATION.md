# Administration

## At A Glance

| Item | Details |
| --- | --- |
| Scope | Shared permission ID namespace for the wider ecosystem |
| Control posture | Source-level coordination only |
| Highest-risk actions | Reordering or reusing IDs already assumed by deployed contracts |
| Recovery posture | Requires downstream code changes and redeployments where relevant |

## Purpose

`nana-permission-ids-v6` has no runtime admin surface. Its control significance is source-level: it defines the shared permission namespace used by the rest of the ecosystem.

## Control Model

- No owner
- No runtime governance
- No mutable onchain state
- Source-code level coordination only

## Roles

| Role | How Assigned | Scope | Notes |
| --- | --- | --- | --- |
| Maintainer | Source-code author | Ecosystem-wide | Can add or reorder constants only by editing and redeploying dependent code |

## Privileged Surfaces

There are no privileged runtime functions. The only meaningful changes are source changes to `JBPermissionIds.sol`.

## Immutable And One-Way

- Once deployed contracts depend on a given ID mapping, that mapping is effectively immutable for those deployments.
- Reusing or reordering IDs is a cross-repo breaking change.

## Operational Notes

- Add new permission IDs append-only.
- Update downstream docs and call sites in the same change set.
- Treat permission ID changes as protocol changes, not refactors.

## Machine Notes

- Do not infer semantic compatibility from matching names if numeric IDs changed.
- Treat `src/JBPermissionIds.sol` as append-only unless a breaking ecosystem-wide migration is intentional.
- If docs and code disagree on a permission number, trust the code and update the docs before further admin review.

## Recovery

- There is no runtime recovery surface.
- A bad ID assignment is fixed only by downstream code changes and redeployments where needed.

## Admin Boundaries

- Nobody can patch deployed contracts to reinterpret old permission bits.
- This repo cannot grant, revoke, or inspect permissions by itself.

## Source Map

- `src/JBPermissionIds.sol`
