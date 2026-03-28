# nana-permission-ids-v6 Changelog (v5 → v6)

This document describes all changes between `nana-permission-ids` (v5) and `nana-permission-ids-v6` (v6).

## Summary

- **All numeric IDs shifted** — the insertion of `LAUNCH_RULESETS` at ID 3 cascades through every subsequent permission. Any code using hardcoded numeric values will break.
- **Two permissions split**: `QUEUE_RULESETS` → `QUEUE_RULESETS` + `LAUNCH_RULESETS`; `SUCKER_SAFETY` → `SUCKER_SAFETY` + `SET_SUCKER_DEPRECATION`.
- **5 new permissions** added: `LAUNCH_RULESETS` (3), `SET_TOKEN_METADATA` (21), `SET_BUYBACK_HOOK` (28), `SET_ROUTER_TERMINAL` (29), `SET_SUCKER_DEPRECATION` (33).
- **2 swap terminal permissions removed**: `ADD_SWAP_TERMINAL_POOL` and `ADD_SWAP_TERMINAL_TWAP_PARAMS` (swap terminal replaced by router terminal).

## ABI Status

This repo does not introduce a runtime contract ABI migration in the same way the protocol repos do.

What changed instead:
- the exported constants set changed;
- numeric meanings shifted;
- downstream contracts now gate functions using different permission IDs.

So the migration work here is at compile-time and application-logic level, not at the level of emitted runtime events or callable function selectors.

> **⚠️ WARNING: All numeric permission IDs have shifted.** If your contracts, scripts, or frontends hardcode permission ID numbers (e.g., `permissions.setPermissionsFor(..., 3, ...)` for `CASH_OUT_TOKENS`), they MUST be updated. `CASH_OUT_TOKENS` moved from 3 → 4, `SEND_PAYOUTS` from 4 → 5, and so on. Always reference the named constants from `JBPermissionIds` rather than raw numbers.

---

## 1. Breaking Changes

### All numeric IDs shifted

The insertion of `LAUNCH_RULESETS` at ID 3 pushed every subsequent permission ID up by one. Additional new permissions at the end of each section caused further shifts. **Any code that hardcodes numeric permission values will break.**

| Permission | v5 ID | v6 ID |
|---|---|---|
| `ROOT` | 1 | 1 |
| `QUEUE_RULESETS` | 2 | 2 |
| `CASH_OUT_TOKENS` | 3 | 4 |
| `SEND_PAYOUTS` | 4 | 5 |
| `MIGRATE_TERMINAL` | 5 | 6 |
| `SET_PROJECT_URI` | 6 | 7 |
| `DEPLOY_ERC20` | 7 | 8 |
| `SET_TOKEN` | 8 | 9 |
| `MINT_TOKENS` | 9 | 10 |
| `BURN_TOKENS` | 10 | 11 |
| `CLAIM_TOKENS` | 11 | 12 |
| `TRANSFER_CREDITS` | 12 | 13 |
| `SET_CONTROLLER` | 13 | 14 |
| `SET_TERMINALS` | 14 | 15 |
| `SET_PRIMARY_TERMINAL` | 15 | 16 |
| `USE_ALLOWANCE` | 16 | 17 |
| `SET_SPLIT_GROUPS` | 17 | 18 |
| `ADD_PRICE_FEED` | 18 | 19 |
| `ADD_ACCOUNTING_CONTEXTS` | 19 | 20 |
| `ADJUST_721_TIERS` | 20 | 22 |
| `SET_721_METADATA` | 21 | 23 |
| `MINT_721` | 22 | 24 |
| `SET_721_DISCOUNT_PERCENT` | 23 | 25 |
| `SET_BUYBACK_TWAP` | 24 | 26 |
| `SET_BUYBACK_POOL` | 25 | 27 |
| `MAP_SUCKER_TOKEN` | 28 | 30 |
| `DEPLOY_SUCKERS` | 29 | 31 |
| `SUCKER_SAFETY` | 30 | 32 |

### `QUEUE_RULESETS` split into two permissions

In v5, `QUEUE_RULESETS` (2) granted permission to call both `JBController.queueRulesetsOf` and `JBController.launchRulesetsFor`. In v6, these are separate:

