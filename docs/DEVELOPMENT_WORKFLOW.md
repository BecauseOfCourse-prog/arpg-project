# Specification-Driven Development Workflow

## Purpose

Use specifications as the shared, persistent context for the developer and Claude. Every meaningful change should have a reviewable description of its intended behavior, constraints, and acceptance criteria before implementation. The specification is also the change's delta documentation: it records what this change adds or alters and remains available after the change is complete.

## Documentation map

```text
CLAUDE.md                         Claude's required project instructions
docs/
  PROJECT_CONTEXT.md              Current product and technical baseline
  BACKLOG.md                      Prioritized work inventory and dependencies
  ARCHITECTURE.md                 High-level architecture map and proposals
  DEVELOPMENT_WORKFLOW.md         This process and documentation contract
  specs/
    README.md                     Specification index and status rules
    _template.md                  Template for a feature/system change
    <topic>/<change-name>.md       Change specifications and their history
  decisions/
    README.md                     Architecture decision index and status rules
    _template.md                  Architecture Decision Record template
    ADR-NNNN-short-title.md        Accepted and superseded decisions
```

## Required context for Claude

At the beginning of every task, Claude must read `CLAUDE.md`, `docs/PROJECT_CONTEXT.md`, `docs/BACKLOG.md`, and this workflow. It must then read the relevant active specification and any relevant ADRs before proposing or editing implementation. The user should not need to repeat decisions from prior chats: repository documentation is the durable context.

When a task has no relevant specification, Claude should draft one before implementing a meaningful feature or behavior change. For a small correction that does not change behavior or project decisions, it may edit directly and keep the relevant docs accurate.

## Change lifecycle

### 1. Understand

- Read the required context and inspect the relevant code and existing documentation.
- Identify applicable accepted decisions and constraints.
- State assumptions and conflicts. Do not turn an open question into a hidden requirement.

### 2. Specify

- Create a change specification from `docs/specs/_template.md` before implementation.
- Give it a stable, descriptive filename under an appropriate topic folder.
- Define scope, intended behavior, non-goals, affected systems, dependencies, and verifiable acceptance criteria.
- Record unresolved design questions as `Open`, with an owner or decision needed when known.
- Add the specification to `docs/specs/README.md` and mark it `Draft` until reviewed/accepted.
- Link the selected backlog item to the specification. Keep it `Ready` while the specification is `Draft`; change it to `Specified` only when the specification is accepted, then to `In Progress` when implementation begins.
- If the user has already explicitly provided the decisions for the requested change, document them and proceed without asking them to repeat those decisions.

### 3. Review the design

- Check the proposed change against the project context and accepted ADRs.
- Resolve contradictions before implementation, or clearly document the required decision.
- Mark the spec `Accepted` when it is ready to guide implementation. If the user asked for implementation as part of the task, acceptance of the requested scope is implied; do not add an unnecessary approval pause.

### 4. Implement

- Implement only the accepted scope. Keep code and authored content aligned with the spec.
- Update the specification when details change during implementation; explain meaningful deviations and their rationale.
- Create an ADR when the work establishes or changes a lasting architectural decision. Do not use ADRs for routine implementation details.

### 5. Verify and close

- Check every acceptance criterion using the verification requested by the user or defined by the project.
- For deterministic gameplay behavior, add or update automated tests with the project's selected test framework and run them for the change. Use manual editor playthroughs to check visual presentation and behavior that is difficult to assert automatically.
- Do not claim a criterion passed without evidence. Record checks performed and known gaps in the spec.
- Update `PROJECT_CONTEXT.md` when the accepted baseline, terminology, or lasting constraints change.
- Mark the spec `Complete` only when its scoped work and required documentation updates are complete; otherwise use `In Progress` or `Blocked` and explain why.
- Update the linked backlog item to `Done` when its scope is complete, or to `Dropped` if the work is cancelled.
- Include the spec, context, and ADR updates in the same reviewable change as the implementation whenever possible.

## Delta documentation rules

- A spec describes the delta from the current project behavior, not a duplicate of the whole design.
- Preserve completed specifications as historical records. Do not rewrite an old spec to represent a later change; create a new spec that links to the superseded or related one.
- The project context describes the current accepted state. Keep it concise and link to detailed specs/ADRs instead of copying them wholesale.
- If implementation reveals that a spec is obsolete or incorrect, update its status and rationale rather than deleting the record.
- Keep indexes current so Claude can discover active work and history without relying on chat memory.

## Backlog rules

- `docs/BACKLOG.md` is the canonical prioritized inventory of candidate work. Keep entries concise: the backlog is not a substitute for a specification.
- Add ideas and larger work areas as `Proposed`. Move an item to `Ready` when it is prioritized enough to be selected. Create a detailed spec only when work is selected; do not pre-specify the entire game.
- Each item has a stable ID, title, player/development outcome, priority, status, dependencies, and a link to its specification when one exists.
- Keep dependencies visible and do not mark dependent work `Ready` until its prerequisite is resolved or explicitly waived.
- Reorder the backlog when priorities change. Preserve cancelled items as `Dropped` with a short reason rather than silently deleting useful history.
- A backlog status communicates planning state; the linked specification remains the source of detailed scope and acceptance criteria.

## Decision records

Create an ADR for decisions with long-lived architectural impact, such as engine or language changes, save data compatibility, content representation, major system boundaries, or platform support. Each ADR records context, decision, alternatives considered, consequences, and status. An accepted ADR remains part of the history; a later change creates a new ADR that supersedes it.

## Documentation quality

- Write project documentation in clear English.
- Use stable terminology and define domain terms when first introduced.
- Separate facts, decisions, proposals, and open questions.
- Prefer testable behavior descriptions over implementation prescriptions unless implementation constraints matter.
- Keep examples small and consistent with the current codebase.
