# User Journeys -- nana-permission-ids-v6

Since this is a constants-only library with no runtime behavior, these journeys describe how the permission IDs are used by actors across the ecosystem. Each journey shows the constant's role in a concrete access control scenario. All events referenced below are emitted by `JBPermissions` (in nana-core-v6), not by this library.

---

## Journey 1: Grant an Operator Permission to Queue Rulesets

**Entry point**: `JBPermissions.setPermissionsFor(address account, JBPermissionsData calldata permissionsData)`

**Who can call**: The `account` itself, or an existing operator that holds `ROOT` for the same `(account, projectId)` -- provided the new permissions do not include `ROOT` and the `projectId` is not the wildcard (`0`).

**Parameters**:
- `account` -- The address granting permissions (the project owner in this scenario)
- `permissionsData.operator` -- The address receiving permissions (the trusted operator)
- `permissionsData.projectId` -- The project ID the permissions are scoped to (e.g. `5`)
- `permissionsData.permissionIds` -- Array of `uint8` permission IDs to grant (e.g. `[JBPermissionIds.QUEUE_RULESETS]` which is ID 2)

### Steps

1. **Project owner calls `JBPermissions.setPermissionsFor`**

   ```solidity
   uint8[] memory ids = new uint8[](1);
   ids[0] = JBPermissionIds.QUEUE_RULESETS; // ID 2
   permissions.setPermissionsFor(
       projectOwner,
       JBPermissionsData({operator: operatorAddress, projectId: 5, permissionIds: ids})
   );
   ```

2. **Operator calls `JBController.queueRulesetsOf(5, ...)`**

   - Controller calls `_requirePermissionFrom(projectOwner, 5, JBPermissionIds.QUEUE_RULESETS)`
   - `JBPermissions.hasPermission` checks: does `operatorAddress` have bit 2 set for `(projectOwner, projectId=5)`? Yes.
   - Operation proceeds.

**State changes**:
1. `JBPermissions.permissionsOf[operatorAddress][projectOwner][5]` -- bit 2 set to 1 (packed uint256 bitmap)

**Events**: `OperatorPermissionsSet(operator, account, projectId, permissionIds, packed, caller)` -- emitted by `JBPermissions`, not this library.

**Edge cases**:
- The operator can ONLY queue rulesets. They cannot send payouts, set terminals, or perform any other operation unless additional IDs are granted.
- Granting `QUEUE_RULESETS` with `projectId = 0` (wildcard) would allow the operator to queue rulesets for ALL projects the owner controls.
- `JBPermissions_NoZeroPermission()` -- reverts if permission ID 0 is included in the array.
- `JBPermissions_PermissionIdOutOfBounds(permissionId)` -- reverts if any permission ID exceeds 255.

---

## Journey 2: ROOT Permission Grants Universal Access

**Entry point**: `JBPermissions.setPermissionsFor(address account, JBPermissionsData calldata permissionsData)`

**Who can call**: Only the `account` itself can grant `ROOT`. An existing ROOT operator cannot grant ROOT to others (the function enforces this restriction explicitly).

**Parameters**:
- `account` -- The address granting ROOT (must be the caller)
- `permissionsData.operator` -- The address receiving ROOT (e.g. a trusted multisig)
- `permissionsData.projectId` -- Must be a specific project ID (not `0`)
- `permissionsData.permissionIds` -- `[JBPermissionIds.ROOT]` (ID 1)

### Steps

1. **Project owner calls `JBPermissions.setPermissionsFor`**

   ```solidity
   uint8[] memory ids = new uint8[](1);
   ids[0] = JBPermissionIds.ROOT; // ID 1
   permissions.setPermissionsFor(
       projectOwner,
       JBPermissionsData({operator: multisigAddress, projectId: 5, permissionIds: ids})
   );
   ```

2. **Multisig calls any permissioned function for project 5**

   - Every `_requirePermissionFrom` check includes `includeRoot: true`
   - ROOT (bit 1) satisfies any permission check for `(projectOwner, projectId=5)`
   - The multisig can queue rulesets, send payouts, set terminals, mint tokens, etc.

**State changes**:
1. `JBPermissions.permissionsOf[multisigAddress][projectOwner][5]` -- bit 1 set to 1

**Events**: `OperatorPermissionsSet(operator, account, projectId, permissionIds, packed, caller)` -- emitted by `JBPermissions`, not this library.

**Edge cases**:
- `JBPermissions_CantSetRootPermissionForWildcardProject()` -- reverts if ROOT is granted with `projectId = 0`.
- `JBPermissions_Unauthorized(account, operator, projectId, permissionId)` -- reverts if a non-account caller (even a ROOT operator) tries to grant ROOT to another operator, or tries to set wildcard permissions.
- ROOT is per-project. Having ROOT for project 5 does not grant access to project 6.
- A ROOT operator can call `setPermissionsFor` on behalf of the account for non-ROOT, non-wildcard grants only. This prevents permission escalation.

---

## Journey 3: Token Holder Delegates Cashout Authority

