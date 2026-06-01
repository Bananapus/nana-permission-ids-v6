# Changelog

## 0.0.29

- Raise dependency floors to the latest published versions; document NatSpec, comment, and lint conventions in STYLE_GUIDE.

## Scope

This file describes the verified change from `nana-permission-ids-v5` to the current `nana-permission-ids-v6` repo.

## Current v6 surface

- `JBPermissionIds`

## Summary

- The numeric permission map shifted. `LAUNCH_RULESETS` was inserted near the top of the sequence and every downstream numeric value moved with it.
- v6 adds permissions for capabilities that did not exist in the old map, including `LAUNCH_RULESETS`, `ADD_TERMINALS`, `SET_TOKEN_METADATA`, `SET_BUYBACK_HOOK`, `SET_ROUTER_TERMINAL`, and `SET_SUCKER_DEPRECATION`.
- The old swap-terminal-specific permissions are gone because the deployed ecosystem no longer centers on `nana-swap-terminal-v5`.
- `SUCKER_SAFETY` no longer covers every safety action by itself. `SET_SUCKER_DEPRECATION` is its own permission in v6.

## v6 additions: nana-core ERC-1271 delegation (ID 23)

- `SIGN_FOR_ERC20` (23) — sign messages on behalf of a project's ERC-20 token via ERC-1271. Used for Etherscan contract verification and other off-chain signature validation.

## v6 additions: nana-suckers explicit-peer permission (ID 34)

- `SET_SUCKER_PEER` (34) — authorize registering a non-symmetric explicit `peer` address when calling `JBSuckerRegistry.deploySuckersFor`. Intentionally narrower than `DEPLOY_SUCKERS` so ops automation that holds `DEPLOY_SUCKERS` cannot register attacker-controlled peers. Loan IDs `OPEN_LOAN`, `REALLOCATE_LOAN`, and `REPAY_LOAN` shifted by one to `37`, `38`, `39`.

## v6 additions: revnet-core delegation

- `OPEN_LOAN` — open a loan on behalf of a token holder via `REVLoans.borrowFrom`. Checked against the token holder.
- `REALLOCATE_LOAN` — reallocate loan collateral on behalf of a loan NFT owner via `REVLoans.reallocateCollateralFromLoan`. Checked against the loan NFT owner.
- `REPAY_LOAN` — repay a loan on behalf of a loan NFT owner via `REVLoans.repayLoan`. Checked against the loan NFT owner.

These are consumed by `revnet-core-v6` and checked via inline `PERMISSIONS.hasPermission` calls (for `REVLoans`).

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
