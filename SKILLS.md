# nana-permission-ids-v6

## Purpose

Defines all `uint8` permission ID constants used across the Juicebox V6 ecosystem, passed to `JBPermissions.setPermissionsFor()` to grant scoped access to protocol functions.

## Contracts

| Contract | Role |
|----------|------|
| `JBPermissionIds` | Constants-only library. No state, no functions. Pragma `^0.8.0` for maximum compatibility. |

## Key Functions

N/A -- this is a constants-only library with no callable functions.

## All Permission IDs

| ID | Name | Grants access to |
|----|------|-----------------|
| 1 | `ROOT` | All permissions across every contract. |
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` |
| 16 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` |
| 17 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` |
| 18 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` |
| 19 | `ADD_PRICE_FEED` | `JBPrices.addPriceFeedFor` |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` |
| 21 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` |
| 22 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` |
| 23 | `MINT_721` | `JB721TiersHook.mintFor` |
| 24 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` |
| 25 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf`, `setTwapSlippageToleranceOf` |
| 26 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor` |
| 27 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor`, `lockHookFor` |
| 28 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor`, `lockTerminalFor` |
| 29 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` |
| 30 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` |
| 31 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` |
| 32 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` |

## Integration Points

| Dependency | Import | Used For |
|------------|--------|----------|
| None | -- | This library has no dependencies. It is imported by all permission-gated Juicebox contracts. |

## Key Types

N/A -- no structs or enums.

## Gotchas

- `ROOT` (ID 1) grants all permissions across every contract. Must be granted with extreme care.
- `SET_TERMINALS` (ID 15) can be used to remove the primary terminal -- the comment in the source warns about this.
- Permissions are scoped by `(operator, account, projectId)` tuple. Granting with `projectId=0` is a wildcard that applies to all projects for that account.
- The `uint8` type limits IDs to 0--255. Currently 32 are defined (1--32).

## Example Integration

```solidity
import {JBPermissionIds} from "@bananapus/permission-ids-v6/src/JBPermissionIds.sol";

// Grant an operator permission to queue rulesets for project 5
uint8[] memory permissionIds = new uint8[](1);
permissionIds[0] = JBPermissionIds.QUEUE_RULESETS;
permissions.setPermissionsFor(account, JBPermissionsData({
    operator: operatorAddress,
    projectId: 5,
    permissionIds: permissionIds
}));
```
