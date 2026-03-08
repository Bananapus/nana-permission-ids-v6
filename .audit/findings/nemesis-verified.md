# N E M E S I S — Verified Findings

## Scope
- **Language:** Solidity (^0.8.0)
- **Modules analyzed:** 1 (`src/JBPermissionIds.sol`)
- **Deploy scripts:** 0 (no `script/` directory exists)
- **Functions analyzed:** 0 (library contains only `uint8 internal constant` declarations)
- **Coupled state pairs mapped:** 0 (no state exists)
- **Mutation paths traced:** 0 (no mutations exist)
- **Nemesis loop iterations:** 2 (Pass 1: Feynman, Pass 2: State — converged immediately)

## Codebase Characterization

`JBPermissionIds` is a **pure constants library** — it defines 32 `uint8 internal constant` values (IDs 1–32) used as permission identifiers across the Bananapus/Juicebox V6 ecosystem. It contains:

- **No functions** (no entry points, no attack surface within this contract)
- **No state variables** (no storage, no coupled state)
- **No external calls** (no reentrancy, no call ordering concerns)
- **No value storage** (no funds, no tokens, no accounting)

The security-relevant properties of this library are:
1. **Uniqueness** — no two constants share the same value
2. **Contiguity** — values 1–32 with no gaps (ID 0 intentionally unused)
3. **Correctness** — names and comments accurately describe the gated operations

## Nemesis Map (Phase 1 Cross-Reference)

Not applicable — no functions × state × couplings exist.

## Verification Summary

| ID | Source | Coupled Pair | Breaking Op | Severity | Verdict |
|----|--------|-------------|-------------|----------|---------|
| NM-001 | Feynman Q4.5 | — | — | LOW (Info) | TRUE POS |

## Uniqueness & Contiguity Verification

All 32 permission IDs verified:

| Constant | Value | Status |
|----------|-------|--------|
| ROOT | 1 | Unique ✓ |
| QUEUE_RULESETS | 2 | Unique ✓ |
| LAUNCH_RULESETS | 3 | Unique ✓ |
| CASH_OUT_TOKENS | 4 | Unique ✓ |
| SEND_PAYOUTS | 5 | Unique ✓ |
| MIGRATE_TERMINAL | 6 | Unique ✓ |
| SET_PROJECT_URI | 7 | Unique ✓ |
| DEPLOY_ERC20 | 8 | Unique ✓ |
| SET_TOKEN | 9 | Unique ✓ |
| MINT_TOKENS | 10 | Unique ✓ |
| BURN_TOKENS | 11 | Unique ✓ |
| CLAIM_TOKENS | 12 | Unique ✓ |
| TRANSFER_CREDITS | 13 | Unique ✓ |
| SET_CONTROLLER | 14 | Unique ✓ |
| SET_TERMINALS | 15 | Unique ✓ |
| SET_PRIMARY_TERMINAL | 16 | Unique ✓ |
| USE_ALLOWANCE | 17 | Unique ✓ |
| SET_SPLIT_GROUPS | 18 | Unique ✓ |
| ADD_PRICE_FEED | 19 | Unique ✓ |
| ADD_ACCOUNTING_CONTEXTS | 20 | Unique ✓ |
| ADJUST_721_TIERS | 21 | Unique ✓ |
| SET_721_METADATA | 22 | Unique ✓ |
| MINT_721 | 23 | Unique ✓ |
| SET_721_DISCOUNT_PERCENT | 24 | Unique ✓ |
| SET_BUYBACK_TWAP | 25 | Unique ✓ |
| SET_BUYBACK_POOL | 26 | Unique ✓ |
| SET_BUYBACK_HOOK | 27 | Unique ✓ |
| SET_ROUTER_TERMINAL | 28 | Unique ✓ |
| MAP_SUCKER_TOKEN | 29 | Unique ✓ |
| DEPLOY_SUCKERS | 30 | Unique ✓ |
| SUCKER_SAFETY | 31 | Unique ✓ |
| SET_SUCKER_DEPRECATION | 32 | Unique ✓ |

**Contiguity:** Values 1–32 form a complete, gap-free sequence. ✓
**Zero avoidance:** ID 0 is intentionally unused (avoids default/uninitialized confusion). ✓
**uint8 headroom:** 223 remaining IDs available (33–255). ✓

## Verified Findings (TRUE POSITIVES only)

### Finding NM-001: Single Permission ID Gates Multiple Distinct Operations
**Severity:** LOW (Informational)
**Source:** Feynman Pass 1, Category 4 (Assumptions), Q4.5
**Verification:** Code trace — confirmed by reading comments at L44-45 and L48-49

**Observation:**
Two permission IDs each gate two semantically distinct operations:

- `SET_BUYBACK_HOOK` (27) gates both `JBBuybackHookRegistry.setHookFor` AND `JBBuybackHookRegistry.lockHookFor`
- `SET_ROUTER_TERMINAL` (28) gates both `JBRouterTerminalRegistry.setTerminalFor` AND `JBRouterTerminalRegistry.lockTerminalFor`

**Implication:**
A project owner cannot grant an operator permission to *set* a hook/terminal without also granting permission to *lock* it (making it permanent). Conversely, they cannot grant *lock* permission without also granting *set* permission.

This is a deliberate design choice — not a bug. The "set" and "lock" operations are intentionally bundled. However, if a future use case requires finer-grained separation (e.g., allowing an operator to set but not lock), a new permission ID would need to be added.

**Impact:** None in current design. Informational only.

---

## Feedback Loop Discoveries

None. No cross-feed findings emerged because the codebase has no state, no functions, and no mutation paths for the two auditors to cross-pollinate on.

## False Positives Eliminated

None generated — the codebase's simplicity (pure constants, no logic) produced no false positive hypotheses.

## Downgraded Findings

None.

## Summary

- Total constants analyzed: 32
- Coupled state pairs mapped: 0
- Nemesis loop iterations: 2 (converged immediately)
- Raw findings (pre-verification): 0 C | 0 H | 0 M | 1 L
- Feedback loop discoveries: 0
- After verification: 1 TRUE POSITIVE | 0 FALSE POSITIVE | 0 DOWNGRADED
- **Final: 0 CRITICAL | 0 HIGH | 0 MEDIUM | 1 LOW**

## Auditor's Note

This codebase is exceptionally simple and well-constructed. The `JBPermissionIds` library:

1. **Avoids ID 0** — preventing default-value confusion in permission checks
2. **Uses contiguous IDs** — making it easy to verify completeness
3. **Uses `uint8 internal constant`** — constants are inlined at compile time, immutable, and gas-free to reference
4. **Groups IDs by consuming contract** — with clear section comments for each subsystem
5. **Documents the gated function** for every permission ID

The library carries zero runtime attack surface. Its security properties depend entirely on the correctness of the constant values, which has been fully verified above. The one LOW finding (NM-001) is a design observation, not a vulnerability.
