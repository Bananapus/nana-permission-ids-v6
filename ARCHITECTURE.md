# nana-permission-ids-v6 — Architecture

## Purpose

Constants library defining permission IDs used throughout the Juicebox V6 ecosystem. These IDs are used with `JBPermissions` to control access to protocol functions.

## How Permissions Work

These IDs plug into `JBPermissions` in nana-core, which stores permissions as a 256-bit packed `uint256` — one bit per permission ID. Callers check access via `hasPermission(operator, account, projectId, permissionId)`. A project owner can grant any operator a set of permission IDs scoped to a specific project, or use `projectId = 0` as a wildcard to grant permissions across all projects.

## Permission Guards

`JBPermissions.setPermissionsFor` enforces three guard rules:

- **Permission 0 is reserved.** Setting bit 0 always reverts (`JBPermissions_NoZeroPermission`). This prevents accidental misuse of an uninitialized permission ID.
- **ROOT cannot be set via wildcard.** An operator with ROOT on a specific project cannot use `setPermissionsFor` with `projectId = 0` (wildcard). This prevents a single-project ROOT operator from escalating to all-project access (`JBPermissions_CantSetRootPermissionForWildcardProject`).
- **ROOT operators cannot grant ROOT to others.** Only the account itself can include `ROOT` (ID 1) in a `setPermissionsFor` call. A ROOT operator calling on behalf of the account will revert if the new permission set includes ROOT.

## Contract Map

```
src/
└── JBPermissionIds.sol — Library of uint8 permission ID constants
```

## Permission ID Registry

| ID | Name | Used By | Gated Function |
|----|------|---------|----------------|
| 1 | `ROOT` | nana-core | All permissions (dangerous) |
| 2 | `QUEUE_RULESETS` | nana-core | `JBController.queueRulesetsOf` |
| 3 | `LAUNCH_RULESETS` | nana-core | `JBController.launchRulesetsFor` |
| 4 | `CASH_OUT_TOKENS` | nana-core | `JBMultiTerminal.cashOutTokensOf` |
| 5 | `SEND_PAYOUTS` | nana-core | `JBMultiTerminal.sendPayoutsOf` |
| 6 | `MIGRATE_TERMINAL` | nana-core | `JBMultiTerminal.migrateBalanceOf` |
| 7 | `SET_PROJECT_URI` | nana-core | `JBController.setUriOf` |
| 8 | `DEPLOY_ERC20` | nana-core | `JBController.deployERC20For` |
| 9 | `SET_TOKEN` | nana-core | `JBController.setTokenFor` |
| 10 | `MINT_TOKENS` | nana-core | `JBController.mintTokensOf` |
| 11 | `BURN_TOKENS` | nana-core | `JBController.burnTokensOf` |
| 12 | `CLAIM_TOKENS` | nana-core | `JBController.claimTokensFor` |
| 13 | `TRANSFER_CREDITS` | nana-core | `JBController.transferCreditsFrom` |
| 14 | `SET_CONTROLLER` | nana-core | `JBDirectory.setControllerOf` |
| 15 | `SET_TERMINALS` | nana-core | `JBDirectory.setTerminalsOf` |
| 16 | `SET_PRIMARY_TERMINAL` | nana-core | `JBDirectory.setPrimaryTerminalOf` |
| 17 | `USE_ALLOWANCE` | nana-core | `JBMultiTerminal.useAllowanceOf` |
| 18 | `SET_SPLIT_GROUPS` | nana-core | `JBController.setSplitGroupsOf` |
| 19 | `ADD_PRICE_FEED` | nana-core | `JBController.addPriceFeed` |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | nana-core | `JBMultiTerminal.addAccountingContextsFor` |
| 21 | `SET_TOKEN_METADATA` | nana-core | `JBController.setTokenMetadataOf` |
| 22 | `ADJUST_721_TIERS` | nana-721-hook | `JB721TiersHook.adjustTiers` |
| 23 | `SET_721_METADATA` | nana-721-hook | `JB721TiersHook.setMetadata` |
| 24 | `MINT_721` | nana-721-hook | `JB721TiersHook.mintFor` |
| 25 | `SET_721_DISCOUNT_PERCENT` | nana-721-hook | `JB721TiersHook.setDiscountPercentOf` |
| 26 | `SET_BUYBACK_TWAP` | nana-buyback-hook | `JBBuybackHook.setTwapWindowOf` |
| 27 | `SET_BUYBACK_POOL` | nana-buyback-hook | `JBBuybackHook.setPoolFor` |
| 28 | `SET_BUYBACK_HOOK` | nana-buyback-hook | `JBBuybackHookRegistry.setHookFor` + `lockHookFor` |
| 29 | `SET_ROUTER_TERMINAL` | nana-router-terminal | `JBRouterTerminalRegistry.setTerminalFor` + `lockTerminalFor` |
| 30 | `MAP_SUCKER_TOKEN` | nana-suckers | `JBSucker.mapToken` |
| 31 | `DEPLOY_SUCKERS` | nana-suckers | `JBSuckerRegistry.deploySuckersFor` |
| 32 | `SUCKER_SAFETY` | nana-suckers | `JBSucker.enableEmergencyHatchFor` |
| 33 | `SET_SUCKER_DEPRECATION` | nana-suckers | `JBSucker.setDeprecation` |

## Dependencies

None — this is a leaf dependency with no imports.
