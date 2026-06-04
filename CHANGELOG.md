# V5 to V6 Changelog

## Scope

This is a V5-to-V6 migration changelog, not a package release log or commit history. It compares `nana-permission-ids-v5` in `../../v5/evm` with the current `nana-permission-ids-v6` repo.

## Current V6 Surface

- `JBPermissionIds`

## Summary

- The numeric permission map changed. Any V5 code that hardcodes IDs must be updated.
- `QUEUE_RULESETS` no longer also authorizes `launchRulesetsFor`; V6 adds a dedicated `LAUNCH_RULESETS`.
- Router terminal permissions replace the V5 swap-terminal permissions.
- V6 adds permissions for token metadata, ERC-1271 signing, buyback-hook selection, explicit sucker peers, sucker deprecation, and revnet loan operators.

## ABI, Event, and Error Changes

- This package is a Solidity library of constants; it has no runtime events or custom errors.
- Migration-sensitive constant shifts:
  - `QUEUE_RULESETS` remains ID `2`, but no longer covers launch.
  - `LAUNCH_RULESETS` is new at ID `3`.
  - Core permissions after ID `2` shifted up because of `LAUNCH_RULESETS`.
  - `SET_TOKEN_METADATA` is ID `22`.
  - `SIGN_FOR_ERC20` is ID `23`.
  - 721 hook permissions now occupy IDs `24-27`.
  - buyback permissions now occupy IDs `28-30`.
  - `SET_ROUTER_TERMINAL` is ID `31`.
  - sucker permissions now occupy IDs `32-36`.
  - revnet loan operator permissions are `OPEN_LOAN` ID `37`, `REALLOCATE_LOAN` ID `38`, and `REPAY_LOAN` ID `39`.
- Removed V5 swap-terminal constants:
  - `ADD_SWAP_TERMINAL_POOL`
  - `ADD_SWAP_TERMINAL_TWAP_PARAMS`

## Machine-Checked ABI Coverage

Generated from Foundry `out/**/*.json` artifacts, filtered to this repo's own runtime source roots and excluding tests, scripts, and dependencies.

- V5 comparison package: `nana-permission-ids-v5`.
- Own-source ABI artifacts compared: V6 `1`, V5 `1`.
- Contract/interface coverage: `0` added, `0` removed, `0` shared names with ABI changes, `1` shared names ABI-identical.
- Shared-name ABI item deltas: `0` added, `0` removed, `0` modified.

Shared ABI artifacts checked with no ABI item changes:
- `JBPermissionIds`.

## Migration Notes

- Do not copy numeric constants from V5. Import `JBPermissionIds` from the V6 package.
- Re-audit operator grants before migration. A numeric ID that meant one action in V5 can authorize a different action in V6.
- Update launch automation to request `LAUNCH_RULESETS` where it previously relied on `QUEUE_RULESETS`.
