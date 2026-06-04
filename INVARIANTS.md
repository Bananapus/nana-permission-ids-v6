# Invariants of `nana-permission-ids-v6`

Scope: the single constants-only library in `src/` — `JBPermissionIds.sol`. This package defines the canonical numbered permission IDs (`uint8`, 1–255) that `JBPermissions` (in `nana-core-v6`) packs into a `uint256` bitmask. It is a pure constants library — no state, no functions, no storage. **It is the single source of truth for permission IDs across every V6 package.**

This file is the per-repo scoped invariants doc. The protocol-wide guarantees for the seven deployed revnets live in [`../INVARIANTS.md`](../INVARIANTS.md); the operator permission sets and bypass addresses there are derived from the constants enumerated below.

---

## Section A — Guarantees to integrators

This package has no payable users, no token holders, no runtime state — every consumer is a Solidity contract that imports `JBPermissionIds` to derive a permission ID, or an off-chain caller (frontend, indexer, deploy script) that reads the constants to construct `setPermissionsFor` calls. The guarantees below are addressed to those integrators.

### A.1 ID namespace

- **A.1.1 Each ID is a `uint8`.** Every constant is declared `uint8 internal constant`. `JBPermissions` packs these into a `uint256` bitmask via bit shifts (`(permissions >> permissionId) & 1`). IDs outside `[0, 255]` cannot be expressed in a `uint8`; passing `> 255` to a `uint256`-typed `hasPermission` call reverts `JBPermissions_PermissionIdOutOfBounds` (see `nana-core-v6/src/JBPermissions.sol:170, 214`).
- **A.1.2 ID 0 is reserved and cannot be granted.** `JBPermissions.setPermissionsFor` reverts `JBPermissions_NoZeroPermission` if any caller-supplied permission ID is 0 (`nana-core-v6/src/JBPermissions.sol:71–75`). No constant in this library is assigned the value 0. Bit 0 of the packed `uint256` therefore stays unused as a deliberate sentinel.
- **A.1.3 ID 1 is `ROOT` and grants every other permission.** When `includeRoot=true` is passed to `hasPermissions` / `hasPermission`, the function returns `true` immediately if the operator holds bit 1, regardless of which other bits are checked (`nana-core-v6/src/JBPermissions.sol:141–154, 221–228`). Granting `ROOT` is therefore equivalent to granting every other ID in this file, present and future. Use with extreme caution.
- **A.1.4 ROOT cannot be sub-delegated.** A non-account operator that holds `ROOT` on a project may set non-ROOT permissions on the account's behalf, but cannot set `ROOT` and cannot touch the wildcard project (`projectId == 0`) — `JBPermissions.setPermissionsFor` reverts `JBPermissions_Unauthorized` if it tries (`nana-core-v6/src/JBPermissions.sol:80–101`). This caps how far a ROOT grant can propagate.
- **A.1.5 The current namespace is contiguous from 1 through 39.** Every constant defined in `src/JBPermissionIds.sol` takes a unique value in `[1, 39]` with no gaps. The Halmos check in `test/formal/JBPermissionIdsHalmos.t.sol` machine-verifies both the contiguity and the bounds (`ROOT == 1`, `REPAY_LOAN == 39`).

### A.2 Stability across releases

- **A.2.1 IDs MUST NEVER be renumbered or repurposed.** This is the load-bearing invariant of the package. See **Section D**.
- **A.2.2 New IDs are appended only.** Future permissions take the next unused integer (`40`, `41`, …) and never reuse a previously-defined slot, even if the original constant is removed or renamed. Integrators that derive IDs by importing the constant (rather than hardcoding the integer) are forward-compatible with any append-only change.

### A.3 Cross-package consumers

Every consumer of this library either:

1. Imports the constant by name (`JBPermissionIds.SET_BUYBACK_POOL`) — the safe, recommended pattern; or
2. Hardcodes the integer for off-chain code (deploy scripts, indexers, frontends).

For (2), see the `jb-v6-permission-id-renumbering` skill — V5 numbers do NOT carry over to V6 and copy-pasting a V5 integer list silently grants the wrong permissions.

---

## Section B — Guarantees to operators