- `QUEUE_RULESETS` (2) -- only `JBController.queueRulesetsOf`
- `LAUNCH_RULESETS` (3) -- only `JBController.launchRulesetsFor`

> **Cross-repo impact**: `nana-core-v6` (`JBController.launchRulesetsFor`) now requires `LAUNCH_RULESETS` instead of `QUEUE_RULESETS`. `nana-omnichain-deployers-v6` and `revnet-core-v6` both use the new `LAUNCH_RULESETS` permission.

### `SUCKER_SAFETY` split into two permissions

In v5, `SUCKER_SAFETY` (30) granted permission to call both `BPSucker.enableEmergencyHatchFor` and `BPSucker.setDeprecation`. In v6, these are separate:

- `SUCKER_SAFETY` (32) -- only `JBSucker.enableEmergencyHatchFor`
- `SET_SUCKER_DEPRECATION` (33) -- only `JBSucker.setDeprecation`

### Swap terminal permissions removed

The following permissions from `nana-swap-terminal` no longer exist in v6:

| Removed | v5 ID | Notes |
|---|---|---|
| `ADD_SWAP_TERMINAL_POOL` | 26 | Was for `JBSwapTerminal.addDefaultPool` |
| `ADD_SWAP_TERMINAL_TWAP_PARAMS` | 27 | Was for `JBSwapTerminal.addTwapParamsFor` |

> **Cross-repo impact**: `nana-router-terminal-v6` (the replacement for swap terminal) uses the new `SET_ROUTER_TERMINAL` (29) permission instead.

### Contract prefix rename (suckers)

Sucker contract references changed from `BP*` to `JB*`:

- `BPSucker` → `JBSucker`
- `BPSuckerRegistry` → `JBSuckerRegistry`

### `SET_BUYBACK_TWAP` comment narrowed

In v5, the comment stated this gates both `JBBuybackHook.setTwapWindowOf` and `JBBuybackHook.setTwapSlippageToleranceOf`. In v6, the comment only mentions `JBBuybackHook.setTwapWindowOf`.

---

## 2. New Features

### `LAUNCH_RULESETS` (3)

New permission split from `QUEUE_RULESETS`. Gates `JBController.launchRulesetsFor` independently.

### `SET_TOKEN_METADATA` (21)

New core permission. Gates `JBController.setMetadataOf` for setting project token metadata.

### `SET_BUYBACK_HOOK` (28)

New buyback hook permission. Gates both `JBBuybackHookRegistry.setHookFor` and `JBBuybackHookRegistry.lockHookFor`. Note: granting this permission allows the operator to permanently lock the hook configuration.

### `SET_ROUTER_TERMINAL` (29)

New router terminal permission. Gates both `JBRouterTerminalRegistry.setTerminalFor` and `JBRouterTerminalRegistry.lockTerminalFor`. Note: granting this permission allows the operator to permanently lock the terminal configuration.

### `SET_SUCKER_DEPRECATION` (33)

New permission split from `SUCKER_SAFETY`. Gates `JBSucker.setDeprecation` independently.

---

## 3. What Integrators Should Change

In practice, permission-ID migrations usually fail in one of four places:
- Solidity code that passes raw numeric arrays into `setPermissionsFor(...)`
- deployment scripts that serialize permission IDs as literals
- frontends that label permissions by number instead of by constant name
- indexers/admin tools that assume the old operator-capability mapping

Search targets worth checking:
- `setPermissionsFor`
- `hasPermission`
- raw arrays like `[2,3,4]`
- literals previously used for swap-terminal permissions (`26`, `27`)
- any custom admin UI copy that still says `swap terminal` instead of `router terminal`

High-risk behavioral changes:
- `QUEUE_RULESETS` no longer implies launch permission; launch now needs `LAUNCH_RULESETS`.
- `SUCKER_SAFETY` no longer implies deprecation permission; deprecation now needs `SET_SUCKER_DEPRECATION`.
- There is no direct numeric replacement for `ADD_SWAP_TERMINAL_POOL` / `ADD_SWAP_TERMINAL_TWAP_PARAMS`; the admin model changed with router-terminal registry control.

