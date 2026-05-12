// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @notice Permission IDs used across the Juicebox ecosystem.
/// @dev Projects can grant permissions to other addresses (called "operators") through `JBPermissions`. Each permission
/// ID here authorizes the operator to call specific functions on behalf of the project owner or token holder. See
/// https://github.com/Bananapus/nana-core-v6/blob/main/src/JBPermissions.sol
library JBPermissionIds {
    /// @notice Grants all permissions across every Juicebox contract. An operator with ROOT can do anything the
    /// project owner can do. Use with extreme caution.
    uint8 internal constant ROOT = 1;

    /* ── nana-core-v6
    ───────────────────────────────────────────────────
    */

    /// @notice Queue new rulesets for a project, scheduling future changes to its funding cycles, payouts, and rules
    /// (`JBController.queueRulesetsOf`).
    uint8 internal constant QUEUE_RULESETS = 2;

    /// @notice Launch a project's first rulesets, initializing its funding cycles and configuration
    /// (`JBController.launchRulesetsFor`).
    uint8 internal constant LAUNCH_RULESETS = 3;

    /// @notice Cash out (redeem) project tokens from the treasury on behalf of a token holder
    /// (`JBMultiTerminal.cashOutTokensOf`).
    uint8 internal constant CASH_OUT_TOKENS = 4;

    /// @notice Send a project's payouts to its split recipients, distributing funds from the treasury
    /// (`JBMultiTerminal.sendPayoutsOf`).
    uint8 internal constant SEND_PAYOUTS = 5;

    /// @notice Migrate a project's terminal balance to a different terminal
    /// (`JBMultiTerminal.migrateBalanceOf`).
    uint8 internal constant MIGRATE_TERMINAL = 6;

    /// @notice Set or update a project's metadata URI, e.g. its name, description, and logo
    /// (`JBController.setUriOf`).
    uint8 internal constant SET_PROJECT_URI = 7;

    /// @notice Deploy a new ERC-20 token for a project, allowing token holders to claim transferable tokens
    /// (`JBController.deployERC20For`).
    uint8 internal constant DEPLOY_ERC20 = 8;

    /// @notice Set a project's token to an existing ERC-20 contract (`JBController.setTokenFor`).
    uint8 internal constant SET_TOKEN = 9;

    /// @notice Mint new project tokens and allocate them to a beneficiary (`JBController.mintTokensOf`).
    /// @dev Only works if the project's ruleset allows owner minting.
    uint8 internal constant MINT_TOKENS = 10;

    /// @notice Burn project tokens on behalf of a token holder, reducing the total supply
    /// (`JBController.burnTokensOf`).
    uint8 internal constant BURN_TOKENS = 11;

    /// @notice Claim internal token credits as ERC-20 tokens on behalf of a holder
    /// (`JBController.claimTokensFor`).
    uint8 internal constant CLAIM_TOKENS = 12;

    /// @notice Transfer internal token credits (unclaimed tokens) to another address
    /// (`JBController.transferCreditsFrom`).
    uint8 internal constant TRANSFER_CREDITS = 13;

    /// @notice Set a project's controller — the contract that manages its rulesets and token issuance
    /// (`JBDirectory.setControllerOf`).
    /// @dev Changing the controller is a significant governance action.
    uint8 internal constant SET_CONTROLLER = 14;

    /// @notice Replace a project's full list of payment terminals, which can add or remove terminals
    /// (`JBDirectory.setTerminalsOf`).
    /// @dev This can remove the primary terminal — use with caution.
    uint8 internal constant SET_TERMINALS = 15;

    /// @notice Add a new terminal to a project when setting a primary terminal for a token
    /// (`JBDirectory.setPrimaryTerminalOf`, when it implicitly adds a new terminal).
    uint8 internal constant ADD_TERMINALS = 16;

    /// @notice Set which terminal is the primary one for receiving a specific token
    /// (`JBDirectory.setPrimaryTerminalOf`).
    uint8 internal constant SET_PRIMARY_TERMINAL = 17;

    /// @notice Spend funds from a project's surplus allowance — discretionary funds beyond payout limits
    /// (`JBMultiTerminal.useAllowanceOf`).
    uint8 internal constant USE_ALLOWANCE = 18;

    /// @notice Configure how a project's payouts and reserved tokens are split among recipients
    /// (`JBController.setSplitGroupsOf`).
    uint8 internal constant SET_SPLIT_GROUPS = 19;

    /// @notice Add a price feed that converts between two currencies for a project's accounting
    /// (`JBController.addPriceFeedFor`).
    uint8 internal constant ADD_PRICE_FEED = 20;

    /// @notice Register new token types that a project's terminal can accept as payment
    /// (`JBMultiTerminal.addAccountingContextsFor`).
    uint8 internal constant ADD_ACCOUNTING_CONTEXTS = 21;

    /// @notice Update the on-chain metadata (name, symbol, etc.) of a project's ERC-20 token
    /// (`JBController.setTokenMetadataOf`).
    uint8 internal constant SET_TOKEN_METADATA = 22;

    /// @notice Sign messages on behalf of a project's ERC-20 token via ERC-1271
    /// (`JBERC20.isValidSignature`).
    /// @dev Used for Etherscan contract verification and other off-chain signature validation.
    uint8 internal constant SIGN_FOR_ERC20 = 23;

    /* ── nana-721-hook-v6
    ───────────────────────────────────────────────
    */

    /// @notice Add, remove, or modify NFT tiers for a project's 721 hook
    /// (`JB721TiersHook.adjustTiers`).
    uint8 internal constant ADJUST_721_TIERS = 24;

    /// @notice Update the metadata (base URI, contract URI, token URI resolver) of a project's NFT collection
    /// (`JB721TiersHook.setMetadata`).
    uint8 internal constant SET_721_METADATA = 25;

    /// @notice Mint NFTs directly to a beneficiary without requiring payment, typically for reserved or promotional
    /// NFTs (`JB721TiersHook.mintFor`).
    uint8 internal constant MINT_721 = 26;

    /// @notice Set a discount percentage for a specific NFT tier, reducing the payment required to mint
    /// (`JB721TiersHook.setDiscountPercentOf`).
    uint8 internal constant SET_721_DISCOUNT_PERCENT = 27;

    /* ── nana-buyback-hook-v6
    ───────────────────────────────────────────
    */

    /// @notice Set the TWAP (time-weighted average price) window used by a project's buyback hook to determine when
    /// buying tokens on a DEX is cheaper than minting (`JBBuybackHook.setTwapWindowOf`).
    uint8 internal constant SET_BUYBACK_TWAP = 28;

    /// @notice Set which Uniswap V4 pool a project's buyback hook uses for token buybacks
    /// (`JBBuybackHook.setPoolFor`).
    uint8 internal constant SET_BUYBACK_POOL = 29;

    /// @notice Configure or permanently lock a project's buyback hook
    /// (`JBBuybackHookRegistry.setHookFor` and `JBBuybackHookRegistry.lockHookFor`).
    /// @dev An operator with this permission can lock the hook, preventing future changes.
    uint8 internal constant SET_BUYBACK_HOOK = 30;

    /* ── nana-router-terminal-v6
    ────────────────────────────────────────
    */

    /// @notice Configure or permanently lock a project's router terminal, which routes payments through a DEX
    /// (`JBRouterTerminalRegistry.setTerminalFor` and `JBRouterTerminalRegistry.lockTerminalFor`).
    /// @dev An operator with this permission can lock the terminal, preventing future changes.
    uint8 internal constant SET_ROUTER_TERMINAL = 31;

    /* ── nana-suckers-v6
    ────────────────────────────────────────────────
    */

    /// @notice Map a token on one chain to its counterpart on another chain within a cross-chain sucker bridge
    /// (`JBSucker.mapToken`).
    uint8 internal constant MAP_SUCKER_TOKEN = 32;

    /// @notice Deploy cross-chain sucker bridges for a project, enabling token bridging between chains
    /// (`JBSuckerRegistry.deploySuckersFor`).
    /// @dev When the configuration's `peer` is `address(0)` or `address(this)` (default symmetric-address peering),
    /// `DEPLOY_SUCKERS` is sufficient. Registering a non-symmetric explicit peer also requires `SET_SUCKER_PEER`.
    uint8 internal constant DEPLOY_SUCKERS = 33;

    /// @notice Register a non-symmetric explicit peer address when deploying a cross-chain sucker
    /// (`JBSuckerRegistry.deploySuckersFor` with `configuration.peer` != 0 and != `address(this)`).
    /// @dev The explicit-peer field bypasses the same-address peering invariant, so any operator that can set it
    /// can authorize mint-from-arbitrary-roots. This permission is intentionally narrower than `DEPLOY_SUCKERS` so
    /// that ops automation with `DEPLOY_SUCKERS` cannot register attacker-controlled peers.
    uint8 internal constant SET_SUCKER_PEER = 34;

    /// @notice Enable the emergency hatch on a cross-chain sucker, allowing stuck tokens to be recovered
    /// (`JBSucker.enableEmergencyHatchFor`).
    uint8 internal constant SUCKER_SAFETY = 35;

    /// @notice Set the deprecation status of a cross-chain sucker, progressing it through its shutdown lifecycle
    /// (`JBSucker.setDeprecation`).
    uint8 internal constant SET_SUCKER_DEPRECATION = 36;

    /* ── revnet-core-v6
    ─────────────────────────────────────────────────
    */

    /// @notice Open a loan against project tokens as collateral on behalf of a token holder
    /// (`REVLoans.borrowFrom`).
    uint8 internal constant OPEN_LOAN = 37;

    /// @notice Move loan collateral between projects on behalf of a loan owner
    /// (`REVLoans.reallocateCollateralFromLoan`).
    uint8 internal constant REALLOCATE_LOAN = 38;

    /// @notice Repay a loan on behalf of the loan owner, returning collateral tokens
    /// (`REVLoans.repayLoan`).
    uint8 internal constant REPAY_LOAN = 39;
}