**N/A.** This is a constants-only library with no operator-callable surface. There are no functions to call. There is no owner. There is no upgradeability. Permission *enforcement* lives in `nana-core-v6/src/JBPermissions.sol`; permission *grants* are made by token-holder / project-owner accounts via `JBPermissions.setPermissionsFor`.

---

## Section C — Per-symbol inventory

`src/JBPermissionIds.sol` — every constant defined in the library, its numeric value, the action it gates, and the production contracts that enforce or pass it through. File:line refs are to the corresponding consumer's `src/` directory.

### C.1 Foundational — ROOT

| ID | Symbol | Gates | Enforced in |
|---:|---|---|---|
| 1 | `ROOT` | Implicit grant of every other permission for the scoped project (when `includeRoot=true` at the check site). | `nana-core-v6/src/JBPermissions.sol:84, 90, 99, 145, 150, 224, 225` |

### C.2 nana-core-v6 — Project lifecycle, treasury, token

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` — queue additional rulesets for a project. | `nana-core-v6/src/JBController.sol`; passed through by `nana-721-hook-v6/src/JB721TiersHookProjectDeployer.sol` and `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol` |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` — initial-launch ruleset for an existing project. | `nana-core-v6/src/JBController.sol`; passed through by `nana-721-hook-v6/src/JB721TiersHookProjectDeployer.sol` and `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol` |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` on behalf of a token holder. | `nana-core-v6/src/JBMultiTerminal.sol` |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` (permissionless in practice; permission applies when callers want a wrapper to authenticate as operator). | `nana-core-v6/src/JBMultiTerminal.sol` |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` — move project balance to a new terminal. | `nana-core-v6/src/JBMultiTerminal.sol` |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` — update project metadata URI. | `nana-core-v6/src/JBController.sol`; passed through by `revnet-core-v6/src/REVOwner.sol`, `nana-721-hook-v6/src/JB721TiersHookProjectDeployer.sol`, `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol` |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` — one-shot ERC-20 deployment for a project. | `nana-core-v6/src/JBController.sol` |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` — point the project at an existing ERC-20. | `nana-core-v6/src/JBController.sol` |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` — owner-mint; requires `allowOwnerMinting` flag on the current ruleset. | `nana-core-v6/src/JBController.sol` |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` — burn project tokens on behalf of a holder. | `nana-core-v6/src/JBController.sol` |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` — convert internal credits to ERC-20. | `nana-core-v6/src/JBController.sol` |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` — transfer internal credits. | `nana-core-v6/src/JBController.sol` |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` — change the controller managing a project. | `nana-core-v6/src/JBDirectory.sol` |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` — replace the project's terminal list. | `nana-core-v6/src/JBDirectory.sol`; passed through by `nana-core-v6/src/JBController.sol`, `nana-721-hook-v6/src/JB721TiersHookProjectDeployer.sol`, `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol` |
| 16 | `ADD_TERMINALS` | `JBDirectory.setPrimaryTerminalOf` when it implicitly appends a new terminal. | `nana-core-v6/src/JBDirectory.sol` |
| 17 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` — choose the primary terminal for a token. | `nana-core-v6/src/JBDirectory.sol` |
| 18 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` — spend project surplus allowance. | `nana-core-v6/src/JBMultiTerminal.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |
| 19 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` — replace reserved-token / payout splits. | `nana-core-v6/src/JBController.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |
| 20 | `ADD_PRICE_FEED` | `JBController.addPriceFeedFor` — register a per-project price feed. | `nana-core-v6/src/JBController.sol` |
| 21 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` — accept a new token in this terminal. | `nana-core-v6/src/JBMultiTerminal.sol` |
| 22 | `SET_TOKEN_METADATA` | `JBController.setTokenMetadataOf` — update project ERC-20 name/symbol. | `nana-core-v6/src/JBController.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |
| 23 | `SIGN_FOR_ERC20` | `JBERC20.isValidSignature` — ERC-1271 signing on behalf of the project token. | `nana-core-v6/src/JBERC20.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |

