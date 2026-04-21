# AX XPO Project Agent Handoff Prompt

Use this prompt when starting a new Codex project that contains a Microsoft Dynamics AX / Axapta `.xpo` export.

The goal is to help the agent quickly understand the AX project, extract the XPO into readable object-level files, and maintain a useful markdown knowledge base.

## Prompt To Give The New Agent

You are helping maintain a Microsoft Dynamics AX / Axapta project exported as an `.xpo` file.

The project source is currently represented by a raw XPO export. Your first goal is to make the project easier to inspect, understand, review, and modify by extracting the XPO into an object-level folder structure and building a concise markdown knowledge base.

Do not treat the raw XPO as the only working file. Keep it as the canonical export artifact, but create a readable `src` tree from it.

## Expected Repository Layout

Use this general layout:

```text
/
  ProjectExport.xpo
  README.md
  docs/
    xpo-analysis.md
    project-structure.md
    table-dictionary.md
    classes.md
    forms.md
    enums-and-types.md
    menuitems.md
    reports.md
    jobs.md
    status-lifecycle.md        optional, only if statuses/workflows exist
    process-flows.md           optional, only if meaningful business flows exist
    code-observations.md
    improvement-opportunities.md
  src/
    classes/
    tables/
    forms/
    enums/
    types/
    menuitems/
    reports/
    jobs/
    projects/
  tools/
    extract-xpo.ps1
```

Adjust the file names if the project is small, but keep the idea:

- `src` contains extracted AX objects
- `docs` contains the living knowledge base
- the root `.xpo` remains the preserved export artifact

## Using The XPO Extraction Tool

The repo should contain a PowerShell script similar to:

```text
tools/extract-xpo.ps1
```

Run it from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\extract-xpo.ps1
```

If the XPO file has a custom name or location, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\extract-xpo.ps1 -XpoPath .\MyProject.xpo -OutputRoot .\src
```

The extraction script should split the monolithic XPO into files such as:

```text
src/classes/MyClass.xpo
src/tables/MyTable.xpo
src/forms/MyForm.xpo
src/enums/MyEnum.xpo
src/types/MyEDT.xpo
src/menuitems/MyMenuItem.xpo
src/reports/MyReport.xpo
src/jobs/MyJob.xpo
src/projects/MyProject.xpo
```

After extraction, inspect the diff and verify that the object files match the latest XPO export.

## First Analysis Pass

After extraction, read the object inventory and create a first knowledge base.

Start with:

1. `README.md`
2. `docs/xpo-analysis.md`
3. `docs/project-structure.md`

The README should explain:

- what the AX project appears to do
- the main business purpose
- the key AX objects
- how the XPO is extracted
- where future agents should look first

The XPO analysis should include:

- count of extracted objects by type
- notable tables
- notable forms
- notable classes
- notable enums / EDTs
- notable reports and jobs
- any odd or malformed export sections

The project structure doc should explain:

- source folder layout
- raw XPO role
- extracted source role
- docs role
- any repeatable extraction steps

## Object-Type Documentation

Create separate markdown summaries by object type when useful:

- `docs/table-dictionary.md`
- `docs/classes.md`
- `docs/forms.md`
- `docs/enums-and-types.md`
- `docs/menuitems.md`
- `docs/reports.md`
- `docs/jobs.md`

Keep these documents practical. They should help the next agent understand the project without rereading the full XPO.

## Table Dictionary Guidance

For each custom table, document:

- table purpose
- key fields
- field type / EDT / enum where visible
- how fields appear to be populated
- important validations
- relations or indexes
- lifecycle notes if the table stores status or process state

If the project has many standard AX tables in the export, focus first on custom tables.

## Class Documentation Guidance

For each custom class, document:

- purpose
- main methods
- tables/forms/reports it interacts with
- whether it is a menu action, service/helper, batch class, or business logic class
- important side effects such as creating records, updating statuses, generating files, or printing reports

## Form Documentation Guidance

For each custom form, document:

- primary table/datasource
- important controls and buttons
- which menu items/classes buttons call
- which fields are editable and when
- any special display logic such as colors, warnings, enabled/disabled buttons

## Status And Process Documentation

If the project uses statuses, create:

```text
docs/status-lifecycle.md
```

Document:

- enum values
- meaning of each status
- methods that move records into each status
- valid transitions
- delete/cancel/retry rules if present

If the project has a clear business process, create:

```text
docs/process-flows.md
```

Document:

- main user flow
- setup flow
- approval or posting flow
- error/retry flow
- expected operator steps

## Code Observations And Improvements

Create:

```text
docs/code-observations.md
docs/improvement-opportunities.md
```

Use `code-observations.md` for factual findings:

- unusual code paths
- important assumptions
- hard-coded values
- validation rules
- places where behavior is inferred

Use `improvement-opportunities.md` for possible future work:

- bugs found during review
- UX improvements
- missing validations
- cleanup opportunities
- documentation gaps

Do not mix confirmed behavior with guesses. Clearly mark inferences.

## Git Workflow

Use small commits.

Recommended commit pattern:

1. baseline raw XPO and extraction
2. initial knowledge base
3. each focused code/doc change
4. each refreshed XPO re-export

Before making changes, check:

```powershell
git status --short
```

When a new XPO export is copied into the repo:

1. rerun `tools/extract-xpo.ps1`
2. review changed extracted files
3. update docs if behavior changed
4. commit the refreshed XPO and extracted source together

## Working Rules For Future Agents

Follow these rules:

- never rely only on memory of the XPO
- extract the XPO into `src` before doing detailed review
- keep the raw XPO and extracted source synchronized
- use markdown docs as the living knowledge base
- avoid creating too many documents; prefer a small set of durable docs
- update docs when behavior changes
- use git diffs to help the human manually port AX changes back if needed
- clearly separate confirmed code behavior from assumptions

## Minimal First Tasks For A New AX XPO Project

If starting from scratch, do this:

1. Confirm the root `.xpo` file name.
2. Run `tools/extract-xpo.ps1`.
3. Create or update `README.md`.
4. Create `docs/xpo-analysis.md`.
5. Create `docs/project-structure.md`.
6. Create object docs for tables, forms, classes, enums, menu items, reports, and jobs as applicable.
7. Identify the main user/process flow.
8. Document statuses and lifecycle rules if the project uses statuses.
9. Commit the baseline.

## What Not To Do

Do not:

- edit the raw XPO manually unless explicitly required
- lose the original export
- create many overlapping docs that say the same thing
- assume the extracted source is current after a new XPO is copied in
- ignore generated object files when reviewing behavior
- overwrite user changes without checking git status

## Expected Outcome

After the first pass, the new repo should allow a future agent to quickly answer:

- what does this AX project do?
- which objects are involved?
- where is the important code?
- which tables store the important data?
- which forms users interact with?
- what are the main process/status transitions?
- what changed between XPO exports?

That is the standard to aim for before making deeper code suggestions.
