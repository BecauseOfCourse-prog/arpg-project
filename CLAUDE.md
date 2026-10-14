# Claude Project Instructions

## Required context

Before planning or changing this project, read these files in order:

1. `docs/PROJECT_CONTEXT.md` — the current product and technical baseline.
2. `docs/DEVELOPMENT_WORKFLOW.md` — the required specification-driven workflow.
3. `docs/BACKLOG.md` — the prioritized work inventory and dependencies.
4. `docs/ARCHITECTURE.md`, when the task affects system boundaries or data ownership. Treat its draft proposals as non-binding.
5. The relevant active specification in `docs/specs/`, if one exists.
6. Relevant decisions in `docs/decisions/` when they affect the task.

If a required file is missing, create it or report the gap before making a change that depends on it. Do not assume that a previous conversation is the source of truth; the repository documentation is.

## Working rules

- Treat `docs/PROJECT_CONTEXT.md` and accepted Architecture Decision Records (ADRs) as the canonical current context.
- For every non-trivial feature or behavior change, create or update a change specification before implementation. Keep it with the project as the change's delta documentation.
- Keep specifications, implementation, and acceptance criteria aligned. Update the specification and shared context in the same change when implementation reveals a lasting project-level decision.
- Do not silently change an accepted decision. Record a superseding ADR and update the project context when a decision changes.
- Keep project documentation in English. Communicate with the user in their preferred language.
- Do not invent undecided game rules. Mark them `Open` in the specification and identify the decision needed.
- Keep changes scoped to the requested work. Summarize documentation and code changes and state what was not verified.

## Starting a task

After reading the required context, summarize the applicable constraints briefly in the plan or response. If the request is too small to need a new specification (for example, a typo or isolated documentation correction), make the change directly and keep the relevant documentation accurate.
