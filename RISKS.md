# RISKS.md -- nana-permission-ids-v6

Constants-only library defining permission ID values used throughout the Bananapus ecosystem. Contains no logic, no state, and no external calls.

## 1. Known Risks

- **ROOT permission (ID 1).** ROOT grants all permissions across every contract. Any address granted ROOT can perform any permissioned operation on any project. Should never be granted to untrusted addresses.
- **SET_BUYBACK_HOOK includes lock (ID 28).** Gates both `setHookFor` and `lockHookFor`. An operator with this permission can permanently lock the buyback hook configuration.
- **SET_ROUTER_TERMINAL includes lock (ID 29).** Gates both `setTerminalFor` and `lockTerminalFor`. An operator can permanently lock the router terminal.
- **ID collision risk.** Permission IDs are manually assigned sequential uint8 values. Adding new IDs requires coordination to avoid collision. Library is append-only.
- **No runtime enforcement.** This library only defines constants. Enforcement happens in consuming contracts. A mismatch between the ID used here and the ID checked in a consumer would silently fail.
- **High-impact permission IDs (fund-moving).** IDs that control fund flow should receive the most audit scrutiny: `ROOT` (1, grants everything), `CASH_OUT_TOKENS` (5, triggers withdrawals), `SEND_PAYOUTS` (6, triggers payout distribution), `USE_ALLOWANCE` (7, draws from surplus), `SET_SPLIT_GROUPS` (8, controls where payouts go), `SET_TERMINALS` (13, redirects all fund flows), `MIGRATE_TERMINAL` (14, moves balances). Of these, ROOT + SET_TERMINALS + MIGRATE_TERMINAL are the most dangerous — they can redirect all of a project's funds.
- **Wildcard `projectId=0` semantics.** When a permission is granted with `projectId=0`, it applies to ALL projects. This is used by system contracts (e.g., `REVLoans` gets `USE_ALLOWANCE` with `projectId=0`). A bug in a contract holding wildcard permissions affects every project in the ecosystem, not just one. Only system-level contracts should hold wildcard permissions.

## 2. Design Notes

- Permission 0 is reserved and cannot be set.
- IDs are `uint8` (0-255), with 1-33 currently assigned.
- IDs 34-255 are available for future ecosystem extensions.
- IDs 34-255 are available for ecosystem extensions. Third-party contracts can define their own permission IDs in this range, but must coordinate to avoid collisions. No on-chain registry exists for custom IDs — collision detection is purely social.
- This library has zero dependencies -- it is the leaf of the dependency graph.
