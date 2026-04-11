# Permission IDs Risk Register

Constants-only library defining permission ID values used throughout the Juicebox V6 ecosystem. The main failure mode is not local arithmetic; it is ecosystem-wide semantic drift if contracts disagree on what a permission ID means.

## How to use this file

- Read `Priority risks` first; these are the ways a tiny library can create very large blast radius.
- Use the design notes to understand why stability and coordination matter more here than contract complexity.
- Treat any change in this repo as an ecosystem migration event, not a routine edit.

## Priority risks

| Priority | Risk | Why it matters | Primary controls |
|----------|------|----------------|------------------|
| P0 | Semantic drift across repos | If two repos interpret the same `uint8` differently, access control breaks silently across the ecosystem. | Single source of truth, strict review, and synchronized downstream updates. |
| P1 | Reordering or repurposing existing IDs | Changing established IDs can create backward-incompatible authority bugs without any contract-level revert. | Append-only discipline and explicit migration communication. |
| P2 | Incomplete ecosystem adoption | A new permission ID is only safe if every dependent repo and deploy script understands it. | Cross-repo review and deployment coordination. |

## 1. Known Risks

- **ROOT permission (ID 1).** ROOT grants all permissions across every contract. Any address granted ROOT can perform any permissioned operation on any project. Should never be granted to untrusted addresses.
- **SET_BUYBACK_HOOK includes lock (ID 30).** Gates both `setHookFor` and `lockHookFor`. An operator with this permission can permanently lock the buyback hook configuration.
- **SET_ROUTER_TERMINAL includes lock (ID 31).** Gates both `setTerminalFor` and `lockTerminalFor`. An operator can permanently lock the router terminal.
- **ID collision risk.** Permission IDs are manually assigned sequential uint8 values. Adding new IDs requires coordination to avoid collision. Library is append-only.
- **No runtime enforcement.** This library only defines constants. Enforcement happens in consuming contracts. A mismatch between the ID used here and the ID checked in a consumer would silently fail.
- **High-impact permission IDs (fund-moving).** IDs that control fund flow should receive the most audit scrutiny: `ROOT` (1, grants everything), `CASH_OUT_TOKENS` (4, triggers withdrawals), `SEND_PAYOUTS` (5, triggers payout distribution), `MIGRATE_TERMINAL` (6, moves balances), `SET_TERMINALS` (15, redirects all fund flows), `USE_ALLOWANCE` (18, draws from surplus), `SET_SPLIT_GROUPS` (19, controls where payouts go). Of these, ROOT + SET_TERMINALS + MIGRATE_TERMINAL are the most dangerous — they can redirect all of a project's funds.
- **SIGN_FOR_ERC20 (ID 23).** Grants permission to sign messages on behalf of a project's ERC-20 token via ERC-1271. Used for Etherscan contract verification and other off-chain signature validation. Should only be granted to trusted addresses since it controls the token's signing authority.
- **Wildcard `projectId=0` semantics.** When a permission is granted with `projectId=0`, it applies to ALL projects. This is used by system contracts (e.g., `REVLoans` gets `USE_ALLOWANCE` with `projectId=0`). A bug in a contract holding wildcard permissions affects every project in the ecosystem, not just one. Only system-level contracts should hold wildcard permissions.

## 2. Design Notes

- Permission 0 is reserved and cannot be set.
- IDs are `uint8` (0-255), with 1-40 currently assigned.
- IDs 36-40 are used by `revnet-core-v6` for operator delegation: `HIDE_TOKENS` (36), `OPEN_LOAN` (37), `REALLOCATE_LOAN` (38), `REPAY_LOAN` (39), `REVEAL_TOKENS` (40).
- IDs 41-255 are available for ecosystem extensions. Third-party contracts can define their own permission IDs in this range, but must coordinate to avoid collisions. No on-chain registry exists for custom IDs — collision detection is purely social.
- This library has zero dependencies -- it is the leaf of the dependency graph.
