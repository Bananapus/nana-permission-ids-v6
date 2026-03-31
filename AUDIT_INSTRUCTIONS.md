# Audit Instructions

This repo is only permission ID constants, but the constants are security-critical because many repos key access control off them.

## Objective

Find issues that:
- assign duplicate IDs to different semantic permissions
- mismatch IDs that downstream repos assume are canonical
- create ordering or collision hazards for future permission additions

## Scope

In scope:
- `src/JBPermissionIds.sol`

## Critical Invariants

1. Each permission semantic has one stable numeric ID.
2. No two distinct permissions share an ID.
3. IDs match the expectations of all dependent repos in this workspace.

## Threat Model

Prioritize stale or inconsistent constants, especially where wildcard grants or deployer permissions depend on a specific numeric value.

## Build And Verification

Standard workflow:
- `npm install`
- `forge build`

A meaningful finding here should show a real downstream permission check becoming broader, narrower, or mismatched because of the constant set.
