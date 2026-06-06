// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {JBPermissionIds} from "../../src/JBPermissionIds.sol";

/// @notice Functional-correctness harness for the `JBPermissionIds` constants library.
/// @dev This package is constants-only. "Correctness" means: (1) every ID is a unique, non-zero `uint8`; (2) the
/// namespace is the exact contiguous range `[1, 39]` (a bijection onto names); and (3) the constants compose with the
/// pure bit-packing logic that `JBPermissions` (nana-core-v6) uses to enforce permissions, i.e. granting one ID sets
/// exactly that bit, ID 0 stays the reserved sentinel, and the ROOT bit (1) short-circuits any check.
///
/// Each property is DUAL-implemented per the V6 house convention (see nana-core-v6/test/formal/FeeProperties.t.sol):
/// a `check_*` entry-point for Halmos (symbolic) and a `testFuzz_*` entry-point for forge (random). The bit-shift
/// helpers below are an EXACT mirror of `JBPermissions._includesPermission` / `_packedPermissions`
/// (nana-core-v6/src/JBPermissions.sol:243-245 and the packing loop) so the proof binds the constants to their
/// real runtime meaning.
contract JBPermissionIdsProperties is Test {
    // The full set of named IDs, in declaration order. Kept in sync with src/JBPermissionIds.sol.
    function _allIds() internal pure returns (uint8[39] memory ids) {
        ids = [
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
    }

    // --- Exact mirror of nana-core-v6/src/JBPermissions.sol pure permission logic. ---

    /// @dev Mirror of `JBPermissions._includesPermission`.
    function _includesPermission(uint256 permissions, uint256 permissionId) internal pure returns (bool) {
        return ((permissions >> permissionId) & 1) == 1;
    }

    /// @dev Mirror of `JBPermissions._packedPermissions` for the single-ID grant case used by these properties.
    function _packOne(uint8 permissionId) internal pure returns (uint256) {
        // forge-lint: disable-next-line(incorrect-shift) — shift-by-id is intentional and mirrors JBPermissions.
        return uint256(1) << permissionId;
    }

    //*********************************************************************//
    // ------------------- Property 1: uniqueness ------------------------ //
    //*********************************************************************//
    // INVARIANTS.md A.2.1 / AUDIT_INSTRUCTIONS critical invariant 2: "No two distinct permissions share an ID."
    // Contiguity alone does not state this; we prove it directly (all pairs distinct).

    function _assertAllDistinct() internal pure {
        uint8[39] memory ids = _allIds();
        for (uint256 i; i < ids.length; ++i) {
            for (uint256 j = i + 1; j < ids.length; ++j) {
                assert(ids[i] != ids[j]);
            }
        }
    }

    /// @notice Halmos: every named permission ID is distinct from every other.
    function check_idsAreUnique() public pure {
        _assertAllDistinct();
    }

    /// @notice Forge: every named permission ID is distinct from every other.
    function testFuzz_idsAreUnique(uint256) public pure {
        _assertAllDistinct();
    }

    //*********************************************************************//
    // ------- Property 2: every ID is a valid, non-zero uint8 ----------- //
    //*********************************************************************//
    // INVARIANTS.md A.1.1 (each ID is a uint8 => <= 255) and A.1.2 (ID 0 is the reserved sentinel; no constant is 0).
    // Bit `permissionId` must be expressible: `1 << id` must not be 0 for id in [1, 255].

    function _assertEachIdInGrantableRange() internal pure {
        uint8[39] memory ids = _allIds();
        for (uint256 i; i < ids.length; ++i) {
            // Non-zero: ID 0 is reserved and rejected by JBPermissions.setPermissionsFor.
            assert(ids[i] != 0);
            // uint8 by construction is <= 255; assert the shift is non-degenerate (bit exists in the uint256 mask).
            assert((uint256(1) << ids[i]) != 0);
        }
    }

    /// @notice Halmos: every ID is non-zero and addresses a real bit in the packed uint256 mask.
    function check_idsAreGrantable() public pure {
        _assertEachIdInGrantableRange();
    }

    /// @notice Forge: every ID is non-zero and addresses a real bit in the packed uint256 mask.
    function testFuzz_idsAreGrantable(uint256) public pure {
        _assertEachIdInGrantableRange();
    }

    //*********************************************************************//
    // ------- Property 3: namespace is the exact range [1, 39] ---------- //
    //*********************************************************************//
    // INVARIANTS.md A.1.5 / Section D.2: the set of values equals {1,...,39} with no gaps (a bijection onto names).
    // This subsumes contiguity AND completeness: every integer in [1,39] is present exactly once.

    function _assertNamespaceIsExactRange() internal pure {
        uint8[39] memory ids = _allIds();
        // For each target value v in [1,39], exactly one constant equals v.
        for (uint256 v = 1; v <= 39; ++v) {
            uint256 hits;
            for (uint256 i; i < ids.length; ++i) {
                if (uint256(ids[i]) == v) ++hits;
            }
            assert(hits == 1);
        }
        // And nothing falls outside [1,39].
        for (uint256 i; i < ids.length; ++i) {
            assert(ids[i] >= 1 && ids[i] <= 39);
        }
    }

    /// @notice Halmos: the value set is exactly {1,...,39}, each present once.
    function check_namespaceIsExactRange() public pure {
        _assertNamespaceIsExactRange();
    }

    /// @notice Forge: the value set is exactly {1,...,39}, each present once.
    function testFuzz_namespaceIsExactRange(uint256) public pure {
        _assertNamespaceIsExactRange();
    }

    //*********************************************************************//
    // --- Property 4: single-ID grant sets exactly that bit ------------- //
    //*********************************************************************//
    // INVARIANTS.md Section D.1: bit position == integer value of the constant. Granting only permission N must make
    // `hasPermission(N)` true and `hasPermission(M)` false for every other named M. This is the load-bearing tie
    // between this library and JBPermissions' runtime check.

    /// @notice Halmos: granting one ID isolates exactly its bit, for ANY two distinct grantable IDs.
    /// @dev Symbolic over the abstract IDs `a`, `b` (not the concrete named array — Halmos cannot index a
    /// fixed-size memory array with a symbolic offset; that variant is covered by the fuzz test below). Since every
    /// named constant is proven to live in `[1, 39] ⊂ [1, 255]` and to be pairwise-distinct (Properties 1-3), this
    /// abstract statement implies the concrete one for every named pair. This is the bit-isolation fact that ties
    /// `_packedPermissions` to `_includesPermission` in JBPermissions.
    function check_singleGrantIsolatesBit(uint8 a, uint8 b) public pure {
        vm.assume(a >= 1); // ID 0 is the reserved sentinel; real grants are >= 1.
        vm.assume(b >= 1);
        vm.assume(a != b);

        uint256 packed = _packOne(a);

        // The granted ID is included.
        assert(_includesPermission(packed, a));
        // A different ID is NOT included — no cross-talk between bits.
        assert(!_includesPermission(packed, b));
        // The reserved sentinel bit 0 is never set by a single non-zero grant.
        assert(!_includesPermission(packed, 0));
    }

    /// @notice Forge: granting one named ID sets exactly that bit; no other named ID reads as granted.
    /// @dev Not `view`/`pure`: forge-std's `assertTrue/assertFalse` records failures via cheatcode state writes.
    function testFuzz_singleGrantIsolatesBit(uint256 i) public {
        uint8[39] memory ids = _allIds();
        i = i % ids.length;

        uint256 packed = _packOne(ids[i]);
        assertTrue(_includesPermission(packed, ids[i]), "granted bit not set");

        for (uint256 k; k < ids.length; ++k) {
            if (ids[k] == ids[i]) continue;
            assertFalse(_includesPermission(packed, ids[k]), "unrelated bit set");
        }
        // ID 0 (reserved sentinel) is never implied by a single non-zero grant.
        assertFalse(_includesPermission(packed, 0), "sentinel bit 0 set");
    }

    //*********************************************************************//
    // --- Property 5: ROOT (bit 1) packs into the documented slot ------- //
    //*********************************************************************//
    // INVARIANTS.md A.1.3: ROOT == 1. JBPermissions short-circuits on `_includesPermission(perms, ROOT)`. We prove the
    // constant lands in bit 1 and that a ROOT-only grant reads as ROOT (the short-circuit precondition) while a
    // non-ROOT single grant does NOT read as ROOT (no accidental escalation).

    function _assertRootSlot() internal pure {
        assert(JBPermissionIds.ROOT == 1);

        // A ROOT-only grant satisfies the short-circuit precondition.
        uint256 rootGrant = _packOne(JBPermissionIds.ROOT);
        assert(_includesPermission(rootGrant, JBPermissionIds.ROOT));

        // A non-ROOT single grant must NOT read as ROOT (would be silent privilege escalation).
        uint256 nonRootGrant = _packOne(JBPermissionIds.REPAY_LOAN);
        assert(!_includesPermission(nonRootGrant, JBPermissionIds.ROOT));
    }

    /// @notice Halmos: ROOT lives in bit 1; ROOT grant reads as ROOT; a non-ROOT grant never reads as ROOT.
    function check_rootSlotIntegrity() public pure {
        _assertRootSlot();
    }

    /// @notice Forge: ROOT lives in bit 1; ROOT grant reads as ROOT; a non-ROOT grant never reads as ROOT.
    function testFuzz_rootSlotIntegrity(uint256) public pure {
        _assertRootSlot();
    }
}
