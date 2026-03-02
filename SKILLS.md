# nana-permission-ids-v5 — AI Reference

## Purpose

Defines all permission ID constants used across the Juicebox V5 ecosystem. These `uint8` values are passed to `JBPermissions.setPermissionsFor()` to grant scoped access to protocol functions.

## Contracts

### JBPermissionIds (src/JBPermissionIds.sol)
Solidity library. No state, no functions -- only `uint8 internal constant` declarations. Pragma `^0.8.0` for maximum compatibility.

## Entry Points

N/A -- this is a constants-only library with no callable functions.

## All Permission IDs

```solidity
uint8 ROOT = 1;                         // All permissions. Dangerous.
uint8 QUEUE_RULESETS = 2;               // JBController.queueRulesetsOf, launchRulesetsFor
uint8 CASH_OUT_TOKENS = 3;             // JBMultiTerminal.cashOutTokensOf
uint8 SEND_PAYOUTS = 4;                // JBMultiTerminal.sendPayoutsOf
uint8 MIGRATE_TERMINAL = 5;            // JBMultiTerminal.migrateBalanceOf
uint8 SET_PROJECT_URI = 6;             // JBController.setUriOf
uint8 DEPLOY_ERC20 = 7;                // JBController.deployERC20For
uint8 SET_TOKEN = 8;                   // JBController.setTokenFor
uint8 MINT_TOKENS = 9;                 // JBController.mintTokensOf
uint8 BURN_TOKENS = 10;                // JBController.burnTokensOf
uint8 CLAIM_TOKENS = 11;               // JBController.claimTokensFor
uint8 TRANSFER_CREDITS = 12;           // JBController.transferCreditsFrom
uint8 SET_CONTROLLER = 13;             // JBDirectory.setControllerOf
uint8 SET_TERMINALS = 14;              // JBDirectory.setTerminalsOf
uint8 SET_PRIMARY_TERMINAL = 15;       // JBDirectory.setPrimaryTerminalOf
uint8 USE_ALLOWANCE = 16;              // JBMultiTerminal.useAllowanceOf
uint8 SET_SPLIT_GROUPS = 17;           // JBController.setSplitGroupsOf
uint8 ADD_PRICE_FEED = 18;             // JBPrices.addPriceFeedFor
uint8 ADD_ACCOUNTING_CONTEXTS = 19;    // JBMultiTerminal.addAccountingContextsFor
uint8 ADJUST_721_TIERS = 20;           // JB721TiersHook.adjustTiers
uint8 SET_721_METADATA = 21;           // JB721TiersHook.setMetadata
uint8 MINT_721 = 22;                   // JB721TiersHook.mintFor
uint8 SET_721_DISCOUNT_PERCENT = 23;   // JB721TiersHook.setDiscountPercentOf
uint8 SET_BUYBACK_TWAP = 24;           // JBBuybackHook.setTwapWindowOf, setTwapSlippageToleranceOf
uint8 SET_BUYBACK_POOL = 25;           // JBBuybackHook.setPoolFor
uint8 ADD_SWAP_TERMINAL_POOL = 26;     // JBSwapTerminal.addDefaultPool
uint8 ADD_SWAP_TERMINAL_TWAP_PARAMS = 27; // JBSwapTerminal.addTwapParamsFor
uint8 MAP_SUCKER_TOKEN = 28;           // BPSucker.mapToken
uint8 DEPLOY_SUCKERS = 29;             // BPSuckerRegistry.deploySuckersFor
uint8 SUCKER_SAFETY = 30;              // BPSucker.enableEmergencyHatchFor, setDeprecation
```

## Integration Points

- **JBPermissions**: The core contract that stores permission grants. Operators check `hasPermission(operator, account, projectId, permissionId)`.
- **JBPermissioned**: Abstract modifier base. Contracts inherit this and call `_requirePermissionFrom(account, projectId, permissionId)`.
- **Every Juicebox V5 contract**: All permission-gated functions reference these constants.

## Key Patterns

- **ROOT (1) is special**: Grants all permissions across every contract. Must be granted with extreme care.
- **Scoped by project**: Permissions are granted per `(operator, account, projectId)` tuple. A permission for project 5 does not apply to project 6.
- **Wildcard projectId=0**: Granting a permission with `projectId=0` makes it apply to all projects for that account.
- **uint8 range**: Maximum of 256 permission IDs (0-255). Currently 30 are defined.
