# User Journeys

## Who This Repo Serves

- integrators deciding which permission to grant
- auditors reviewing whether an operator has too much power
- maintainers extending the ecosystem without colliding permission semantics

## Journey 1: Map A Product Action To The Right Permission

**Starting state:** a contract or UI needs to authorize an operator action somewhere in the V6 stack.

**Success:** you grant the smallest permission that matches the intended action.

**Flow**
1. Identify the action, such as queueing rulesets, cashing out on behalf of a holder, adjusting NFT tiers, or deploying suckers.
2. Look up the canonical ID in `JBPermissionIds`.
3. Grant that permission through `JBPermissions` on the relevant project.
4. Reuse the shared ID everywhere rather than inventing repo-local meanings.

## Journey 2: Review An Existing Operator Setup

**Starting state:** a project already has operators and you need to know what they can really do.

**Success:** you can explain the operator's authority in protocol terms instead of by raw integers.

**Flow**
1. Read the granted numeric IDs.
2. Translate them through this repo's constant set.
3. Check whether those permissions combine into a broader power than the operator was supposed to have.

## Journey 3: Add A New Ecosystem Surface Without Permission Drift

**Starting state:** a new contract surface needs permission-gated behavior.

**Success:** the new surface stays aligned with the ecosystem's shared permission vocabulary.

**Flow**
1. Reuse an existing permission ID if the action is semantically the same.
2. Add a new ID only if the action is genuinely distinct.
3. Update docs and downstream repos so the new meaning is not ambiguous.

**This repo is not an end-user flow.** It is the glossary that keeps every permissioned flow legible.
