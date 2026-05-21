// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {JBPermissionIds} from "../../src/JBPermissionIds.sol";

/// @notice Small Halmos entrypoints for the ecosystem permission namespace.
/// @dev This package is constants-only, so the useful machine-check is exact namespace drift: values must remain
/// contiguous from ROOT through REPAY_LOAN unless a future migration intentionally updates this proof.
contract JBPermissionIdsHalmos {
    /// @notice Proves the permission IDs are exactly the expected contiguous sequence.
    function check_permissionIdsAreContiguousAndStable() public pure {
        uint8[39] memory ids = [
            JBPermissionIds.ROOT,
            JBPermissionIds.QUEUE_RULESETS,
            JBPermissionIds.LAUNCH_RULESETS,
            JBPermissionIds.CASH_OUT_TOKENS,
            JBPermissionIds.SEND_PAYOUTS,
            JBPermissionIds.MIGRATE_TERMINAL,
            JBPermissionIds.SET_PROJECT_URI,
            JBPermissionIds.DEPLOY_ERC20,
            JBPermissionIds.SET_TOKEN,
            JBPermissionIds.MINT_TOKENS,
            JBPermissionIds.BURN_TOKENS,
            JBPermissionIds.CLAIM_TOKENS,
            JBPermissionIds.TRANSFER_CREDITS,
            JBPermissionIds.SET_CONTROLLER,
            JBPermissionIds.SET_TERMINALS,
            JBPermissionIds.ADD_TERMINALS,
            JBPermissionIds.SET_PRIMARY_TERMINAL,
            JBPermissionIds.USE_ALLOWANCE,
            JBPermissionIds.SET_SPLIT_GROUPS,
            JBPermissionIds.ADD_PRICE_FEED,
            JBPermissionIds.ADD_ACCOUNTING_CONTEXTS,
            JBPermissionIds.SET_TOKEN_METADATA,
            JBPermissionIds.SIGN_FOR_ERC20,
            JBPermissionIds.ADJUST_721_TIERS,
            JBPermissionIds.SET_721_METADATA,
            JBPermissionIds.MINT_721,
            JBPermissionIds.SET_721_DISCOUNT_PERCENT,
            JBPermissionIds.SET_BUYBACK_TWAP,
            JBPermissionIds.SET_BUYBACK_POOL,
            JBPermissionIds.SET_BUYBACK_HOOK,
            JBPermissionIds.SET_ROUTER_TERMINAL,
            JBPermissionIds.MAP_SUCKER_TOKEN,
            JBPermissionIds.DEPLOY_SUCKERS,
            JBPermissionIds.SET_SUCKER_PEER,
            JBPermissionIds.SUCKER_SAFETY,
            JBPermissionIds.SET_SUCKER_DEPRECATION,
            JBPermissionIds.OPEN_LOAN,
            JBPermissionIds.REALLOCATE_LOAN,
            JBPermissionIds.REPAY_LOAN
        ];

        for (uint256 i; i < ids.length;) {
            assert(ids[i] == i + 1);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Proves the first and final IDs stay pinned to the documented namespace bounds.
    function check_permissionNamespaceBounds() public pure {
        assert(JBPermissionIds.ROOT == 1);
        assert(JBPermissionIds.REPAY_LOAN == 39);
    }
}
