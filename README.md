# FIN Group Reporting AX Project

This repository contains an exported Microsoft Dynamics AX / Axapta v3.0 project for group financial consolidation and reporting.

The canonical AX export is `SharedProject_FIN_GroupReporting.xpo`. For review and maintenance, the export is split into object-level XPO files under `src/` by `tools/extract-xpo.ps1`.

## What This Application Appears To Do

The project supports group-level financial reporting across multiple entities. It stores group entities, reporting periods, data sources, dataset definitions, field mappings, ledger accounts, ledger data, adjustments, inventory data, exchange rates, row sets, Excel templates, and user/entity access.

The main operational flow is:

1. Maintain setup data such as entities, reporting periods, scenarios, categories, users, row sets, exchange rates, and data sources.
2. Configure datasets and field mappings per entity/data source.
3. Import ledger accounts, mappings, ledger data, ledger adjustments, and inventory data from configured SQL data sources.
4. Store imported results in group reporting tables.
5. Lock entity periods by user/admin to prevent changes to reported data.
6. Use mapping, row set, Excel template, and ledger views to support consolidated reporting.

## Source Layout

- `SharedProject_FIN_GroupReporting.xpo` - preserved raw AX export.
- `src/` - extracted object-level XPO files for review and editing assistance.
- `tools/extract-xpo.ps1` - repeatable extraction script.
- `docs/project-knowledge.md` - consolidated living knowledge base.
- `ax-xpo-agent-handoff-prompt.md` - original workflow instructions for future agents.

## Refreshing Extracted Source

Run this from the repository root whenever a new XPO export is copied in:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\extract-xpo.ps1
```

The script currently extracts classes, tables, forms, enums, EDTs, menu items, the top-level menu, and the project object.

## Where To Start

Start with `docs/project-knowledge.md`, then inspect the relevant object files in `src/`. The most central objects are:

- `FIN_GroupEntities`
- `FIN_GroupPeriod`
- `FIN_GroupEntityPeriod`
- `FIN_GroupEntityDataSet`
- `FIN_GroupEntityDataSetMap`
- `FIN_GroupDataSource`
- `FIN_GroupLedgerTable`
- `FIN_GroupLedgerData`
- `FIN_GroupLedgerAdjustmentData`
- `FIN_GroupInventoryData`
- `FIN_DataConnection`
- `FIN_RunBatch_DataImport`
