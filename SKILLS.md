# Juicebox Permission IDs

## Purpose

Defines all `uint8` permission ID constants used across the Juicebox V6 ecosystem. These IDs are passed to `JBPermissions.setPermissionsFor()` to grant scoped access to protocol functions. The library has no state, no functions, and no dependencies -- it exists solely so that every contract references the same numeric IDs by name.

## Contracts

| Contract | Role |
|----------|------|
| `JBPermissionIds` | Constants-only library. 33 `uint8 internal constant` values (1--33). Pragma `^0.8.0` for maximum compatibility across all Juicebox contracts. |

## Key Functions

N/A -- this is a constants-only library with no callable functions.

## How permissions work

Permissions are stored as 256-bit packed integers in `JBPermissions`, keyed by `[operator][account][projectId]`. ROOT (ID 1) passes all checks; `projectId = 0` grants cross-project access. See `nana-core-v6/SKILLS.md` for full permissions mechanics.

## All Permission IDs

### Global

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 1 | `ROOT` | `JBPermissions` (implicit) | All permissions across every contract. Checked as a fallback in `hasPermission()` and `hasPermissions()`. Cannot be granted for wildcard `projectId = 0`. A ROOT operator can call `setPermissionsFor` on behalf of the account but cannot grant ROOT to others or set wildcard permissions. |

