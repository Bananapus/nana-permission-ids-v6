// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @notice Permission IDs for `JBPermissions`, used throughout the Bananapus ecosystem. See
/// [`JBPermissions`](https://github.com/Bananapus/nana-core/blob/main/src/JBPermissions.sol)
/// @dev `JBPermissions` allows one address to grant another address permission to call functions in Juicebox contracts
/// on their behalf. Each ID in `JBPermissionIds` grants access to a specific set of these functions.
library JBPermissionIds {
    uint8 internal constant ROOT = 1; // All permissions across every contract. Very dangerous. BE CAREFUL!

    /* Used by `nana-core`: https://github.com/Bananapus/nana-core */
    uint8 internal constant QUEUE_RULESETS = 2; // Permission to call `JBController.queueRulesetsOf`.
    uint8 internal constant LAUNCH_RULESETS = 3; // Permission to call `JBController.launchRulesetsFor`.
    uint8 internal constant CASH_OUT_TOKENS = 4; // Permission to call `JBMultiTerminal.cashOutTokensOf`.
    uint8 internal constant SEND_PAYOUTS = 5; // Permission to call `JBMultiTerminal.sendPayoutsOf`.
    uint8 internal constant MIGRATE_TERMINAL = 6; // Permission to call `JBMultiTerminal.migrateBalanceOf`.
    uint8 internal constant SET_PROJECT_URI = 7; // Permission to call `JBController.setUriOf`.
    uint8 internal constant DEPLOY_ERC20 = 8; // Permission to call `JBController.deployERC20For`.
    uint8 internal constant SET_TOKEN = 9; // Permission to call `JBController.setTokenFor`.
    uint8 internal constant MINT_TOKENS = 10; // Permission to call `JBController.mintTokensOf`.
    uint8 internal constant BURN_TOKENS = 11; // Permission to call `JBController.burnTokensOf`.
    uint8 internal constant CLAIM_TOKENS = 12; // Permission to call `JBController.claimTokensFor`.
    uint8 internal constant TRANSFER_CREDITS = 13; // Permission to call `JBController.transferCreditsFrom`.
    uint8 internal constant SET_CONTROLLER = 14; // Permission to call `JBDirectory.setControllerOf`.
    uint8 internal constant SET_TERMINALS = 15; // Permission to call `JBDirectory.setTerminalsOf`.
    // Be careful - `SET_TERMINALS` can be used to remove the primary terminal.
    uint8 internal constant ADD_TERMINALS = 16; // Permission to call `JBDirectory.setPrimaryTerminalOf` when it
    // implicitly adds a new terminal.
    uint8 internal constant SET_PRIMARY_TERMINAL = 17; // Permission to call `JBDirectory.setPrimaryTerminalOf`.
    uint8 internal constant USE_ALLOWANCE = 18; // Permission to call `JBMultiTerminal.useAllowanceOf`.
    uint8 internal constant SET_SPLIT_GROUPS = 19; // Permission to call `JBController.setSplitGroupsOf`.
    uint8 internal constant ADD_PRICE_FEED = 20; // Permission to call `JBController.addPriceFeedFor`.
    uint8 internal constant ADD_ACCOUNTING_CONTEXTS = 21; // Permission to call
    // `JBMultiTerminal.addAccountingContextsFor`.
    uint8 internal constant SET_TOKEN_METADATA = 22; // Permission to call
    // `JBController.setTokenMetadataOf`.
    /// @notice Permission to sign messages on behalf of a project's ERC-20 token via ERC-1271.
    /// @dev Used for Etherscan contract verification and other off-chain signature validation.
    uint8 internal constant SIGN_FOR_ERC20 = 23;

    /* Used by `nana-721-hook`: https://github.com/Bananapus/nana-721-hook */
    uint8 internal constant ADJUST_721_TIERS = 24; // Permission to call `JB721TiersHook.adjustTiers`.
    uint8 internal constant SET_721_METADATA = 25; // Permission to call `JB721TiersHook.setMetadata`.
    uint8 internal constant MINT_721 = 26; // Permission to call `JB721TiersHook.mintFor`.
    uint8 internal constant SET_721_DISCOUNT_PERCENT = 27; // Permission to call `JB721TiersHook.setDiscountPercentOf`.

    /* Used by `nana-buyback-hook`: https://github.com/Bananapus/nana-buyback-hook */
    uint8 internal constant SET_BUYBACK_TWAP = 28; // Permission to call `JBBuybackHook.setTwapWindowOf`.
    uint8 internal constant SET_BUYBACK_POOL = 29; // Permission to call `JBBuybackHook.setPoolFor`.
    /// @dev This single ID intentionally gates both setting and locking the buyback hook as a simplification.
    /// Granting this permission allows the operator to call both `JBBuybackHookRegistry.setHookFor` (to configure the
    /// hook) and `JBBuybackHookRegistry.lockHookFor` (to permanently lock the hook configuration). Project owners
    /// should be aware that an operator with this permission can lock the hook, preventing future changes.
    uint8 internal constant SET_BUYBACK_HOOK = 30; // Permission to call `JBBuybackHookRegistry.setHookFor` and
    // `JBBuybackHookRegistry.lockHookFor`.

    /* Used by `nana-router-terminal`: https://github.com/Bananapus/nana-router-terminal-v6 */
    /// @dev This single ID intentionally gates both setting and locking the router terminal as a simplification.
    /// Granting this permission allows the operator to call both `JBRouterTerminalRegistry.setTerminalFor` (to
    /// configure the terminal) and `JBRouterTerminalRegistry.lockTerminalFor` (to permanently lock the terminal
    /// configuration). Project owners should be aware that an operator with this permission can lock the terminal,
    /// preventing future changes.
    uint8 internal constant SET_ROUTER_TERMINAL = 31; // Permission to call
    // `JBRouterTerminalRegistry.setTerminalFor` and `JBRouterTerminalRegistry.lockTerminalFor`.

    /* Used by `nana-suckers`: https://github.com/Bananapus/nana-suckers */
    uint8 internal constant MAP_SUCKER_TOKEN = 32; // Permission to call `JBSucker.mapToken`.
    uint8 internal constant DEPLOY_SUCKERS = 33; // Permission to call `JBSuckerRegistry.deploySuckersFor`.
    uint8 internal constant SUCKER_SAFETY = 34; // Permission to call `JBSucker.enableEmergencyHatchFor`.
    uint8 internal constant SET_SUCKER_DEPRECATION = 35; // Permission to call `JBSucker.setDeprecation`.

    /* Used by `revnet-core`: https://github.com/Bananapus/revnet-core */
    /// @notice Permission to hide or reveal tokens on behalf of a holder via `REVHiddenTokens`.
    uint8 internal constant HIDE_TOKENS = 36;
    /// @notice Permission to open a loan on behalf of a token holder via `REVLoans.borrowFrom`.
    uint8 internal constant OPEN_LOAN = 37;
    /// @notice Permission to reallocate loan collateral on behalf of a loan owner via
    /// `REVLoans.reallocateCollateralFromLoan`.
    uint8 internal constant REALLOCATE_LOAN = 38;
    /// @notice Permission to repay a loan on behalf of a loan owner via `REVLoans.repayLoan`.
    uint8 internal constant REPAY_LOAN = 39;
    /// @notice Permission to reveal hidden tokens on behalf of a holder via `REVHiddenTokens`.
    uint8 internal constant REVEAL_TOKENS = 40;
}
