# Audit Instructions -- nana-permission-ids-v6

You are auditing a constants-only library that defines all permission IDs used across the Juicebox V6 ecosystem. The library has no state, no functions, no constructors, and no dependencies. The entire audit surface is the correctness and consistency of 33 `uint8` constants. Read [RISKS.md](./RISKS.md) first -- it documents all known risks and trust assumptions. Then come back here.

## Quick Verification

Run this one-liner from the repo root to verify all 33 permission IDs are unique, sequential (1-33), and have no gaps or duplicates:

```bash
grep 'constant.*=' src/JBPermissionIds.sol | sed 's/.*= \([0-9]*\).*/\1/' | sort -n | diff - <(seq 1 33) && echo "PASS: All 33 IDs are unique and sequential (1-33)" || echo "FAIL: ID mismatch detected"
```

If `PASS` is printed, the constants are correctly assigned. If `FAIL` is printed, inspect the diff output to identify which IDs are missing, duplicated, or out of range.

## Compiler and Version Info

From `foundry.toml`:

| Setting | Value |
|---------|-------|
| Solidity version | `0.8.26` |
| EVM target | `cancun` |
| Optimizer | Enabled, 200 runs |
| Pragma in source | `^0.8.0` (flexible, compiled with 0.8.26) |

Note: The library pragma is `^0.8.0` rather than a fixed version, since consuming contracts may compile it with their own Solidity version. The `foundry.toml` pins `0.8.26` for local builds.

## Previous Audit Findings

No prior formal audit with finding IDs has been conducted for `nana-permission-ids-v6`. This library has been reviewed informally as part of broader Juicebox V6 ecosystem reviews, but no standalone audit report exists.

## Scope

**In scope:**
```
src/JBPermissionIds.sol    # Constants library (~67 lines, 33 permission IDs)
```

**Out of scope:** All consuming contracts (nana-core, nana-721-hook, nana-buyback-hook, nana-router-terminal, nana-suckers, revnet-core, croptop-core). The constants library has no dependencies.

## Architecture

`JBPermissionIds` is a Solidity library containing 33 `uint8 internal constant` values numbered 1 through 33. These IDs are used with `JBPermissions.setPermissionsFor()` to grant scoped access to protocol functions. The permission system stores permissions as a 256-bit packed integer (`uint256`), with each bit corresponding to a permission ID.

### Permission System Overview

```
permissionsOf[operator][account][projectId] => uint256 (one bit per permission ID)
```

- **Bit 0 (ID 0):** Reserved, cannot be set. `JBPermissions` reverts if bit 0 is included.
- **Bit 1 (ID 1, ROOT):** Grants all permissions across all contracts. Cannot be granted for wildcard `projectId = 0`.
- **Bits 2-33:** Individual permissions, each gating a specific function (or set of functions) in the ecosystem.
- **Bits 34-255:** Unassigned, available for future extensions.

### All Permission IDs

