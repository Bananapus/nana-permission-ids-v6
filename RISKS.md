# RISKS.md -- nana-permission-ids-v6

Constants-only library defining permission ID values used throughout the Bananapus ecosystem. Contains no logic, no state, and no external calls.

## 1. Known Risks

- **ROOT permission (ID 1).** ROOT grants all permissions across every contract. Any address granted ROOT can perform any permissioned operation on any project. Should never be granted to untrusted addresses.
- **SET_BUYBACK_HOOK includes lock (ID 28).** Gates both `setHookFor` and `lockHookFor`. An operator with this permission can permanently lock the buyback hook configuration.
- **SET_ROUTER_TERMINAL includes lock (ID 29).** Gates both `setTerminalFor` and `lockTerminalFor`. An operator can permanently lock the router terminal.
- **ID collision risk.** Permission IDs are manually assigned sequential uint8 values. Adding new IDs requires coordination to avoid collision. Library is append-only.
- **No runtime enforcement.** This library only defines constants. Enforcement happens in consuming contracts. A mismatch between the ID used here and the ID checked in a consumer would silently fail.

## 2. Design Notes

- Permission 0 is reserved and cannot be set.
- IDs are `uint8` (0-255), with 1-33 currently assigned.
- IDs 34-255 are available for future ecosystem extensions.
- This library has zero dependencies -- it is the leaf of the dependency graph.
