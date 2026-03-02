# nana-permission-ids-v5

Library of `uint8` constants defining all permission IDs used with `JBPermissions` across the Juicebox V5 ecosystem.

## Architecture

| Contract | Description |
|----------|-------------|
| `JBPermissionIds` | Solidity library with 30 `uint8 internal constant` permission IDs. No state, no functions. |

### Permission ID Ranges

| IDs | Repository | Permissions |
|-----|------------|-------------|
| 1 | All | `ROOT` -- grants all permissions. |
| 2--19 | nana-core-v5 | `QUEUE_RULESETS`, `CASH_OUT_TOKENS`, `SEND_PAYOUTS`, `MIGRATE_TERMINAL`, `SET_PROJECT_URI`, `DEPLOY_ERC20`, `SET_TOKEN`, `MINT_TOKENS`, `BURN_TOKENS`, `CLAIM_TOKENS`, `TRANSFER_CREDITS`, `SET_CONTROLLER`, `SET_TERMINALS`, `SET_PRIMARY_TERMINAL`, `USE_ALLOWANCE`, `SET_SPLIT_GROUPS`, `ADD_PRICE_FEED`, `ADD_ACCOUNTING_CONTEXTS` |
| 20--23 | nana-721-hook-v5 | `ADJUST_721_TIERS`, `SET_721_METADATA`, `MINT_721`, `SET_721_DISCOUNT_PERCENT` |
| 24--25 | nana-buyback-hook-v5 | `SET_BUYBACK_TWAP`, `SET_BUYBACK_POOL` |
| 26--27 | nana-swap-terminal-v5 | `ADD_SWAP_TERMINAL_POOL`, `ADD_SWAP_TERMINAL_TWAP_PARAMS` |
| 28--30 | nana-suckers-v5 | `MAP_SUCKER_TOKEN`, `DEPLOY_SUCKERS`, `SUCKER_SAFETY` |

## Install

```bash
npm install
```

## Develop

| Command | Description |
|---------|-------------|
| `forge build` | Compile contracts |
