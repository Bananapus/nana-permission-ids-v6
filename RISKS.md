# Permission IDs Risk Register

This file focuses on the coordination risks in `JBPermissionIds`. The contract surface is tiny, but any semantic drift here can corrupt access control across the entire V6 ecosystem.

## How to use this file

- Read `Priority risks` first; the main danger is cross-repo disagreement, not local bugs.
- Treat every ID change as an ecosystem migration event.
- Use `Invariants to Verify` to keep append-only discipline explicit.

## Priority risks

| Priority | Risk | Why it matters | Primary controls |
|----------|------|----------------|------------------|
| P0 | Semantic drift across repos | If two packages assign different meanings to the same numeric ID, permission checks silently authorize the wrong actions. | Single source of truth, append-only changes, and synchronized downstream updates. |
| P1 | Reusing or reordering existing IDs | Renumbering breaks already-deployed contracts and off-chain tooling without any on-chain migration safety. | Never repurpose an assigned ID. Append only. |
| P1 | Over-trusting high-impact IDs | Some IDs directly control funds, terminal routing, hook locking, or wildcard authority. Misgrants are catastrophic. | Explicit operator review and narrow-scoped permission grants. |

## 1. Known Risks

- **No runtime enforcement here.** This library only defines constants. Safety depends on every consuming repo checking the intended ID.
- **`ROOT` is ecosystem-wide god mode.** `ROOT` (ID `1`) grants all permissions, including permissions added in the future.
- **Wildcard grants amplify blast radius.** Any permission granted with `projectId = 0` applies to all projects owned by that account. System contracts may need this, but operator mistakes become ecosystem-wide.
- **Hook and router lock powers are bundled.** `SET_BUYBACK_HOOK` (ID `30`) controls both hook selection and hook locking. `SET_ROUTER_TERMINAL` (ID `31`) controls both terminal selection and terminal locking.
- **No on-chain namespace for third-party extensions.** IDs `41-255` are socially available, not registry-managed. External packages can collide unless teams coordinate out of band.

## 2. High-Impact IDs

- **Fund-moving IDs.** `CASH_OUT_TOKENS` (`4`), `SEND_PAYOUTS` (`5`), `MIGRATE_TERMINAL` (`6`), `SET_TERMINALS` (`15`), `USE_ALLOWANCE` (`18`), and `SET_SPLIT_GROUPS` (`19`) can redirect or release value.
- **Hook-routing IDs.** `SET_BUYBACK_POOL` (`28`), `SET_BUYBACK_HOOK` (`30`), and `SET_ROUTER_TERMINAL` (`31`) materially control execution routes and can lock those routes permanently.
- **Revnet loan IDs.** `OPEN_LOAN` (`37`), `REALLOCATE_LOAN` (`38`), and `REPAY_LOAN` (`39`) are operationally powerful because they move collateral and debt state.

## 3. Integration Risks

- **Docs can lag deployed assumptions.** Off-chain tooling, UIs, and auditors often rely on human-readable permission names. A stale doc can be almost as dangerous as a stale constant if operators grant the wrong ID.
- **Cross-package imports must remain canonical.** Downstream repos should import this library instead of redefining numeric literals locally.
- **Future IDs inherit current trust assumptions.** Because `ROOT` covers future IDs, any new permission expands the capability of existing ROOT operators immediately after deployment.

## 4. Invariants to Verify

- Assigned IDs are append-only and never repurposed.
- `0` remains unused as a permission ID.
- Every documented ID in this repo matches the numeric checks in downstream consuming contracts.
- New IDs added after `40` do not collide with existing ecosystem assignments.

## 5. Accepted Behaviors

### 5.1 This repo is coordination infrastructure, not an enforcement layer

`JBPermissionIds` intentionally has no access control, storage, or runtime checks. The value of the repo is that every other package can import the same constants and mean the same thing.
