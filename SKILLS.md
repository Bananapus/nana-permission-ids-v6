# nana-permission-ids-v5

## Purpose

Defines all `uint8` permission ID constants used across the Juicebox V5 ecosystem, passed to `JBPermissions.setPermissionsFor()` to grant scoped access to protocol functions.

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
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf`, `launchRulesetsFor` |
| 3 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` |
| 4 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` |
| 5 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` |
| 6 | `SET_PROJECT_URI` | `JBController.setUriOf` |
| 7 | `DEPLOY_ERC20` | `JBController.deployERC20For` |
| 8 | `SET_TOKEN` | `JBController.setTokenFor` |
| 9 | `MINT_TOKENS` | `JBController.mintTokensOf` |
| 10 | `BURN_TOKENS` | `JBController.burnTokensOf` |
| 11 | `CLAIM_TOKENS` | `JBController.claimTokensFor` |
| 12 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` |
| 13 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` |
| 14 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` |
| 15 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` |
| 16 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` |
| 17 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` |
| 18 | `ADD_PRICE_FEED` | `JBPrices.addPriceFeedFor` |
| 19 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` |
| 20 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` |
| 21 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` |
| 22 | `MINT_721` | `JB721TiersHook.mintFor` |
| 23 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` |
| 24 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf`, `setTwapSlippageToleranceOf` |
| 25 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor` |
| 26 | `ADD_SWAP_TERMINAL_POOL` | `JBSwapTerminal.addDefaultPool` |
| 27 | `ADD_SWAP_TERMINAL_TWAP_PARAMS` | `JBSwapTerminal.addTwapParamsFor` |
| 28 | `MAP_SUCKER_TOKEN` | `BPSucker.mapToken` |
| 29 | `DEPLOY_SUCKERS` | `BPSuckerRegistry.deploySuckersFor` |
| 30 | `SUCKER_SAFETY` | `BPSucker.enableEmergencyHatchFor`, `setDeprecation` |

## Integration Points

| Dependency | Import | Used For |
|------------|--------|----------|
| None | -- | This library has no dependencies. It is imported by all permission-gated Juicebox contracts. |

## Key Types

N/A -- no structs or enums.

## Gotchas

- `ROOT` (ID 1) grants all permissions across every contract. Must be granted with extreme care.
- `SET_TERMINALS` (ID 14) can be used to remove the primary terminal -- the comment in the source warns about this.
- Permissions are scoped by `(operator, account, projectId)` tuple. Granting with `projectId=0` is a wildcard that applies to all projects for that account.
- The `uint8` type limits IDs to 0--255. Currently 30 are defined (1--30).

## Example Integration

```solidity
import {JBPermissionIds} from "@bananapus/permission-ids-v5/src/JBPermissionIds.sol";

// Grant an operator permission to queue rulesets for project 5
uint8[] memory permissionIds = new uint8[](1);
permissionIds[0] = JBPermissionIds.QUEUE_RULESETS;
permissions.setPermissionsFor(account, JBPermissionsData({
    operator: operatorAddress,
    projectId: 5,
    permissionIds: permissionIds
}));
```
