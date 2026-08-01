<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: Tracker as Source of Truth

**ALWAYS enforce:** Use the issue tracker's CLI commands resolved from configuration to query the tracker for authoritative issue state. Never trust local files or checklist documentation alone.

## Hard constraints

- Before working on a feature, verify its status using the tracker's configured issue view command.
- Before creating issues, check for duplicates using the tracker's configured issue query command.
- All issue lifecycle operations (create, close, edit, transition) MUST use the tracker's configured issue management commands — never modify local files as the primary operation.
- Every local specification file MUST include the tracker issue ID in its YAML frontmatter (`issue_id: <int>`).
- When referencing Issue IDs in markdown, use the live tracker Issue number — never hard-code or assume numbers.
- When constructing links to files in issue descriptions, dynamically determine the remote URL from the repository settings (e.g., `meta.upstream_repository`). Never use relative paths like `../features/...` in issue bodies.
- **Registered Issues Must Have A Local Specification**: every tracker issue carrying the Epic or Feature label MUST have a corresponding local specification file. A registered issue with no file means the branch baseline is incomplete, and the reconciler will write checklist state back to an issue whose specification nobody can read.
- **Local Indices Must Not Collide With Registered Issues**: a local specification whose ordinal (`epic-02`, `feat-07`) is already claimed on the tracker by a *differently titled* issue is a collision and MUST be renumbered. Reconciliation addresses specifications by ordinal, so the ambiguity silently retargets updates at the wrong issue.

## What local files are for

- Local markdown files (`docs/epics/`, `docs/features/`, etc.) are the specification source, but their checklist states may be stale.
- Always sync local state with the tracker state using the backlog reconciliation script (e.g., `reconcile_backlog.py`).
- The authoritative "done" state lives in the issue tracker, not in local frontmatter.

## Relationship to other rules

- See `rules/platform-independence.md` for specification content rules (WHAT vs HOW) and for all Mermaid syntax constraints.
- See `.pipeline/constitution.md` § *Unique Backlog Identifiers* for the issue ID frontmatter mandate.
- See `.pipeline/constitution.md` § *Agent Behavior* for commit and branch naming conventions referencing issue numbers.
- See `.pipeline/constitution.md` § *CMMI Level 3 & Scrum Issue Lifecycle Rules* for the states an agent may set. An agent may reach `Fixed / Resolved`; `Closed` requires Product Owner validation.

> **Consolidation note (issue #284):** this file supersedes the former
> `rules/github-source-of-truth.md`, which stated the same mandate in
> provider-specific wording. That file has been deleted and its unique clauses —
> the `issue_id` frontmatter mandate and this cross-reference section — merged here.
> Do not reintroduce a second statement of this rule; the fork drifted last time.

## Why

Local files can be contaminated, outdated, or contain broken links. The configured issue tracker is the canonical state store. Querying it directly prevents agents from working on closed issues, creating duplicates, or referencing stale data.
