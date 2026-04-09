# Changelog

## Scope

This file describes the verified change from `nana-permission-ids-v5` to the current `nana-permission-ids-v6` repo.

## Current v6 surface

- `JBPermissionIds`

## Summary

- The numeric permission map shifted. `LAUNCH_RULESETS` was inserted near the top of the sequence and every downstream numeric value moved with it.
- v6 adds permissions for capabilities that did not exist in the old map, including `LAUNCH_RULESETS`, `ADD_TERMINALS`, `SET_TOKEN_METADATA`, `SET_BUYBACK_HOOK`, `SET_ROUTER_TERMINAL`, and `SET_SUCKER_DEPRECATION`.
- The old swap-terminal-specific permissions are gone because the deployed ecosystem no longer centers on `nana-swap-terminal-v5`.
- `SUCKER_SAFETY` no longer covers every safety action by itself. `SET_SUCKER_DEPRECATION` is its own permission in v6.

## v6 additions: revnet-core delegation (IDs 35–39)

- `HIDE_TOKENS` (35) — hide tokens on behalf of a holder via `REVHiddenTokens.hideTokensOf`. Checked against the token holder.
- `OPEN_LOAN` (36) — open a loan on behalf of a token holder via `REVLoans.borrowFrom`. Checked against the token holder.
- `REALLOCATE_LOAN` (37) — reallocate loan collateral on behalf of a loan NFT owner via `REVLoans.reallocateCollateralFromLoan`. Checked against the loan NFT owner.
- `REPAY_LOAN` (38) — repay a loan on behalf of a loan NFT owner via `REVLoans.repayLoan`. Checked against the loan NFT owner.
- `REVEAL_TOKENS` (39) — reveal hidden tokens on behalf of a holder via `REVHiddenTokens.revealTokensOf`. Checked against the token holder.

These are consumed by `revnet-core-v6` and checked via `JBPermissioned._requirePermissionFrom` (for `REVHiddenTokens`) or inline `PERMISSIONS.hasPermission` calls (for `REVLoans`).

## Verified deltas

- `QUEUE_RULESETS` no longer also covers `launchRulesetsFor`; `LAUNCH_RULESETS` is its own constant.
- `ADD_TERMINALS` was inserted between `SET_TERMINALS` and `SET_PRIMARY_TERMINAL`.
- `SET_TOKEN_METADATA`, `SET_BUYBACK_HOOK`, `SET_ROUTER_TERMINAL`, and `SET_SUCKER_DEPRECATION` are new constants.
- `ADD_SWAP_TERMINAL_POOL` and `ADD_SWAP_TERMINAL_TWAP_PARAMS` were removed.

## Breaking ABI changes

- There is no runtime contract ABI to port here.
- The breaking surface is compile-time and application-logic-level: constant names, meanings, and numeric values changed.

## Indexer impact

- None directly from this repo.
- Indirectly, any off-chain access-control model keyed to raw numeric IDs must be updated.

## Migration notes

- Hardcoded numeric permission IDs from v5 are stale and unsafe.
- Rebuild every permission check from the named v6 constants.
- Treat this repo as application-logic-critical even though it is not a large runtime surface.
