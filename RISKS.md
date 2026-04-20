# Permission IDs Risk Register

This file covers the coordination risks in `JBPermissionIds`. The contract surface is tiny, but drift here can corrupt access control across the V6 ecosystem.

## How To Use This File

- Read `Priority risks` first. The main danger is cross-repo disagreement, not a local code bug.
- Treat every ID change as an ecosystem migration event.
- Use `Invariants to verify` to keep append-only discipline explicit.

## Priority Risks

| Priority | Risk | Why it matters | Primary controls |
|----------|------|----------------|------------------|
| P0 | Semantic drift across repos | If two packages assign different meanings to the same ID, permission checks can silently authorize the wrong actions. | Single source of truth, append-only changes, and synchronized downstream updates. |
| P1 | Reusing or reordering existing IDs | Renumbering breaks deployed contracts and off-chain tooling without any on-chain migration safety. | Never repurpose an assigned ID. Append only. |
| P1 | Over-trusting high-impact IDs | Some IDs directly control funds, routing, locking, or loan state. Misgrants are dangerous. | Explicit operator review and narrow-scoped grants. |

## 1. Known Risks

- **No runtime enforcement here.** This library only defines constants. Safety depends on every consuming repo checking the intended ID.
- **`ROOT` is broad authority.** `ROOT` (ID `1`) grants all permissions, including permissions added in the future.
- **Wildcard grants increase blast radius.** Any permission granted with `projectId = 0` applies to all projects owned by that account.
- **Hook and router lock powers are bundled.** `SET_BUYBACK_HOOK` (`30`) and `SET_ROUTER_TERMINAL` (`31`) both cover setting and locking.
- **Third-party extensions do not have an on-chain namespace.** IDs `41-255` are only socially coordinated, so external packages can collide without coordination.

## 2. High-Impact IDs

- **Fund-moving IDs.** `CASH_OUT_TOKENS` (`4`), `SEND_PAYOUTS` (`5`), `MIGRATE_TERMINAL` (`6`), `SET_TERMINALS` (`15`), `USE_ALLOWANCE` (`18`), and `SET_SPLIT_GROUPS` (`19`) can redirect or release value.
- **Hook-routing IDs.** `SET_BUYBACK_POOL` (`28`), `SET_BUYBACK_HOOK` (`30`), and `SET_ROUTER_TERMINAL` (`31`) materially control execution routes and can lock those routes permanently.
- **Revnet loan IDs.** `OPEN_LOAN` (`37`), `REALLOCATE_LOAN` (`38`), and `REPAY_LOAN` (`39`) are operationally powerful because they move collateral and debt state.

## 3. Integration Risks

- **Docs can lag deployed assumptions.** Off-chain tooling, UIs, and audits often rely on human-readable permission names.
- **Cross-package imports must stay canonical.** Downstream repos should import this library instead of redefining numeric literals locally.
- **Future IDs expand current `ROOT` power.** Any new permission automatically becomes available to existing `ROOT` operators.

## 4. Invariants To Verify

- Assigned IDs are append-only and never repurposed.
- `0` stays unused as a permission ID.
- Every documented ID in this repo matches the numeric checks in downstream contracts.
- New IDs added after `40` do not collide with existing ecosystem assignments.

## 5. Accepted Behaviors

### 5.1 This repo is coordination infrastructure, not an enforcement layer

`JBPermissionIds` intentionally has no access control, storage, or runtime checks. The repo matters because every other package can import the same constants and mean the same thing.
