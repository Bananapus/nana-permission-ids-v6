# User Journeys

## Who This Repo Serves

- protocol and product engineers mapping actions to the right operator permission
- auditors checking whether a downstream repo reused or drifted from the shared permission vocabulary
- maintainers adding new permission surfaces without colliding with existing meaning

## Journey 1: Map A Product Action To The Right Permission

**Starting state:** a repo needs to guard an action with `JBPermissions`.

**Success:** the code imports the canonical constant instead of inventing a local numeric meaning.

**Flow**
1. Find the action's domain in `JBPermissionIds`, such as core, 721 hook, buyback, router, or sucker permissions.
2. Import the shared constant into the downstream repo.
3. Check the relevant caller against that constant through `JBPermissions`.

## Journey 2: Review An Existing Operator Setup

**Starting state:** a project or audit needs to understand what a granted permission actually means.

**Success:** the operator bitset can be read as named product actions instead of opaque integers.

**Flow**
1. Start with the permission bits granted on the project.
2. Map each bit back to the shared constant defined here.
3. Confirm that the downstream repo still uses that constant consistently at its authorization checks.

## Journey 3: Add A New Ecosystem Surface Without Permission Drift

**Starting state:** a new repo or feature needs a permission that does not fit any existing constant.

**Success:** the new constant is added once, in the right numeric range, and downstream packages can reuse it without ambiguity.

**Flow**
1. Pick the next unused ID in the relevant ecosystem range.
2. Add the named constant in `JBPermissionIds.sol`.
3. Update downstream repos to import that constant instead of duplicating the number.
4. Re-audit any docs or tests that explain the meaning of that permission.

## Hand-Offs

- Use [nana-core-v6](../nana-core-v6/USER_JOURNEYS.md) for the runtime permission registry that stores and checks these IDs.
- Use the relevant downstream repo when the question is about what a permissioned action actually does after authorization succeeds.
