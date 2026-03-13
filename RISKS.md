# nana-permission-ids-v6 — Risks

## Trust Assumptions

This is a constants-only library with no runtime behavior. The risk surface is limited to the correctness of the ID assignments.

## Known Risks

| Risk | Description | Mitigation |
|------|-------------|------------|
| ID collision | If two repos use the same ID for different permissions, access control breaks | IDs are centrally managed in this single file |
| ROOT scope | ROOT (ID 1) grants ALL permissions across all contracts | Cannot be set for wildcard projectId=0; ROOT operators cannot grant ROOT |
| SET_TERMINALS scope | Includes ability to remove the primary terminal | Documented warning in source |
| SET_BUYBACK_HOOK / SET_ROUTER_TERMINAL scope | Each gates both setting AND locking (permanent) | Documented in source; granting means operator can lock |

## Design Notes

- Permission 0 is reserved and cannot be set
- IDs are `uint8` (0-255), with 1-33 currently assigned
- IDs 34-255 are available for future ecosystem extensions
- This library has zero dependencies — it is the leaf of the dependency graph