### C.3 nana-721-hook-v6 — Tier NFTs

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 24 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` — add/remove tiers. | `nana-721-hook-v6/src/JB721TiersHook.sol`; passed through by `revnet-core-v6/src/REVDeployer.sol`, `croptop-core-v6/src/CTProjectOwner.sol`, `croptop-core-v6/src/CTPublisher.sol`, `croptop-core-v6/src/CTDeployer.sol` |
| 25 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` — base URI / contract URI / token URI resolver. | `nana-721-hook-v6/src/JB721TiersHook.sol`; passed through by `revnet-core-v6/src/REVDeployer.sol`, `croptop-core-v6/src/CTDeployer.sol` |
| 26 | `MINT_721` | `JB721TiersHook.mintFor` — reserved / promotional mints without payment. | `nana-721-hook-v6/src/JB721TiersHook.sol`; passed through by `revnet-core-v6/src/REVDeployer.sol`, `croptop-core-v6/src/CTDeployer.sol` |
| 27 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` — per-tier discount. | `nana-721-hook-v6/src/JB721TiersHook.sol`; passed through by `revnet-core-v6/src/REVDeployer.sol`, `croptop-core-v6/src/CTDeployer.sol` |

### C.4 nana-buyback-hook-v6 — Buyback hook + registry

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 28 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf` — TWAP window for the project's buyback pool. | `nana-buyback-hook-v6/src/JBBuybackHook.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |
| 29 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor` / `initializePoolFor` (and registry forwarders). | `nana-buyback-hook-v6/src/JBBuybackHook.sol`, `nana-buyback-hook-v6/src/JBBuybackHookRegistry.sol`; passed through by `revnet-core-v6/src/REVOwner.sol`, `revnet-core-v6/src/REVDeployer.sol` |
| 30 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor` / `lockHookFor` — pin or permanently lock the buyback hook for a project. | `nana-buyback-hook-v6/src/JBBuybackHookRegistry.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |

### C.5 nana-router-terminal-v6

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 31 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor` / `lockTerminalFor`. | `nana-router-terminal-v6/src/JBRouterTerminalRegistry.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |

### C.6 nana-suckers-v6 — Cross-chain bridges

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 32 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` — register a per-chain token mapping. | `nana-suckers-v6/src/JBSucker.sol`; passed through by `revnet-core-v6/src/REVOwner.sol`, `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol` |
| 33 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` — deploy bridges (sufficient for default symmetric-address peering). | `nana-suckers-v6/src/JBSuckerRegistry.sol`; passed through by `revnet-core-v6/src/REVOwner.sol`, `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol`, `croptop-core-v6/src/CTDeployer.sol` |
| 34 | `SET_SUCKER_PEER` | `JBSuckerRegistry.deploySuckersFor` with a non-symmetric explicit peer. Intentionally narrower than `DEPLOY_SUCKERS` so automation cannot register attacker-controlled peers. | `nana-suckers-v6/src/JBSuckerRegistry.sol`; passed through by `nana-omnichain-deployers-v6/src/JBOmnichainDeployer.sol`, `croptop-core-v6/src/CTDeployer.sol` |
| 35 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` — emergency exit for stuck tokens. | `nana-suckers-v6/src/JBSucker.sol`; passed through by `revnet-core-v6/src/REVOwner.sol` |
| 36 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` — advance a sucker through its 14-day deprecation lifecycle. | `nana-suckers-v6/src/JBSucker.sol` |

### C.7 revnet-core-v6 — Loans

| ID | Symbol | Gates | Enforced in (file:line) |
|---:|---|---|---|
| 37 | `OPEN_LOAN` | `REVLoans.borrowFrom` — open a loan against the holder's project-token collateral. | `revnet-core-v6/src/REVLoans.sol` |
| 38 | `REALLOCATE_LOAN` | `REVLoans.reallocateCollateralFromLoan` — move collateral between projects. | `revnet-core-v6/src/REVLoans.sol` |
| 39 | `REPAY_LOAN` | `REVLoans.repayLoan` — repay on behalf of the loan owner. | `revnet-core-v6/src/REVLoans.sol` |

---

## Section D — Numbering stability invariant

**Permission IDs in this library MUST NEVER be renumbered or repurposed across releases.**

This is the load-bearing invariant of the package. Every other guarantee in this file depends on it.

### D.1 Why

Permissions in V6 are stored as a `uint256` bitmask, **packed by ID** (see `nana-core-v6/src/JBPermissions.sol:243–245`: `(permissions >> permissionId) & 1`). The bit position of each permission inside the mask is the integer value of its constant in this file at the time the grant was written.

A token-holder / project-owner who runs `setPermissionsFor` writes a `uint256` to `permissionsOf[operator][account][projectId]`. That `uint256` is **persisted on chain forever** (or until explicitly overwritten by the same account). When a downstream contract later checks `hasPermission`, the bit it tests is determined by the integer value of the constant at the **check site's compile time** — which may be much later than the grant was made, and may have been recompiled against a newer version of this library.

If a permission ID is renumbered:

- **Already-deployed contracts** that hardcoded the old integer (or that pinned an old version of this library via npm) will check the wrong bit.
- **Already-issued grants** that wrote the old integer's bit into storage will silently grant the new permission to anyone who was given the old one — and silently revoke the old permission from everyone.

Concretely: if `SUCKER_SAFETY` were renumbered from 35 to 99, every operator who was previously granted `SUCKER_SAFETY` (bit 35) would lose access to the emergency hatch and instead silently gain whatever permission ends up at bit 35 in the new layout — even on **deployed mainnet contracts** that have not been redeployed. There is no migration path that can fix this without rotating every grant on every chain.

### D.2 The rule

1. **Existing IDs are immutable.** Once a `uint8 internal constant FOO = N;` is published in a tagged release, `N` is the permanent value for `FOO`. The constant's value MUST NOT change in any future version of this library.
2. **Existing IDs are not repurposed.** If a permission is removed (e.g. its consumer is sunset), the integer slot stays burned — the constant may be deleted, but no new permission ever takes the freed slot. Append-only.
3. **New permissions take the next unused integer.** The next ID added to this file takes value `40`. The one after that takes `41`. And so on.
4. **V5 → V6 was a deliberate full-namespace reshuffle, not a renumbering.** V5 IDs do NOT carry over. Any cross-version porting must derive every ID from this file. See the `jb-v6-permission-id-renumbering` skill for the canonical V5 → V6 porting checklist.
5. **The formal check is the source of truth.** `test/formal/JBPermissionIdsHalmos.t.sol::check_permissionIdsAreContiguousAndStable` machine-verifies that every constant defined today has its expected integer value. Any PR that breaks this proof breaks the invariant. The companion check `check_permissionNamespaceBounds` pins `ROOT == 1` and `REPAY_LOAN == 39`; when the namespace is extended, the bound is updated to the new tail and the new constants are appended to the contiguous-check array — never inserted in the middle.

### D.3 Operational consequence

A PR that touches `src/JBPermissionIds.sol` and changes the integer value of any constant — even if the constant's *name* and *purpose* are unchanged — is a critical bug. The Halmos check at `test/formal/JBPermissionIdsHalmos.t.sol` will fail; do not "fix" the Halmos check to match the new numbering. Fix the source.

---

## Section E — Out-of-scope centralization caveats

**N/A.** This is a constants-only library:

- No global admin.
- No owner.
- No upgradeability.
- No proxy.
- No storage.

There is no privileged role inside this repo. The closest thing to a "trust boundary" is **the maintainer who can land a renumbering PR** — Section D's formal check is the on-chain-enforceable defense against that mistake.

---

## Section F — Key code references

- Permission packing and bit-shift check: `nana-core-v6/src/JBPermissions.sol:71, 170, 214, 243–245`
- ID 0 rejection on grant: `nana-core-v6/src/JBPermissions.sol:71–75`
- ROOT short-circuit on check: `nana-core-v6/src/JBPermissions.sol:141–154, 221–228`
- ROOT cannot grant ROOT / cannot touch wildcard project: `nana-core-v6/src/JBPermissions.sol:80–101`
- Formal contiguity + bounds proofs: `nana-permission-ids-v6/test/formal/JBPermissionIdsHalmos.t.sol`
- V5 → V6 porting skill: `jb-v6-permission-id-renumbering`

For the protocol-wide third-party attack-surface audit reasoning that depends on these IDs being stable, see [`../INVARIANTS.md`](../INVARIANTS.md) Sections A.4 and B.2.
