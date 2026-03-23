# Administration

Admin privileges and their scope in nana-permission-ids-v6.

## Overview

This repo defines permission ID constants. It contains no admin functions itself -- it is a reference library for the permission system used across the Juicebox V6 ecosystem. The constants in `JBPermissionIds` are consumed by contracts in nana-core-v6, nana-721-hook-v6, nana-buyback-hook-v6, nana-router-terminal-v6, and nana-suckers-v6 to gate privileged operations.

There are no ownable contracts, no upgrade mechanisms, and no mutable state. The library compiles to inline constants.

## Permission IDs

All 33 defined permission IDs and what they control:

| ID | Constant | Used By | What It Controls |
|----|----------|---------|-----------------|
| 1 | `ROOT` | All contracts (via `JBPermissions`) | Grants every permission. See [ROOT Permission](#root-permission). |
| 2 | `QUEUE_RULESETS` | nana-core (`JBController`) | `JBController.queueRulesetsOf` -- queue new rulesets for a project. |
| 3 | `LAUNCH_RULESETS` | nana-core (`JBController`) | `JBController.launchRulesetsFor` -- launch a project's initial rulesets. Also requires `SET_TERMINALS` (ID 15). |
| 4 | `CASH_OUT_TOKENS` | nana-core (`JBMultiTerminal`) | `JBMultiTerminal.cashOutTokensOf` -- redeem tokens for surplus. Checked against the **token holder**, not the project owner. |
| 5 | `SEND_PAYOUTS` | nana-core (`JBMultiTerminal`) | `JBMultiTerminal.sendPayoutsOf` -- distribute payouts to splits. |
| 6 | `MIGRATE_TERMINAL` | nana-core (`JBMultiTerminal`) | `JBMultiTerminal.migrateBalanceOf` -- migrate a project's balance to another terminal. |
| 7 | `SET_PROJECT_URI` | nana-core (`JBController`) | `JBController.setUriOf` -- set project metadata URI. |
| 8 | `DEPLOY_ERC20` | nana-core (`JBController`) | `JBController.deployERC20For` -- deploy a new ERC-20 token for a project. |
| 9 | `SET_TOKEN` | nana-core (`JBController`) | `JBController.setTokenFor` -- set an existing ERC-20 token for a project. |
| 10 | `MINT_TOKENS` | nana-core (`JBController`) | `JBController.mintTokensOf` -- mint new project tokens. Only effective when the current ruleset allows owner minting. |
| 11 | `BURN_TOKENS` | nana-core (`JBController`) | `JBController.burnTokensOf` -- burn tokens. Checked against the **token holder**. |
| 12 | `CLAIM_TOKENS` | nana-core (`JBController`) | `JBController.claimTokensFor` -- claim internal credits as ERC-20. Checked against the **token holder**. |
| 13 | `TRANSFER_CREDITS` | nana-core (`JBController`) | `JBController.transferCreditsFrom` -- transfer internal credits. Checked against the **token holder**. |
| 14 | `SET_CONTROLLER` | nana-core (`JBDirectory`) | `JBDirectory.setControllerOf` -- set a project's controller. |
| 15 | `SET_TERMINALS` | nana-core (`JBDirectory`) | `JBDirectory.setTerminalsOf` -- set a project's terminals. **Warning:** can remove the primary terminal. |
| 16 | `SET_PRIMARY_TERMINAL` | nana-core (`JBDirectory`) | `JBDirectory.setPrimaryTerminalOf` -- set the primary terminal for a token. |
| 17 | `USE_ALLOWANCE` | nana-core (`JBMultiTerminal`) | `JBMultiTerminal.useAllowanceOf` -- spend surplus allowance to an arbitrary address. |
| 18 | `SET_SPLIT_GROUPS` | nana-core (`JBController`) | `JBController.setSplitGroupsOf` -- configure payout and reserved token splits. |
| 19 | `ADD_PRICE_FEED` | nana-core (`JBController`) | `JBController.addPriceFeedFor` (which internally calls `JBPrices.addPriceFeedFor`) -- add a price feed for a project. |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | nana-core (`JBMultiTerminal`) | `JBMultiTerminal.addAccountingContextsFor` -- add accepted tokens to a terminal. |
| 21 | `SET_TOKEN_METADATA` | nana-core (`JBController`) | `JBController.setTokenMetadataOf` -- set a project token's name and symbol. |
| 22 | `ADJUST_721_TIERS` | nana-721-hook (`JB721TiersHook`) | `JB721TiersHook.adjustTiers` -- add or remove NFT tiers. |
| 23 | `SET_721_METADATA` | nana-721-hook (`JB721TiersHook`) | `JB721TiersHook.setMetadata` -- set NFT metadata URIs. |
| 24 | `MINT_721` | nana-721-hook (`JB721TiersHook`) | `JB721TiersHook.mintFor` -- manually mint NFTs to a beneficiary. |
| 25 | `SET_721_DISCOUNT_PERCENT` | nana-721-hook (`JB721TiersHook`) | `JB721TiersHook.setDiscountPercentOf` -- set discount percent on NFT tiers. |
| 26 | `SET_BUYBACK_TWAP` | nana-buyback-hook (`JBBuybackHook`) | `JBBuybackHook.setTwapWindowOf` -- configure the TWAP oracle window. |
| 27 | `SET_BUYBACK_POOL` | nana-buyback-hook (`JBBuybackHook`) | `JBBuybackHook.setPoolFor` -- set the Uniswap pool for buybacks. |
| 28 | `SET_BUYBACK_HOOK` | nana-buyback-hook (`JBBuybackHookRegistry`) | `JBBuybackHookRegistry.setHookFor` and `lockHookFor` -- configure and permanently lock the buyback hook. |
| 29 | `SET_ROUTER_TERMINAL` | nana-router-terminal (`JBRouterTerminalRegistry`) | `JBRouterTerminalRegistry.setTerminalFor` and `lockTerminalFor` -- configure and permanently lock the router terminal. |
| 30 | `MAP_SUCKER_TOKEN` | nana-suckers (`JBSucker`) | `JBSucker.mapToken` -- map an ERC-20 to its remote chain counterpart. Immutable once the outbox tree has entries. |
| 31 | `DEPLOY_SUCKERS` | nana-suckers (`JBSuckerRegistry`) | `JBSuckerRegistry.deploySuckersFor` -- deploy sucker contracts for cross-chain bridging. |
| 32 | `SUCKER_SAFETY` | nana-suckers (`JBSucker`) | `JBSucker.enableEmergencyHatchFor` -- enable the emergency hatch to recover stuck tokens. |
| 33 | `SET_SUCKER_DEPRECATION` | nana-suckers (`JBSucker`) | `JBSucker.setDeprecation` -- set deprecation status (ENABLED, DEPRECATION_PENDING, SENDING_DISABLED, DEPRECATED). |

IDs 0 and 34-255 are unused. ID 0 is reserved and cannot be set. IDs 34-255 are available for future ecosystem extensions.

## ROOT Permission

`ROOT` (ID 1) is a superuser permission. When an operator has ROOT for a given project, `JBPermissions` treats every permission check as passing for that project. It is the only permission that grants blanket access.

Restrictions enforced by `JBPermissions`:

- **Cannot be granted for the wildcard project ID (0).** Attempting to set ROOT with `projectId = 0` reverts with `JBPermissions_CantSetRootPermissionForWildcardProject()`. This prevents a single operator from controlling all projects owned by an account.
- **ROOT operators cannot grant ROOT to others.** A ROOT operator can call `setPermissionsFor` on behalf of the account, but the new permission set must not include ROOT and must not target the wildcard project ID.
- **ROOT is scoped per project.** Having ROOT for project 5 does not grant any permissions for project 6.

## Wildcard Project ID

When permissions are granted with `projectId = 0`, they apply to **every project** owned by the granting account. This is checked by `JBPermissions` as a fallback: if the operator does not have a specific permission for the target project, the contract checks whether the operator has that permission for `projectId = 0`.

ROOT cannot be set for the wildcard project ID. All other permissions can.

## How Permissions Are Checked

Permissions are stored in `JBPermissions` as a 256-bit packed integer per (operator, account, projectId) tuple:

```
permissionsOf[operator][account][projectId] => uint256 (packed bits)
```

Each bit position corresponds to a permission ID. When a contract checks whether an operator has a permission, it calls `JBPermissions.hasPermission(operator, account, projectId, permissionId, includeRoot, includeWildcardProjectId)`, which:

1. Checks whether the operator has ROOT (bit 1) for the specific project -- if so, returns true.
2. If `includeWildcardProjectId`, checks whether the operator has ROOT (bit 1) for the wildcard project (`projectId = 0`) -- if so, returns true.
3. Checks whether the specific permission bit is set for the specific project -- if so, returns true.
4. If `includeWildcardProjectId`, checks whether the specific permission bit is set for the wildcard project (`projectId = 0`) -- if so, returns true.

Steps 1-2 are skipped if `includeRoot` is false. Steps 2 and 4 are skipped if `includeWildcardProjectId` is false.

Contracts that use this system inherit from `JBPermissioned`, which provides the `_requirePermissionFrom(account, projectId, permissionId)` modifier. This modifier passes if the caller is the account itself or has the required permission via `JBPermissions`.

## High-Risk Permissions

Some permissions warrant extra caution when granting:

- **`ROOT` (1):** Full access to all gated functions for a project.
- **`SET_TERMINALS` (15):** Can remove the primary terminal, breaking payments and cashouts.
- **`USE_ALLOWANCE` (17):** Can send surplus funds to any address.
- **`SET_BUYBACK_HOOK` (28):** Can permanently lock the buyback hook configuration.
- **`SET_ROUTER_TERMINAL` (29):** Can permanently lock the router terminal configuration.
- **`MINT_TOKENS` (10):** Can inflate token supply (subject to ruleset allowing owner minting).

## Holder vs. Owner Permissions

Most permissions are checked against the **project owner** (the account that owns the project NFT). Four permissions are instead checked against the **token holder**:

| Permission | Checked Against |
|-----------|----------------|
| `CASH_OUT_TOKENS` (4) | Token holder |
| `BURN_TOKENS` (11) | Token holder |
| `CLAIM_TOKENS` (12) | Token holder |
| `TRANSFER_CREDITS` (13) | Token holder |

This means a token holder can grant an operator permission to cash out, burn, claim, or transfer their own tokens -- independent of the project owner's permissions.
