# Juicebox Permission IDs

The single source of truth for access control across the Juicebox V6 ecosystem. This library defines 33 `uint8` constants -- one for each permission ID used with [`JBPermissions`](https://github.com/Bananapus/nana-core-v6/blob/main/src/JBPermissions.sol) -- ensuring every contract references the same IDs.

## How permissions work

Juicebox V6 access control is built on a simple model: an **account** (typically a project owner) grants an **operator** (any address) a set of permission IDs scoped to a specific **project ID**. When a permissioned function is called, the contract checks that the caller either *is* the account or *has* the required permission ID for that project.

Permissions are stored as a 256-bit packed integer in `JBPermissions`, where each bit position corresponds to a permission ID. This library provides human-readable names for those bit positions.

```
permissionsOf[operator][account][projectId] => uint256 (packed bits)
```

## Architecture

| Contract | Description |
|----------|-------------|
| `JBPermissionIds` | Solidity library with 33 `uint8 internal constant` permission IDs (values 1--33). No state, no functions, no dependencies. Pragma `^0.8.0` for maximum compatibility. |

## All permission IDs

### Global (ID 1)

| ID | Name | Description |
|----|------|-------------|
| 1 | `ROOT` | Grants **all** permissions across every contract. An operator with ROOT can call any permissioned function on behalf of the account. Must be granted with extreme care. See [Gotchas](#gotchas) for restrictions. |

### Core (IDs 2--21) -- [nana-core-v6](https://github.com/Bananapus/nana-core-v6)

| ID | Name | Checked in | Description |
|----|------|------------|-------------|
| 2 | `QUEUE_RULESETS` | `JBController.queueRulesetsOf` | Queue new rulesets for a project. Also required by `JB721TiersHookProjectDeployer` and `JBOmnichainDeployer`. |
| 3 | `LAUNCH_RULESETS` | `JBController.launchRulesetsFor` | Launch a project's initial rulesets and terminals. Note: the caller also needs `SET_TERMINALS` (ID 15) since this function configures terminals. |
| 4 | `CASH_OUT_TOKENS` | `JBMultiTerminal.cashOutTokensOf` | Cash out (redeem) a holder's tokens for a share of the project's surplus. Checked against the **token holder**, not the project owner. |
| 5 | `SEND_PAYOUTS` | `JBMultiTerminal.sendPayoutsOf` | Send payouts to a project's splits up to its payout limit. |
| 6 | `MIGRATE_TERMINAL` | `JBMultiTerminal.migrateBalanceOf` | Migrate a project's balance from one terminal to another. |
| 7 | `SET_PROJECT_URI` | `JBController.setUriOf` | Set a project's metadata URI. |
| 8 | `DEPLOY_ERC20` | `JBController.deployERC20For` | Deploy a new ERC-20 token for a project. |
| 9 | `SET_TOKEN` | `JBController.setTokenFor` | Set an existing ERC-20 token for a project. |
| 10 | `MINT_TOKENS` | `JBController.mintTokensOf` | Mint new project tokens. Only works if the current ruleset allows owner minting. |
| 11 | `BURN_TOKENS` | `JBController.burnTokensOf` | Burn a holder's project tokens. Checked against the **token holder**, not the project owner. |
| 12 | `CLAIM_TOKENS` | `JBController.claimTokensFor` | Claim a holder's internal credit balance as ERC-20 tokens. Checked against the **token holder**. |
| 13 | `TRANSFER_CREDITS` | `JBController.transferCreditsFrom` | Transfer a holder's internal credit balance to another address. Checked against the **token holder**. |
| 14 | `SET_CONTROLLER` | `JBDirectory.setControllerOf` | Set a project's controller in the directory. |
| 15 | `SET_TERMINALS` | `JBDirectory.setTerminalsOf` | Set a project's terminals. **Warning:** can remove the primary terminal. Also required by `LAUNCH_RULESETS` (ID 3). |
| 16 | `SET_PRIMARY_TERMINAL` | `JBDirectory.setPrimaryTerminalOf` | Set a project's primary terminal for a given token. |
| 17 | `USE_ALLOWANCE` | `JBMultiTerminal.useAllowanceOf` | Use a project's surplus allowance to send funds to an arbitrary address. |
| 18 | `SET_SPLIT_GROUPS` | `JBController.setSplitGroupsOf` | Set a project's split groups (how payouts and reserved tokens are distributed). |
| 19 | `ADD_PRICE_FEED` | `JBController.addPriceFeedFor` | Add a price feed for a project. The controller checks this permission before calling `JBPrices.addPriceFeedFor`. |
| 20 | `ADD_ACCOUNTING_CONTEXTS` | `JBMultiTerminal.addAccountingContextsFor` | Add accounting contexts (accepted tokens) to a terminal for a project. |
| 21 | `SET_TOKEN_METADATA` | `JBController.setTokenMetadataOf` | Set a project token's name and symbol. Checked against the project owner. |

### 721 Hook (IDs 22--25) -- [nana-721-hook-v6](https://github.com/Bananapus/nana-721-hook-v6)

| ID | Name | Checked in | Description |
|----|------|------------|-------------|
| 22 | `ADJUST_721_TIERS` | `JB721TiersHook.adjustTiers` | Add or remove NFT tiers. Also used by `CTPublisher` and `CTProjectOwner` in croptop-core-v6. |
| 23 | `SET_721_METADATA` | `JB721TiersHook.setMetadata` | Set the metadata (base URI, contract URI, token URI resolver) for a 721 hook. |
| 24 | `MINT_721` | `JB721TiersHook.mintFor` | Manually mint NFTs from specific tiers to a beneficiary. |
| 25 | `SET_721_DISCOUNT_PERCENT` | `JB721TiersHook.setDiscountPercentOf` | Set the discount percent for one or more NFT tiers. |

### Buyback Hook (IDs 26--28) -- [nana-buyback-hook-v6](https://github.com/Bananapus/nana-buyback-hook-v6)

| ID | Name | Checked in | Description |
|----|------|------------|-------------|
| 26 | `SET_BUYBACK_TWAP` | `JBBuybackHook.setTwapWindowOf` | Set the TWAP (time-weighted average price) oracle window for a project's buyback hook. |
| 27 | `SET_BUYBACK_POOL` | `JBBuybackHook.setPoolFor`, `JBBuybackHook.setTwapWindowOf`, `JBBuybackHookRegistry.setPoolFor`, `JBBuybackHookRegistry.lockPoolFor` | Set the Uniswap pool or TWAP window for a project's buyback hook. |
| 28 | `SET_BUYBACK_HOOK` | `JBBuybackHookRegistry.setHookFor`, `JBBuybackHookRegistry.lockHookFor` | Set or lock the buyback hook in the registry. Also used by `REVDeployer` as an operator permission grant. |

### Router Terminal (ID 29) -- [nana-router-terminal-v6](https://github.com/Bananapus/nana-router-terminal-v6)

| ID | Name | Checked in | Description |
|----|------|------------|-------------|
| 29 | `SET_ROUTER_TERMINAL` | `JBRouterTerminalRegistry.setTerminalFor`, `JBRouterTerminalRegistry.lockTerminalFor` | Set or lock the router terminal for a project. |

### Suckers / Omnichain (IDs 30--33) -- [nana-suckers-v6](https://github.com/Bananapus/nana-suckers-v6)

| ID | Name | Checked in | Description |
|----|------|------------|-------------|
| 30 | `MAP_SUCKER_TOKEN` | `JBSucker.mapToken` | Map an ERC-20 token to its remote chain counterpart in a sucker. Mapping is immutable once the outbox tree has entries. |
| 31 | `DEPLOY_SUCKERS` | `JBSuckerRegistry.deploySuckersFor` | Deploy new sucker contracts for a project. Also checked by `JBOmnichainDeployer` and `CTDeployer`. |
| 32 | `SUCKER_SAFETY` | `JBSucker.enableEmergencyHatchFor` | Enable the emergency hatch for a sucker, allowing the project owner to recover stuck tokens. |
| 33 | `SET_SUCKER_DEPRECATION` | `JBSucker.setDeprecation` | Set the deprecation status of a sucker (ENABLED, DEPRECATION_PENDING, SENDING_DISABLED, DEPRECATED). |

## Gotchas

- **ROOT is dangerous.** It grants every permission on every contract. An operator with ROOT for project 5 can queue rulesets, send payouts, migrate terminals, mint tokens, etc. -- all on behalf of the granting account for that project.
- **ROOT cannot be granted for the wildcard project ID.** `JBPermissions` reverts with `JBPermissions_CantSetRootPermissionForWildcardProject()` if you try to set ROOT with `projectId = 0`. This prevents a single operator from controlling all of an account's projects.
- **ROOT operators can set permissions for others, but cannot grant ROOT.** A ROOT operator can call `setPermissionsFor` on behalf of the account, but only if the new permission set does NOT include ROOT and is NOT for the wildcard project ID.
- **Permission ID 0 is reserved.** `JBPermissions` reverts with `JBPermissions_NoZeroPermission()` if bit 0 is set in any packed permission value. IDs start at 1.
- **Wildcard project ID (0) applies to all projects.** Granting a permission with `projectId = 0` means the operator has that permission for every project owned by the account. Use with caution.
- **SET_TERMINALS can remove the primary terminal.** The source code warns about this. Replacing the terminal list can drop the primary terminal, breaking payments and cashouts.
- **LAUNCH_RULESETS requires SET_TERMINALS.** `launchRulesetsFor` enforces both `LAUNCH_RULESETS` and `SET_TERMINALS` because it configures terminals as part of the launch.
- **Holder vs. owner permissions.** Most permissions are checked against the project owner, but `CASH_OUT_TOKENS`, `BURN_TOKENS`, `CLAIM_TOKENS`, and `TRANSFER_CREDITS` are checked against the **token holder**. This means a holder can grant an operator permission to cash out or burn their own tokens.
- **The uint8 type limits IDs to 0--255.** Currently 33 are defined (1--33), leaving room for future extensions.

## Install

```bash
npm install
```

## Develop

| Command | Description |
|---------|-------------|
| `forge build` | Compile contracts |
