# User Journeys -- nana-permission-ids-v6

Since this is a constants-only library with no runtime behavior, these journeys describe how the permission IDs are used by actors across the ecosystem. Each journey shows the constant's role in a concrete access control scenario.

## Journey 1: Grant an Operator Permission to Queue Rulesets

**Actor:** Project owner granting delegated access to a trusted operator.
**Goal:** Allow an operator to queue new rulesets for a project without transferring project ownership.

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

   - Sets bit 2 in `permissionsOf[operatorAddress][projectOwner][5]`

2. **Operator calls `JBController.queueRulesetsOf(5, ...)`**

   - Controller calls `_requirePermissionFrom(projectOwner, 5, JBPermissionIds.QUEUE_RULESETS)`
   - `JBPermissions.hasPermission` checks: does `operatorAddress` have bit 2 set for `(projectOwner, projectId=5)`? Yes.
   - Operation proceeds.

### What to verify

- The operator can ONLY queue rulesets. They cannot send payouts, set terminals, or perform any other operation unless additional IDs are granted.
- Granting `QUEUE_RULESETS` with `projectId = 0` (wildcard) would allow the operator to queue rulesets for ALL projects the owner controls.

---

## Journey 2: ROOT Permission Grants Universal Access

**Actor:** Project owner granting ROOT to a highly trusted multisig.
**Goal:** Give a single operator full control over all project operations.

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

   - Sets bit 1 in `permissionsOf[multisigAddress][projectOwner][5]`

2. **Multisig calls any permissioned function for project 5**

   - Every `_requirePermissionFrom` check includes `includeRoot: true`
   - ROOT (bit 1) satisfies any permission check for `(projectOwner, projectId=5)`
   - The multisig can queue rulesets, send payouts, set terminals, mint tokens, etc.

### What to verify

- ROOT cannot be granted with `projectId = 0`. `JBPermissions` reverts with `JBPermissions_CantSetRootPermissionForWildcardProject()`.
- A ROOT operator can call `setPermissionsFor` on behalf of the account, but cannot grant ROOT to other operators or set wildcard permissions. This prevents permission escalation.
- ROOT is per-project. Having ROOT for project 5 does not grant access to project 6.

---

## Journey 3: Token Holder Delegates Cashout Authority

**Actor:** Token holder (not project owner) granting a bot permission to cash out tokens on their behalf.
**Goal:** Allow automated cashout execution without exposing the holder's private key.

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

### What to verify

- `CASH_OUT_TOKENS` (ID 4) is checked against the token holder, not the project owner. This is by design -- only the holder (or their delegates) can cash out the holder's tokens.
- The project owner CANNOT cash out another holder's tokens (unless the holder explicitly grants them `CASH_OUT_TOKENS`).
- The same holder-scoped pattern applies to `BURN_TOKENS` (11), `CLAIM_TOKENS` (12), and `TRANSFER_CREDITS` (13).

---

## Journey 4: SET_TERMINALS Can Break a Project

**Actor:** Project owner (or delegate with SET_TERMINALS permission).
**Goal:** Update the list of terminals for a project -- illustrating the risk documented in the source.

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

### What to verify

- Granting `SET_TERMINALS` to an untrusted operator is dangerous. The operator can remove all terminals, bricking the project.
- `LAUNCH_RULESETS` (ID 3) also requires `SET_TERMINALS` (ID 15) because the launch function configures terminals. Granting only ID 3 without ID 15 will cause the launch to revert.
- There is no undo mechanism. Once terminals are set, another `setTerminalsOf` call is needed to restore them.

---

## Journey 5: Locking a Buyback Hook or Router Terminal (Permanent Action)

**Actor:** Project owner or delegate with SET_BUYBACK_HOOK or SET_ROUTER_TERMINAL permission.
**Goal:** Illustrate the irreversible locking behavior gated by dual-purpose permission IDs.

### Steps (SET_BUYBACK_HOOK example)

1. **Operator with SET_BUYBACK_HOOK (ID 28) calls `JBBuybackHookRegistry.setHookFor(5, hookAddress)`**

   - Configures the buyback hook for project 5
   - This is a reversible operation (can be called again with a different hook)

2. **Same operator calls `JBBuybackHookRegistry.lockHookFor(5)`**

   - Permanently locks the hook configuration for project 5
   - No one can change the hook after locking -- not even the project owner

### What to verify

- A single permission ID (28 or 29) gates BOTH the "set" and "lock" operations. Granting the permission implicitly trusts the operator to potentially lock the configuration.
- The locking is permanent (no unlock mechanism in the registry).
- Project owners should only grant SET_BUYBACK_HOOK (28) or SET_ROUTER_TERMINAL (29) to operators they trust not to lock prematurely.

---

## Journey 6: Cross-Repo Permission Usage (nana-suckers)

**Actor:** Project owner managing cross-chain infrastructure.
**Goal:** Deploy suckers and manage their lifecycle using permission IDs 30-33.

### Steps

1. **Deploy suckers: `JBSuckerRegistry.deploySuckersFor(5, configs)`**
   - Permission: `DEPLOY_SUCKERS` (ID 31)
   - Creates sucker contracts for cross-chain bridging

2. **Map tokens: `JBSucker.mapToken(localToken, remoteToken)`**
   - Permission: `MAP_SUCKER_TOKEN` (ID 30)
   - Maps a local ERC-20 to its remote chain counterpart
   - CAUTION: once the outbox merkle tree has entries, the mapping is immutable (can only be disabled, not remapped)

3. **Enable emergency hatch: `JBSucker.enableEmergencyHatchFor(token)`**
   - Permission: `SUCKER_SAFETY` (ID 32)
   - Allows recovery of stuck tokens via the emergency hatch

4. **Deprecate sucker: `JBSucker.setDeprecation(newState)`**
   - Permission: `SET_SUCKER_DEPRECATION` (ID 33)
   - Moves the sucker through its lifecycle: ENABLED -> DEPRECATION_PENDING -> SENDING_DISABLED -> DEPRECATED

### What to verify

- Each sucker permission is independent. Having `DEPLOY_SUCKERS` does not grant `MAP_SUCKER_TOKEN` or `SUCKER_SAFETY`.
- `MAP_SUCKER_TOKEN` is especially sensitive because token mappings become immutable once the outbox tree has entries.
- `SUCKER_SAFETY` should be granted sparingly -- the emergency hatch is a last-resort recovery mechanism.
- All four sucker permissions are checked against the project owner, not a token holder.
