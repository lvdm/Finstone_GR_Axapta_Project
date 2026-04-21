# Roadmap And TODO

This is the shared working list for improvements, unfinished work, and future build goals. Keep it practical: add concrete tasks here, update status as work is done, and move deep explanations into `docs/project-knowledge.md` or `docs/external-systems-context.md` only when needed.

## Status Legend

- Todo: not started.
- In progress: actively being worked on.
- Blocked: waiting on a decision, access, or external dependency.
- Done: completed and committed.

## AX / XPO Application

| Status | Item | Notes |
| --- | --- | --- |
| Todo | Review entity period lock behavior | Confirm whether lock/unlock should update only `FIN_GroupLedgerData` or also `FIN_GroupInventoryData` and adjustment rows. |
| Todo | Review `FIN_GroupLedgerData.lockData_Admin` and `lockData_User` | Current extracted code appears to set lock flags inside loops without calling `update()` on each selected record. |
| Todo | Review period validation logic | `FIN_GroupPeriod.validateUpdate` may contain a typo in the next-period lookup. |
| Todo | Confirm legacy objects | Mark or clean up legacy `DEL_*` methods and `FIN_GroupLedgerImportData` once safe. |
| Todo | Document currency translation details | Expand the exact `doExchAdjustments` / `doTranslationAdj` rules after a code walkthrough. |
| Todo | Document consolidation roll-up logic | Clarify how `ParentEntityCode`, `PercOwned`, row sets, and SQL views combine for reporting. |

## SQL Reporting Layer

| Status | Item | Notes |
| --- | --- | --- |
| Todo | Source-control SQL objects in this repo or link their repo | The context references v1 `BI_*` and v2 `GR_*` SQL views/functions, but the actual SQL files are not in this AX repo yet. |
| Todo | Review hardcoded `_002` group structure usage | `GR_BASE_GL_Data_Mapped` currently hardcodes `_002`; replace with dynamic structure support before multiple group structures are used. |
| Todo | Verify SQL Server 2008 compatibility | Any new SQL must avoid unsupported syntax such as `CREATE OR ALTER`, `IIF`, and newer aggregation helpers. |
| Todo | Document row-level security chain | Summarize `GR_SEC_DomainUser_Entity` and the service-account bypass in the project knowledge base after SQL files are available. |

## Backend API

| Status | Item | Notes |
| --- | --- | --- |
| Todo | Move secrets and connection strings out of source | Context mentions hardcoded client secret, AAD config, and DB connection strings. |
| Todo | Review API-side user filtering | Backend service account can see all SQL data; confirm every endpoint filters by JWT/user context where needed. |
| Todo | Clean logging template warnings | Context mentions CA2017 placeholder mismatches in `DataController.cs`. |
| Todo | Document `/data/rowdata` and RowSet retrieval flow | Tie API behavior back to AX row set tables and SQL `GR_OUT_RowSet_Data`. |
| Todo | Plan Tier 3 modernization | Current .NET backend is treated as legacy/unchanged for this phase; future rewrite needs its own plan. |

## Excel Add-in Frontend

| Status | Item | Notes |
| --- | --- | --- |
| Todo | Finish beta readiness checklist | Capture the final user-facing workflows, supported datasets, and acceptance criteria. |
| Todo | Review auth/token lifecycle | Confirm MSAL token renewal, session storage behavior, and failure handling for beta users. |
| Todo | Review offline/error states | Context mentions disabled dataset/template buttons when `userData` is null and a connection status panel. |
| Todo | Validate Excel write behavior | Test header mismatch handling, selected columns, table creation/update, and large result performance. |
| Todo | Document Excel template flow | Connect `FIN_GroupExcelTemplates` to add-in template browse/load/create behavior. |

## Documentation

| Status | Item | Notes |
| --- | --- | --- |
| Done | Baseline AX XPO extraction and knowledge base | `src/`, `README.md`, and `docs/project-knowledge.md` are created and committed. |
| Done | External frontend/backend context added | `docs/external-systems-context.md` added and linked from the knowledge base. |
| Todo | Clean formatting in external context file | The pasted file contains escaped Markdown markers such as `\#` and `\---`; clean only when safe to normalize source content. |
| Todo | Add workflow diagrams | Consider one concise Mermaid diagram for AX import flow and one for Excel Add-in architecture. |
| Todo | Keep this roadmap current | Update status and add decisions as the implementation direction becomes clearer. |