| ID | Constant | Gated Function(s) | Checked Against |
|----|----------|-------------------|-----------------|
| 1 | `ROOT` | All permissions (implicit) | Project owner |
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` | Project owner |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` (also needs SET_TERMINALS) | Project owner |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` | **Token holder** |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` | Project owner |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` | Project owner |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` | Project owner |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` | Project owner |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` | Project owner |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` | Project owner |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` | **Token holder** |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` | **Token holder** |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` | **Token holder** |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` | Project owner |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` (WARNING: can remove primary terminal) | Project owner |
| 16 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` | Project owner |
| 17 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` | Project owner |
| 18 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` | Project owner |
| 19 | `ADD_PRICE_FEED` | `JBController.addPriceFeedFor` (not `JBPrices` directly) | Project owner |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` | Project owner |
| 21 | `SET_TOKEN_METADATA` | `JBController.setTokenMetadataOf` | Project owner |
| 22 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` | Hook owner |
| 23 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` | Hook owner |
| 24 | `MINT_721` | `JB721TiersHook.mintFor` | Hook owner |
| 25 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` | Hook owner |
| 26 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf` | Project owner |
| 27 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor` | Project owner |
| 28 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor` + `lockHookFor` | Project owner |
| 29 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor` + `lockTerminalFor` | Project owner |
| 30 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` | Project owner |
| 31 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` | Project owner |
| 32 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` | Project owner |
| 33 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` | Project owner |

## Priority Audit Areas

### 1. ID Uniqueness (Highest Priority)

Every permission ID must be unique. Two different constants with the same numeric value would cause one permission grant to silently authorize a different action. Verify:

- All 33 constants have distinct values.
- Values are sequential from 1 to 33 with no gaps and no duplicates.
- No other file in the ecosystem defines additional permission ID constants that could collide with these.

### 2. ID-to-Function Mapping Correctness

Each constant's doc comment claims it gates a specific function. Verify against the actual source code of each consuming contract:

- **nana-core-v6**: IDs 2-21 should match the `_requirePermissionFrom` calls in `JBController`, `JBMultiTerminal`, and `JBDirectory`.
- **nana-721-hook-v6**: IDs 22-25 should match permission checks in `JB721TiersHook`.
- **nana-buyback-hook-v6**: IDs 26-28 should match permission checks in `JBBuybackHook` and `JBBuybackHookRegistry`.
- **nana-router-terminal-v6**: ID 29 should match permission checks in `JBRouterTerminalRegistry`.
- **nana-suckers-v6**: IDs 30-33 should match permission checks in `JBSucker` and `JBSuckerRegistry`.

Verified: **SET_BUYBACK_HOOK (ID 28)** correctly gates both `JBBuybackHookRegistry.setHookFor` and `lockHookFor`. Both functions check `SET_BUYBACK_HOOK` (ID 28), not `SET_BUYBACK_POOL` (ID 27). The table above is accurate.

### 3. Holder-Scoped vs Owner-Scoped Permissions

Four permissions are checked against the **token holder**, not the project owner:

- `CASH_OUT_TOKENS` (4) -- holder authorizes cashout of their tokens
- `BURN_TOKENS` (11) -- holder authorizes burning their tokens
- `CLAIM_TOKENS` (12) -- holder authorizes claiming their credits as ERC-20
- `TRANSFER_CREDITS` (13) -- holder authorizes transferring their credit balance

Verify that no consuming contract incorrectly checks these against the project owner. A confused check would mean the project owner could burn or cash out any holder's tokens (massive vulnerability).

### 4. Dual-Purpose Permission IDs

Two IDs intentionally gate both a "set" and a "lock" operation:

- **SET_BUYBACK_HOOK (28)**: Gates both `setHookFor` (configurable) and `lockHookFor` (permanent). An operator with this permission can permanently lock the hook configuration.
- **SET_ROUTER_TERMINAL (29)**: Gates both `setTerminalFor` (configurable) and `lockTerminalFor` (permanent). An operator with this permission can permanently lock the terminal configuration.

Verify that project owners are aware of the locking implication when granting these permissions. The source code includes `@dev` documentation, but this is a significant trust escalation.

### 5. ROOT Permission Safety

ROOT (ID 1) is the superadmin permission. The `JBPermissions` contract implements critical safety rails:

- ROOT cannot be granted for wildcard `projectId = 0` (would grant root across all projects)
- A ROOT operator can call `setPermissionsFor` on behalf of the account but cannot grant ROOT to others
- ROOT cannot be included when setting wildcard project permissions

Verify these constraints are enforced in `JBPermissions`, not in this library (this library only defines the constant).

### 6. SET_TERMINALS (ID 15) Risk

The source comment warns: "Be careful - `SET_TERMINALS` can be used to remove the primary terminal." Additionally, `LAUNCH_RULESETS` (ID 3) requires both ID 3 AND ID 15 because the launch function configures terminals. Verify:

- Granting `SET_TERMINALS` alone is sufficient to replace the entire terminal list, potentially breaking a project.
- Granting `LAUNCH_RULESETS` without also granting `SET_TERMINALS` will cause `launchRulesetsFor` to revert (dual permission check).

## Invariants to Verify

1. **Uniqueness**: All 33 constants have unique values in the range [1, 33].
2. **Completeness**: Every `_requirePermissionFrom` call in the ecosystem uses one of these constants (no magic numbers).
3. **Type consistency**: All constants are `uint8`, matching the parameter type of `JBPermissions.hasPermission`.
4. **No ID 0**: No constant has value 0 (reserved and forbidden by `JBPermissions`).
5. **Sequential assignment**: IDs are assigned 1 through 33 with no gaps.

## Testing Setup

This is a constants-only library with no runtime behavior. There are no test files. Verification is done by cross-referencing the constants against consuming contracts.

```bash
cd nana-permission-ids-v6
forge build  # Ensures the library compiles
```

To verify ID usage across the ecosystem:
```bash
# Search for permission ID usage in consuming repos
grep -r "JBPermissionIds\." ../nana-core-v6/src/ ../nana-721-hook-v6/src/ ../nana-buyback-hook-v6/src/ ../nana-router-terminal-v6/src/ ../nana-suckers-v6/src/
```

Go break it.