**Entry point**: `JBPermissions.setPermissionsFor(address account, JBPermissionsData calldata permissionsData)`

**Who can call**: The token holder (the `account`), or an existing ROOT operator for the holder on the relevant project.

**Parameters**:
- `account` -- The token holder granting permission (NOT the project owner)
- `permissionsData.operator` -- The bot or delegate receiving cashout permission
- `permissionsData.projectId` -- The project ID the tokens belong to (e.g. `5`)
- `permissionsData.permissionIds` -- `[JBPermissionIds.CASH_OUT_TOKENS]` (ID 4)

### Steps

1. **Token holder calls `JBPermissions.setPermissionsFor`**

   ```solidity
   uint8[] memory ids = new uint8[](1);
   ids[0] = JBPermissionIds.CASH_OUT_TOKENS; // ID 4
   permissions.setPermissionsFor(
       tokenHolder,
       JBPermissionsData({operator: botAddress, projectId: 5, permissionIds: ids})
   );
   ```

   - Note: the `account` is the **token holder**, not the project owner

2. **Bot calls `JBMultiTerminal.cashOutTokensOf(tokenHolder, 5, ...)`**

   - Terminal calls `_requirePermissionFrom(tokenHolder, 5, JBPermissionIds.CASH_OUT_TOKENS)`
   - Permission check passes for `botAddress` because it has `CASH_OUT_TOKENS` for `(tokenHolder, 5)`

**State changes**:
1. `JBPermissions.permissionsOf[botAddress][tokenHolder][5]` -- bit 4 set to 1

**Events**: `OperatorPermissionsSet(operator, account, projectId, permissionIds, packed, caller)` -- emitted by `JBPermissions`, not this library.

**Edge cases**:
- `CASH_OUT_TOKENS` (ID 4) is checked against the token holder, not the project owner. This is by design -- only the holder (or their delegates) can cash out the holder's tokens.
- The project owner CANNOT cash out another holder's tokens (unless the holder explicitly grants them `CASH_OUT_TOKENS`).
- The same holder-scoped pattern applies to `BURN_TOKENS` (11), `CLAIM_TOKENS` (12), and `TRANSFER_CREDITS` (13).

---

## Journey 4: SET_TERMINALS Can Break a Project

**Entry point**: `JBDirectory.setTerminalsOf(uint256 projectId, IJBTerminal[] calldata terminals)`

**Who can call**: The project owner, or an address with the owner's `SET_TERMINALS` (ID 15) permission for that project.

**Parameters**:
- `projectId` -- The project whose terminals are being updated
- `terminals` -- The new complete list of terminals (replaces the entire existing list)

### Steps

1. **Operator calls `JBDirectory.setTerminalsOf(5, newTerminals)`**

   - Permission check: `_requirePermissionFrom(projectOwner, 5, JBPermissionIds.SET_TERMINALS)` (ID 15)
   - The `newTerminals` array replaces the ENTIRE terminal list

2. **If the new list omits the current primary terminal:**

   - The primary terminal is removed from the project
   - All payments to the project via `pay()` will fail (no terminal to receive them)
   - All cashouts via `cashOutTokensOf()` will fail
   - All payouts via `sendPayoutsOf()` will fail
   - The project is effectively frozen until a new primary terminal is set

**State changes**:
1. `JBDirectory._terminalsOf[projectId]` -- replaced with the new terminals array
2. `JBDirectory._primaryTerminalOf[projectId][token]` -- may be implicitly cleared if the primary terminal is not in the new list

**Events**: `SetTerminals(projectId, terminals, caller)` -- emitted by `JBDirectory` (in nana-core-v6), not this library.

**Edge cases**:
- Granting `SET_TERMINALS` to an untrusted operator is dangerous. The operator can remove all terminals, bricking the project.
- `LAUNCH_RULESETS` (ID 3) also requires `SET_TERMINALS` (ID 15) because the launch function configures terminals. Granting only ID 3 without ID 15 will cause the launch to revert.
- There is no undo mechanism. Once terminals are set, another `setTerminalsOf` call is needed to restore them.

---

## Journey 5: Locking a Buyback Hook or Router Terminal (Permanent Action)

**Entry point (buyback hook)**:
- `JBBuybackHookRegistry.setHookFor(uint256 projectId, IJBRulesetDataHook hook)` -- configures the hook
- `JBBuybackHookRegistry.lockHookFor(uint256 projectId, IJBRulesetDataHook expectedHook)` -- permanently locks the configuration

**Who can call**: The project owner, or an address with the owner's `SET_BUYBACK_HOOK` (ID 28) permission for that project. A single permission ID gates both operations.

**Parameters**:
- `projectId` -- The project whose buyback hook is being configured or locked
- `hook` -- The buyback hook contract address (for `setHookFor` only)

### Steps (SET_BUYBACK_HOOK example)

1. **Operator with SET_BUYBACK_HOOK (ID 28) calls `JBBuybackHookRegistry.setHookFor(5, hookAddress)`**

   - Configures the buyback hook for project 5
   - This is a reversible operation (can be called again with a different hook)

