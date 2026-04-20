# User Journeys

## Repo Purpose

This repo is the shared permission vocabulary for the V6 ecosystem. It does not store permissions or enforce them at runtime. It defines the constants that downstream repos should import so permissioned behavior stays clear and consistent.

## Primary Actors

- engineers choosing which permission constant should guard a feature
- auditors checking whether a repo drifted from the shared vocabulary
- maintainers extending the permission map without numeric collisions

## Key Surfaces

- `JBPermissionIds`: library of canonical permission constants used across V6 repos
- grouped constants for core, 721, router, buyback, sucker, revnet, and related actions
- reserved ranges documented in `README.md`, including `ROOT = 1`, ecosystem-managed IDs through `40`, and socially coordinated extension space above that

## Journey 1: Map A Product Action To The Right Permission

**Actor:** downstream engineer.

**Intent:** protect an action with the canonical permission constant instead of inventing a local number.

**Preconditions**
- the action is governed by `JBPermissions`
- the engineer knows which repo or domain owns the action

**Main Flow**
1. Find the action domain in `JBPermissionIds`, such as core, 721, router, buyback, or sucker permissions.
2. Import the constant into the downstream repo.
3. Use that constant in the runtime authorization check.
4. Treat bundled high-impact IDs like `SET_BUYBACK_HOOK` and `SET_ROUTER_TERMINAL` as broader powers than their short names suggest because they also gate locking.

**Failure Modes**
- the repo hardcodes a number locally and drifts from the shared vocabulary
- a repo picks the wrong existing constant because the action sounds similar but is not actually equivalent
- a team grants `ROOT` or wildcard permissions without appreciating the blast radius
- docs and tests describe a permission by nickname instead of the imported constant

**Postconditions**
- the downstream action is guarded by the shared permission vocabulary instead of a local numeric convention

## Journey 2: Review An Existing Operator Setup

**Actor:** auditor, operator, or integrator.

**Intent:** decode opaque permission bits into named actions.

**Preconditions**
- the operator bitset or granted permission IDs are already known
- the reviewer understands that this repo names permissions but does not prove how each repo uses them

**Main Flow**
1. Start with the permission bits granted on the project.
2. Map each bit to its named constant here.
3. Confirm the downstream repo still uses that constant consistently in authorization checks and docs.
4. Check whether any granted IDs are really funds-moving, routing, locking, or loan-management powers rather than low-risk admin toggles.

**Failure Modes**
- downstream code reuses a permission ID for a different meaning
- reviewers decode the bit correctly but underestimate what the downstream repo lets that permission do
- reviewers rely on this repo alone and skip the guarded code

**Postconditions**
- the reviewer has a named permission map and knows which downstream repos still need inspection

## Journey 3: Add A New Ecosystem Surface Without Permission Drift

**Actor:** maintainer extending the permission vocabulary.

**Intent:** add a new permission constant that the rest of the ecosystem can reuse.

**Preconditions**
- no existing constant already matches the new action
- the maintainer understands the numeric ranges already in use

**Main Flow**
1. Choose the next unused ID in the relevant range.
2. Add the named constant in `JBPermissionIds.sol`.
3. Update downstream repos to import the constant instead of duplicating the number.
4. Refresh docs and tests that explain the permission.
5. If the new ID goes above the ecosystem-managed range, coordinate externally so third-party packages do not collide on the same number.

**Failure Modes**
- a new repo defines its own numeric constant first and creates drift
- a new constant is added in the wrong semantic range, making later review harder
- a new ID silently expands what existing `ROOT` operators can do without that blast radius being reviewed
- documentation updates lag behind the code change

**Postconditions**
- the new ecosystem surface has a reusable canonical permission ID with coordinated downstream adoption

## Trust Boundaries

- this repo is trusted only as shared vocabulary
- actual storage and enforcement live elsewhere
- downstream repos can still misuse a constant even when they import the right one

## Hand-Offs

- Use [nana-core-v6](../nana-core-v6/USER_JOURNEYS.md) for the runtime permission registry that stores and checks these IDs.
- Use the relevant downstream repo when the question is about what a permissioned action does after authorization succeeds.