## 4. Migration Table

| v5 Name | v5 ID | v6 Name | v6 ID | Change |
|---|---|---|---|---|
| `ROOT` | 1 | `ROOT` | 1 | Unchanged |
| `QUEUE_RULESETS` | 2 | `QUEUE_RULESETS` | 2 | Narrowed (no longer includes launch) |
| -- | -- | `LAUNCH_RULESETS` | 3 | **New** (split from `QUEUE_RULESETS`) |
| `CASH_OUT_TOKENS` | 3 | `CASH_OUT_TOKENS` | 4 | ID changed |
| `SEND_PAYOUTS` | 4 | `SEND_PAYOUTS` | 5 | ID changed |
| `MIGRATE_TERMINAL` | 5 | `MIGRATE_TERMINAL` | 6 | ID changed |
| `SET_PROJECT_URI` | 6 | `SET_PROJECT_URI` | 7 | ID changed |
| `DEPLOY_ERC20` | 7 | `DEPLOY_ERC20` | 8 | ID changed |
| `SET_TOKEN` | 8 | `SET_TOKEN` | 9 | ID changed |
| `MINT_TOKENS` | 9 | `MINT_TOKENS` | 10 | ID changed |
| `BURN_TOKENS` | 10 | `BURN_TOKENS` | 11 | ID changed |
| `CLAIM_TOKENS` | 11 | `CLAIM_TOKENS` | 12 | ID changed |
| `TRANSFER_CREDITS` | 12 | `TRANSFER_CREDITS` | 13 | ID changed |
| `SET_CONTROLLER` | 13 | `SET_CONTROLLER` | 14 | ID changed |
| `SET_TERMINALS` | 14 | `SET_TERMINALS` | 15 | ID changed |
| `SET_PRIMARY_TERMINAL` | 15 | `SET_PRIMARY_TERMINAL` | 16 | ID changed |
| `USE_ALLOWANCE` | 16 | `USE_ALLOWANCE` | 17 | ID changed |
| `SET_SPLIT_GROUPS` | 17 | `SET_SPLIT_GROUPS` | 18 | ID changed |
| `ADD_PRICE_FEED` | 18 | `ADD_PRICE_FEED` | 19 | ID changed |
| `ADD_ACCOUNTING_CONTEXTS` | 19 | `ADD_ACCOUNTING_CONTEXTS` | 20 | ID changed |
| -- | -- | `SET_TOKEN_METADATA` | 21 | **New** |
| `ADJUST_721_TIERS` | 20 | `ADJUST_721_TIERS` | 22 | ID changed |
| `SET_721_METADATA` | 21 | `SET_721_METADATA` | 23 | ID changed |
| `MINT_721` | 22 | `MINT_721` | 24 | ID changed |
| `SET_721_DISCOUNT_PERCENT` | 23 | `SET_721_DISCOUNT_PERCENT` | 25 | ID changed |
| `SET_BUYBACK_TWAP` | 24 | `SET_BUYBACK_TWAP` | 26 | ID changed, comment narrowed |
| `SET_BUYBACK_POOL` | 25 | `SET_BUYBACK_POOL` | 27 | ID changed |
| `ADD_SWAP_TERMINAL_POOL` | 26 | -- | -- | **Removed** |
| `ADD_SWAP_TERMINAL_TWAP_PARAMS` | 27 | -- | -- | **Removed** |
| -- | -- | `SET_BUYBACK_HOOK` | 28 | **New** |
| -- | -- | `SET_ROUTER_TERMINAL` | 29 | **New** |
| `MAP_SUCKER_TOKEN` | 28 | `MAP_SUCKER_TOKEN` | 30 | ID changed, `BPSucker` → `JBSucker` |
| `DEPLOY_SUCKERS` | 29 | `DEPLOY_SUCKERS` | 31 | ID changed, `BPSuckerRegistry` → `JBSuckerRegistry` |
| `SUCKER_SAFETY` | 30 | `SUCKER_SAFETY` | 32 | ID changed, narrowed (no longer includes deprecation) |
| -- | -- | `SET_SUCKER_DEPRECATION` | 33 | **New** (split from `SUCKER_SAFETY`) |