2. **Same operator calls `JBBuybackHookRegistry.lockHookFor(5)`**

   - Permanently locks the hook configuration for project 5
   - No one can change the hook after locking -- not even the project owner

**State changes**:
1. `JBBuybackHookRegistry._hookOf[projectId]` -- set to the hook address (step 1)
2. `JBBuybackHookRegistry.hasLockedHook[projectId]` -- set to `true` (step 2, irreversible)

**Events**: Events are emitted by `JBBuybackHookRegistry` (in nana-buyback-hook-v6), not this library.

**Edge cases**:
- A single permission ID (28 or 29) gates BOTH the "set" and "lock" operations. Granting the permission implicitly trusts the operator to potentially lock the configuration.
- The locking is permanent (no unlock mechanism in the registry).
- Project owners should only grant SET_BUYBACK_HOOK (28) or SET_ROUTER_TERMINAL (29) to operators they trust not to lock prematurely.

---

## Journey 6: Cross-Repo Permission Usage (nana-suckers)

**Entry point**: Multiple functions across `JBSuckerRegistry` and `JBSucker`, each gated by a separate permission ID.

**Who can call**: The project owner, or an address with the corresponding permission for that project. Each sucker permission is independent.

**Parameters** (vary by operation):
- `projectId` -- The project managing cross-chain infrastructure
- `configs` -- Sucker deployment configurations (for `deploySuckersFor`)
- `map` -- A `JBTokenMapping` struct (for `mapToken`)
- `tokens` -- Token addresses (`address[]`) for emergency recovery (for `enableEmergencyHatchFor`)
- `timestamp` -- The timestamp after which the sucker is deprecated (for `setDeprecation`)

### Steps

1. **Deploy suckers: `JBSuckerRegistry.deploySuckersFor(5, salt, configs)`**
   - Permission: `DEPLOY_SUCKERS` (ID 31)
   - Creates sucker contracts for cross-chain bridging

2. **Map tokens: `JBSucker.mapToken(map)`** where `map` is a `JBTokenMapping` struct
   - Permission: `MAP_SUCKER_TOKEN` (ID 30)
   - Maps a local ERC-20 to its remote chain counterpart
   - CAUTION: once the outbox merkle tree has entries, the mapping is immutable (can only be disabled, not remapped)

3. **Enable emergency hatch: `JBSucker.enableEmergencyHatchFor(tokens)`**
   - Permission: `SUCKER_SAFETY` (ID 32)
   - Allows recovery of stuck tokens via the emergency hatch

4. **Deprecate sucker: `JBSucker.setDeprecation(timestamp)`**
   - Permission: `SET_SUCKER_DEPRECATION` (ID 33)
   - The timestamp after which the sucker is deprecated.

**State changes** (per step):
1. `JBSuckerRegistry` -- deploys new sucker contracts, registers them for the project
2. `JBSucker._remoteTokenFor[localToken]` -- set to the remote token mapping (immutable once outbox tree populated)
3. `JBSucker._remoteTokenFor[token].emergencyHatch` -- set to `true`
4. `JBSucker._deprecationState` -- advanced to the next lifecycle stage

**Events**: Events are emitted by `JBSuckerRegistry` and `JBSucker` (in nana-suckers-v6), not this library.

**Edge cases**:
- Each sucker permission is independent. Having `DEPLOY_SUCKERS` does not grant `MAP_SUCKER_TOKEN` or `SUCKER_SAFETY`.
- `MAP_SUCKER_TOKEN` is especially sensitive because token mappings become immutable once the outbox tree has entries.
- `SUCKER_SAFETY` should be granted sparingly -- the emergency hatch is a last-resort recovery mechanism.
- All four sucker permissions are checked against the project owner, not a token holder.

---

## Permission ID Reference

| ID | Constant | Gated function(s) | Scope |
|----|----------|-------------------|-------|
| 1 | `ROOT` | All permissioned functions | Project owner |
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` | Project owner |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` | Project owner |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` | Token holder |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` | Project owner |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` | Project owner |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` | Project owner |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` | Project owner |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` | Project owner |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` | Project owner |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` | Token holder |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` | Token holder |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` | Token holder |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` | Project owner |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` | Project owner |
| 16 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` | Project owner |
| 17 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` | Project owner |
| 18 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` | Project owner |
| 19 | `ADD_PRICE_FEED` | `JBController.addPriceFeedFor` | Project owner |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` | Project owner |
| 21 | `SET_TOKEN_METADATA` | `JBController.setTokenMetadataOf` | Project owner |
| 22 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` | Project owner |
| 23 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` | Project owner |
| 24 | `MINT_721` | `JB721TiersHook.mintFor` | Project owner |
| 25 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` | Project owner |
| 26 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf` | Project owner |
| 27 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor` | Project owner |
| 28 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor` + `lockHookFor` | Project owner |
| 29 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor` + `lockTerminalFor` | Project owner |
| 30 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` | Project owner |
| 31 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` | Project owner |
| 32 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` | Project owner |
| 33 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` | Project owner |