### nana-core-v6

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` | Queue new rulesets. Checked against project owner. Also required by `JB721TiersHookProjectDeployer.queueRulesetsOf` and `JBOmnichainDeployer` functions. |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` | Launch initial rulesets. Checked against project owner. **Also requires `SET_TERMINALS` (ID 15)** since the function configures terminals. |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` | Cash out tokens for surplus. Checked against the **token holder** (not the project owner). |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` | Send payouts to splits up to the payout limit. Checked against project owner (inside `_sendPayoutsOf`). |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` | Migrate a project's balance to a different terminal. Checked against project owner. |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` | Set a project's metadata URI. Checked against project owner. |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` | Deploy a cloneable ERC-20 token for a project. Checked against project owner. |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` | Set an existing ERC-20 token for a project. Checked against project owner. |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` | Mint new project tokens. Checked against project owner. Only effective if the current ruleset allows owner minting. |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` | Burn project tokens. Checked against the **token holder**. |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` | Claim internal credits as ERC-20 tokens. Checked against the **token holder**. |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` | Transfer internal credit balance to another address. Checked against the **token holder**. |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` | Set a project's controller. Checked against project owner. |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` | Set a project's terminals. Checked against project owner. **Warning:** can remove the primary terminal. Also checked by `JBController.launchRulesetsFor` (ID 3) and `JBController.launchProjectFor`. |
| 16 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` | Set the primary terminal for a given token. Checked against project owner. |
| 17 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` | Use surplus allowance to send funds to an arbitrary address. Checked against project owner. |
| 18 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` | Set how payouts and reserved tokens are distributed. Checked against project owner. |
| 19 | `ADD_PRICE_FEED` | `JBController.addPriceFeedFor` | Add a price feed for a project. The controller checks this permission, then calls `JBPrices.addPriceFeedFor` internally. Checked against project owner. |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` | Add accepted token accounting contexts to a terminal. Checked against project owner. |
| 21 | `SET_TOKEN_METADATA` | `JBController.setTokenMetadataOf` | Set a project token's name and symbol. Checked against project owner. |

### nana-721-hook-v6

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 22 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` | Add or remove NFT tiers. Checked against `owner()` (the project's controller). Also used by `CTPublisher`, `CTProjectOwner`, and `REVDeployer`. |
| 23 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` | Set base URI, contract URI, or token URI resolver. Checked against `owner()`. |
| 24 | `MINT_721` | `JB721TiersHook.mintFor` | Manually mint NFTs from specific tiers. Checked against `owner()`. |
| 25 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` | Set the discount percent for NFT tiers. Checked against `owner()`. Called twice in the function for two separate code paths. |

### nana-buyback-hook-v6

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 26 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf` | Set the TWAP oracle window duration. Checked against project owner. |
| 27 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor`, `JBBuybackHook.initializePoolFor`, `JBBuybackHookRegistry.initializePoolFor` | Set the Uniswap pool for a project's buyback. Checked against project owner. |
| 28 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor`, `JBBuybackHookRegistry.lockHookFor` | Set or lock the buyback hook implementation for a project. Checked against project owner. Also granted by `REVDeployer` as an operator permission. |

### nana-router-terminal-v6

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 29 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor`, `JBRouterTerminalRegistry.lockTerminalFor` | Set or lock the router terminal for a project. Checked against project owner. |

### nana-suckers-v6

| ID | Name | Checked in | Permission scope |
|----|------|------------|-----------------|
| 30 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` | Map an ERC-20 token to its remote chain counterpart. Immutable once the outbox merkle tree has entries. Checked against project owner. |
| 31 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` | Deploy sucker contracts for cross-chain bridging. Checked against project owner. Also checked by `JBOmnichainDeployer` and `CTDeployer`. |
| 32 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` | Enable the emergency hatch to recover stuck tokens. Checked against project owner. |
| 33 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` | Move a sucker through the deprecation lifecycle (ENABLED -> DEPRECATION_PENDING -> SENDING_DISABLED -> DEPRECATED). Checked against project owner. |

## Common Permission Bundles

Typical combinations when granting operator access via `JBPermissions.setPermissionsFor`:

| Bundle | IDs | Use case |
|--------|-----|----------|
| **Deployer operator** | `QUEUE_RULESETS` (2), `SET_SPLIT_GROUPS` (18), `SET_FUND_ACCESS_LIMITS` (not in this library -- set via ruleset config) | Operator that manages project rulesets and split configuration on behalf of the owner. |
| **Token manager** | `MINT_TOKENS` (10), `BURN_TOKENS` (11), `SET_TOKEN_METADATA` (21) | Operator that manages token supply and metadata. |
| **Treasury manager** | `SEND_PAYOUTS` (5), `USE_ALLOWANCE` (17), `ADD_ACCOUNTING_CONTEXTS` (20) | Operator that manages outflows from the project treasury. |
| **Project admin** | `SET_PROJECT_URI` (7), `DEPLOY_ERC20` (8), `SET_CONTROLLER` (14), `SET_TERMINALS` (15), `SET_PRIMARY_TERMINAL` (16) | Broad administrative access without ROOT. |
| **NFT manager** | `ADJUST_721_TIERS` (22), `SET_721_METADATA` (23), `MINT_721` (24), `SET_721_DISCOUNT_PERCENT` (25) | Full control over 721 tier configuration. |
| **Cross-chain operator** | `DEPLOY_SUCKERS` (31), `MAP_SUCKER_TOKEN` (30), `SET_SUCKER_DEPRECATION` (33) | Manages cross-chain bridging lifecycle. |
| **Launch bundle** | `LAUNCH_RULESETS` (3), `SET_TERMINALS` (15) | Both are required for `launchRulesetsFor` -- ID 3 alone is insufficient. |

## Integration Points

| Dependency | Import | Used For |
|------------|--------|----------|
| None | -- | This library has no dependencies. It is imported by permission-gated contracts across the ecosystem. |

### Repos that import JBPermissionIds

| Repository | Contracts |
|------------|-----------|
| nana-core-v6 | `JBPermissions`, `JBController`, `JBMultiTerminal`, `JBDirectory` |
| nana-721-hook-v6 | `JB721TiersHook`, `JB721TiersHookProjectDeployer` |
| nana-buyback-hook-v6 | `JBBuybackHook`, `JBBuybackHookRegistry` |
| nana-router-terminal-v6 | `JBRouterTerminalRegistry` |
| nana-suckers-v6 | `JBSucker`, `JBSuckerRegistry` |
| nana-omnichain-deployers-v6 | `JBOmnichainDeployer` |
| revnet-core-v6 | `REVDeployer` |
| croptop-core-v6 | `CTDeployer`, `CTProjectOwner`, `CTPublisher` |

## Key Types

N/A -- no structs or enums. All values are `uint8 internal constant`.

## Gotchas

- **ROOT (ID 1) grants everything.** Any permission check that passes `includeRoot: true` (which all standard `_requirePermissionFrom` calls do) will succeed if the operator has ROOT.
- **ROOT cannot be granted for wildcard project ID (0).** `JBPermissions.setPermissionsFor` reverts with `JBPermissions_CantSetRootPermissionForWildcardProject()`. This is a critical safety rail.
- **ROOT operators can delegate, but not escalate.** A ROOT operator can call `setPermissionsFor` on behalf of the account, but the call reverts if the new permission set includes ROOT or targets the wildcard project ID.
- **Permission ID 0 is forbidden.** `JBPermissions` reverts with `JBPermissions_NoZeroPermission()` if bit 0 is set. Valid IDs start at 1.
- **Wildcard project ID (0) grants cross-project access.** Granting `QUEUE_RULESETS` with `projectId = 0` means the operator can queue rulesets for *every* project the account owns. This is powerful and should be used sparingly.
- **SET_TERMINALS (ID 15) can break a project.** Replacing the terminal list without including the current primary terminal will remove it, breaking payments and cashouts until a new primary is set.
- **LAUNCH_RULESETS (ID 3) requires both IDs 3 and 15.** The function enforces two separate permission checks because it configures terminals in addition to launching rulesets.
- **Holder-scoped permissions.** IDs 4 (`CASH_OUT_TOKENS`), 11 (`BURN_TOKENS`), 12 (`CLAIM_TOKENS`), and 13 (`TRANSFER_CREDITS`) are checked against the **token holder**, not the project owner. This means a holder grants an operator permission to act on the holder's own tokens.
- **SET_BUYBACK_POOL (ID 27) vs SET_BUYBACK_HOOK (ID 28) — different scopes.** ID 27 guards pool configuration (`setPoolFor`, `initializePoolFor`). ID 28 guards hook selection (`setHookFor`, `lockHookFor`). `setTwapWindowOf` uses ID 26 (`SET_BUYBACK_TWAP`). Grant all three if the operator needs full buyback management.
- **ADD_PRICE_FEED (ID 19) is checked on JBController, not JBPrices.** The permission gate is on `JBController.addPriceFeed`, which then calls `JBPrices.addPriceFeedFor` internally.
- **uint8 range.** IDs are `uint8` (0--255) but the packed storage is `uint256`, so the system supports up to 256 permission bits. Currently 33 are defined (1--33).

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

```solidity
// Grant multiple permissions at once
uint8[] memory permissionIds = new uint8[](3);
permissionIds[0] = JBPermissionIds.QUEUE_RULESETS;
permissionIds[1] = JBPermissionIds.SET_SPLIT_GROUPS;
permissionIds[2] = JBPermissionIds.SET_PROJECT_URI;
permissions.setPermissionsFor(account, JBPermissionsData({
    operator: operatorAddress,
    projectId: 5,
    permissionIds: permissionIds
}));
```

```solidity
// Check if an operator has a permission
bool canQueue = permissions.hasPermission({
    operator: operatorAddress,
    account: projectOwner,
    projectId: 5,
    permissionId: JBPermissionIds.QUEUE_RULESETS,
    includeRoot: true,              // ROOT holders pass this check
    includeWildcardProjectId: true  // Also check projectId=0 grants
});
```
