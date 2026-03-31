# nana-permission-ids-v6 Changelog (v5 → v6)

This document describes all changes between `nana-permission-ids` (v5) and `nana-permission-ids-v6` (v6).

## Summary

- **All numeric IDs shifted** — the insertion of `LAUNCH_RULESETS` at ID 3 cascades through every subsequent permission. Any code using hardcoded numeric values will break.
- **Two permissions split**: `QUEUE_RULESETS` → `QUEUE_RULESETS` + `LAUNCH_RULESETS`; `SUCKER_SAFETY` → `SUCKER_SAFETY` + `SET_SUCKER_DEPRECATION`.
- **6 new permissions** added: `LAUNCH_RULESETS` (3), `ADD_TERMINALS` (16), `SET_TOKEN_METADATA` (22), `SET_BUYBACK_HOOK` (29), `SET_ROUTER_TERMINAL` (30), `SET_SUCKER_DEPRECATION` (34).
- **2 swap terminal permissions removed**: `ADD_SWAP_TERMINAL_POOL` and `ADD_SWAP_TERMINAL_TWAP_PARAMS` (swap terminal replaced by router terminal).

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
| `SET_PRIMARY_TERMINAL` | 15 | 17 |
| `USE_ALLOWANCE` | 16 | 18 |
| `SET_SPLIT_GROUPS` | 17 | 19 |
| `ADD_PRICE_FEED` | 18 | 20 |
| `ADD_ACCOUNTING_CONTEXTS` | 19 | 21 |
| `ADJUST_721_TIERS` | 20 | 23 |
| `SET_721_METADATA` | 21 | 24 |
| `MINT_721` | 22 | 25 |
| `SET_721_DISCOUNT_PERCENT` | 23 | 26 |
| `SET_BUYBACK_TWAP` | 24 | 27 |
| `SET_BUYBACK_POOL` | 25 | 28 |
| `MAP_SUCKER_TOKEN` | 28 | 31 |
| `DEPLOY_SUCKERS` | 29 | 32 |
| `SUCKER_SAFETY` | 30 | 33 |

### `QUEUE_RULESETS` split into two permissions

In v5, `QUEUE_RULESETS` (2) granted permission to call both `JBController.queueRulesetsOf` and `JBController.launchRulesetsFor`. In v6, these are separate:

- `QUEUE_RULESETS` (2) -- only `JBController.queueRulesetsOf`
- `LAUNCH_RULESETS` (3) -- only `JBController.launchRulesetsFor`

> **Cross-repo impact**: `nana-core-v6` (`JBController.launchRulesetsFor`) now requires `LAUNCH_RULESETS` instead of `QUEUE_RULESETS`. `nana-omnichain-deployers-v6` and `revnet-core-v6` both use the new `LAUNCH_RULESETS` permission.

### `SUCKER_SAFETY` split into two permissions

In v5, `SUCKER_SAFETY` (30) granted permission to call both `BPSucker.enableEmergencyHatchFor` and `BPSucker.setDeprecation`. In v6, these are separate:

- `SUCKER_SAFETY` (33) -- only `JBSucker.enableEmergencyHatchFor`
- `SET_SUCKER_DEPRECATION` (34) -- only `JBSucker.setDeprecation`

### Swap terminal permissions removed

The following permissions from `nana-swap-terminal` no longer exist in v6:

| Removed | v5 ID | Notes |
|---|---|---|
| `ADD_SWAP_TERMINAL_POOL` | 26 | Was for `JBSwapTerminal.addDefaultPool` |
| `ADD_SWAP_TERMINAL_TWAP_PARAMS` | 27 | Was for `JBSwapTerminal.addTwapParamsFor` |

> **Cross-repo impact**: `nana-router-terminal-v6` (the replacement for swap terminal) uses the new `SET_ROUTER_TERMINAL` (30) permission instead.

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

### `ADD_TERMINALS` (16)

New core permission. Gates `JBDirectory.setPrimaryTerminalOf` when it implicitly adds a new terminal that is not already in the project's terminal list. This is a narrower alternative to `SET_TERMINALS` (15), which replaces the entire terminal list.

### `SET_TOKEN_METADATA` (22)

New core permission. Gates `JBController.setTokenMetadataOf` for setting project token metadata.

### `SET_BUYBACK_HOOK` (29)

New buyback hook permission. Gates both `JBBuybackHookRegistry.setHookFor` and `JBBuybackHookRegistry.lockHookFor`. Note: granting this permission allows the operator to permanently lock the hook configuration.

### `SET_ROUTER_TERMINAL` (30)

New router terminal permission. Gates both `JBRouterTerminalRegistry.setTerminalFor` and `JBRouterTerminalRegistry.lockTerminalFor`. Note: granting this permission allows the operator to permanently lock the terminal configuration.

### `SET_SUCKER_DEPRECATION` (34)

New permission split from `SUCKER_SAFETY`. Gates `JBSucker.setDeprecation` independently.

---

## 3. Migration Table

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
| -- | -- | `ADD_TERMINALS` | 16 | **New** |
| `SET_PRIMARY_TERMINAL` | 15 | `SET_PRIMARY_TERMINAL` | 17 | ID changed |
| `USE_ALLOWANCE` | 16 | `USE_ALLOWANCE` | 18 | ID changed |
| `SET_SPLIT_GROUPS` | 17 | `SET_SPLIT_GROUPS` | 19 | ID changed |
| `ADD_PRICE_FEED` | 18 | `ADD_PRICE_FEED` | 20 | ID changed |
| `ADD_ACCOUNTING_CONTEXTS` | 19 | `ADD_ACCOUNTING_CONTEXTS` | 21 | ID changed |
| -- | -- | `SET_TOKEN_METADATA` | 22 | **New** |
| `ADJUST_721_TIERS` | 20 | `ADJUST_721_TIERS` | 23 | ID changed |
| `SET_721_METADATA` | 21 | `SET_721_METADATA` | 24 | ID changed |
| `MINT_721` | 22 | `MINT_721` | 25 | ID changed |
| `SET_721_DISCOUNT_PERCENT` | 23 | `SET_721_DISCOUNT_PERCENT` | 26 | ID changed |
| `SET_BUYBACK_TWAP` | 24 | `SET_BUYBACK_TWAP` | 27 | ID changed, comment narrowed |
| `SET_BUYBACK_POOL` | 25 | `SET_BUYBACK_POOL` | 28 | ID changed |
| `ADD_SWAP_TERMINAL_POOL` | 26 | -- | -- | **Removed** |
| `ADD_SWAP_TERMINAL_TWAP_PARAMS` | 27 | -- | -- | **Removed** |
| -- | -- | `SET_BUYBACK_HOOK` | 29 | **New** |
| -- | -- | `SET_ROUTER_TERMINAL` | 30 | **New** |
| `MAP_SUCKER_TOKEN` | 28 | `MAP_SUCKER_TOKEN` | 31 | ID changed, `BPSucker` → `JBSucker` |
| `DEPLOY_SUCKERS` | 29 | `DEPLOY_SUCKERS` | 32 | ID changed, `BPSuckerRegistry` → `JBSuckerRegistry` |
| `SUCKER_SAFETY` | 30 | `SUCKER_SAFETY` | 33 | ID changed, narrowed (no longer includes deprecation) |
| -- | -- | `SET_SUCKER_DEPRECATION` | 34 | **New** (split from `SUCKER_SAFETY`) |
