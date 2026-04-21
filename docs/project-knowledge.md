# Project Knowledge Base

This is the compact living knowledge base for the FIN Group Reporting AX / Axapta v3.0 project. Keep new findings here unless a topic grows large enough to justify its own document.

## Extraction Snapshot

Generated from `SharedProject_FIN_GroupReporting.xpo` using `tools/extract-xpo.ps1`.

| Object type | Count |
| --- | ---: |
| Classes | 8 |
| Tables | 33 |
| Forms | 18 |
| Enums | 5 |
| EDTs / user types | 15 |
| Menu items | 7 |
| Menus | 1 |
| Projects | 1 |
| Reports | 0 |
| Jobs | 0 |

The extractor was adjusted during the first pass so it defaults to this project's XPO name, extracts `ENUMTYPE` objects using `ENDENUMTYPE`, extracts `USERTYPE` EDTs, extracts the top-level menu, and avoids accidentally treating indented field properties such as `Table #...` as table objects.

## Business Concepts

- Entity: a group reporting entity in `FIN_GroupEntities`. Real company entities keep their native chart of accounts; structure/reporting entities can be marked with `IsStructure`. Entities have an entity code/name, currency, country, parent entity (`ParentEntityCode` in the export), ownership percentage, exchange adjustment account, retained earnings account, and refresh flags.
- Period: a group reporting period in `FIN_GroupPeriod`, with start/end dates, AX `LedgerPeriodStatus`, commentary, and active flag.
- Entity period: per-entity period status and locking record in `FIN_GroupEntityPeriod`. It records period status, user/admin lock flags and timestamps, notes, active flag, and whether data/adjustments/forex exist.
- Dataset: import category represented by enum `FIN_DataSet`: `LedgerAccounts`, `LedgerMappings`, `LedgerData`, `LedgerAdjustments`, and `InventoryData`.
- Data source: external source setup in `FIN_GroupDataSource`, with server/database/user metadata and password lookup through `FIN_GroupDataSourcePassword`.
- Dataset mapping: `FIN_GroupEntityDataSetMap` maps fields returned by a query into the target AX table fields for a specific entity/data source/dataset.
- Ledger account: group chart/account setup in `FIN_GroupLedgerTable`.
- Ledger facts: imported or derived transaction/balance data in `FIN_GroupLedgerData`. Rows carry scenario, category/book, period/date, entity, account, currency, amount, and dimensions.
- Adjustments: manual/imported consolidation adjustment data in `FIN_GroupLedgerAdjustmentData`; these become `ADJ` scenario entries.
- Inventory facts: operational inventory reporting data in `FIN_GroupInventoryData`, with a similar entity/period/category/dimension model plus product/inventory detail fields.
- Row set: reporting row definitions and account-to-row mappings in `FIN_GroupRowSet`, `FIN_GroupRowLine`, `FIN_GroupRowLink`, and `FIN_GroupRowMapping`.
- Excel templates: Excel report templates stored as blob data in `FIN_GroupExcelTemplates`, used by the Group Reporting Excel Add-in. `FIN_GroupExcelReport` and `FIN_GroupExcelReportMapping` hold report/mapping metadata.
- User access: user setup and entity assignment in `FIN_GroupUsers`, `FIN_GroupUserEntity`, `FIN_GroupUserPositions`, and user action audit log `FIN_GroupUserLog`.

## Main Process Flow

1. Setup forms maintain entities, periods, scenarios, categories, exchange rates, users, row sets, and data-source definitions.
2. Entity datasets define which query to run for each entity and dataset.
3. Dataset field maps define how query columns/defaults populate the AX target table.
4. Users run imports from `FIN_DataImport` or batch class `FIN_RunBatch_DataImport`.
5. `FIN_GroupEntityDataSet::loadData_bulk` finds the active dataset setup, optionally deletes existing data for the selected entity/dataset/date range, opens an external SQL connection, executes the configured query, maps each returned row into the dataset target table, inserts the records, logs the import, and reports elapsed time/record count.
6. Locks in `FIN_GroupEntityPeriod` and data tables prevent changing reported/closed data.

## Ledger Structures, Mappings, And Row Sets

Each real company keeps its native GL structure in `FIN_GroupLedgerTable`. The design does not require local companies to adopt a group chart of accounts.

Ledger mappings in `FIN_GroupLedgerMapping` are account-to-account only:

- `FromEntityCode` / `FromAcountNum` maps to `ToEntityCode` / `ToAcountNum`.
- The target can be any other entity, although it is commonly a structure/reporting entity such as the group account structure.
- Dimension-level splitting is not part of ledger mapping.

Row sets handle the more flexible reporting layout requirement:

- `FIN_GroupRowSet` defines a reporting row set.
- `FIN_GroupRowLine` defines the report lines.
- `FIN_GroupRowMapping` maps entity accounts to row lines and can use `CostCenter`, `Department`, and `Purpose` mapping rules.
- This allows the same company account to appear on different reporting lines based on dimensions, without creating many reporting-structure entities.

## Scenarios, Categories, And Currency Translation

`FIN_GroupLedgerData.ScenarioCode` identifies the accounting nature of a row:

- `OBA`: opening balance.
- `ACT`: actual entries/activity.
- `CLS`: closing balance.
- `ADJ`: consolidation adjustment entries added by group accountants.

`FIN_GroupLedgerData.Category` represents a set of books or entry set:

- `MAIN`: imported entries from the local accounting/ERP package.
- Budget or alternate books can use categories such as `BUD1`.
- Currency translation creates a separate translated category/book rather than replacing local-currency `MAIN` rows. The code currently creates translation categories using the `FX_` prefix plus the target currency in `FIN_GroupEntities.doExchAdjustments` / `doTranslationAdj`.

When reporting or extracting data, the selected category determines which set of entries is used.

## Navigation

The top-level menu is `GroupFinancials` with label `Group Financials`.

Main entries:

- Ledgers -> `FIN_GroupLedgers`
- Ledger Data -> `FIN_GroupLedgerData`
- Ledger Adjustments -> `FIN_EntityAdjustments`
- Row Sets -> `FIN_RowsSets`
- Entities -> `FIN_GroupEntities`
- Entity Periods -> `FIN_EntityPeriod`
- Users -> `FIN_GroupUsers`
- Periodic / Data Import -> `FIN_LedgerDataImport`
- Periodic / Excel Templates -> `FIN_GroupExcelTemplates`
- Setup / General -> `FIN_General`

## Key Classes

- `FIN_DataConnection`: opens SQL data connections through ADO wrapper classes, replaces `<STARTDATE>` and `<ENDDATE>` tokens in configured SQL for ledger/adjustment/inventory datasets, runs the query, builds query field maps, and maps recordset fields/defaults into AX target records.
- `FIN_CCADOConnection`, `FIN_CCADOCommand`, `FIN_CCADORecordSet`, `FIN_CCADOFields`, `FIN_CCADOField`: COM/ADO wrappers around external SQL connectivity.
- `FIN_RunBatch_DataImport`: RunBaseBatch import entry point. It asks for entity and days-prior, calculates a start date based on the latest locked date and group period start, then calls `FIN_GroupEntityDataSet::loadData_bulk` for `LedgerData`.
- `FIN_FormTreeDatasource`: helper for tree controls and selected-node maps used by entity/user/data import forms.

## Key Tables

- `FIN_GroupEntities`: entity master and consolidation hierarchy information. Its methods create opening/closing balances and exchange/translation adjustments.
- `FIN_GroupPeriod`: group period master. Insert/update creates and updates related entity-period records.
- `FIN_GroupEntityPeriod`: per-entity period state. Provides lock/unlock by user/admin, status update, and bulk create/update methods from entity or period setup.
- `FIN_GroupEntityDataSet`: dataset/query setup and main import engine. Also resolves dataset target tables, builds maps, deletes existing data, tracks latest locked date, and updates executed timestamps.
- `FIN_GroupEntityDataSetMap`: maps query fields/defaults to target fields. `initValue` and `find` support setup.
- `FIN_GroupEntityHistory`: tracks time-bound changes to entity attributes, such as base currency changes. During extraction/reporting, rows that fall inside a history period can be marked with a different entity code so one legal entity can be distinguished across historical reporting bases, for example `CompA` and `CompA_ZAR`.
- `FIN_GroupDataSource`: external source metadata and helpers for copy, lookup, password access, and ADO test execution.
- `FIN_GroupDataSourcePassword`: stores password per AOS/entity/data source.
- `FIN_GroupLedgerTable`: group ledger account setup, lookup, import helpers, and balance/movement calculations.
- `FIN_GroupLedgerData`: ledger fact table. Builds account dimension key, auto-creates missing accounts on insert, and validates locked/closed records.
- `FIN_GroupLedgerAdjustmentData`: adjustment import/staging table with validation, import, conversion, and delete-in-period logic.
- `FIN_GroupLedgerImportData`: legacy ledger import staging table with conversion logic. Current imports go directly into `FIN_GroupLedgerData`.
- `FIN_GroupInventoryData`: inventory fact table with import/delete/lock validation similar to ledger data.
- `FIN_GroupLedgerMapping` and `FIN_GroupLedgerMapHistory`: map account numbers across entities and preserve mapping history.
- `FIN_GroupRowSet`, `FIN_GroupRowLine`, `FIN_GroupRowLink`, `FIN_GroupRowMapping`: reporting row structure and row/account mapping.
- `FIN_GroupExchangeRates` and `FIN_GroupExchLedgerAccRates`: period exchange rates, including account-specific exchange adjustment rates.
- `FIN_GroupEntityLog`: entity/data import/delete/lock/activity audit log with typed events from `FIN_LogEntryType`.
- `FIN_GroupUserLog`: user action audit log. It also receives actions from external systems, which are outside the current XPO context and need separate documentation later.

## Key Forms

- `FIN_GroupEntities`: central entity setup. Includes data sources, dataset mappings, entity periods, users, history/logs, tree interaction, password setting, and query execution/test actions.
- `FIN_DataImport`: tree-based selection of entities and dataset/date import execution.
- `FIN_GroupLedgers`: ledger account, mapping, mapping history, ledger data, and inventory data view filtered by selected entity.
- `FIN_GroupLedgerData`: ledger data review with balance/mapped data actions and account summary temp table.
- `FIN_EntityPeriod`: period status and lock/unlock workflow for entities.
- `FIN_EntityAdjustments`: adjustment entry/import form with entity and period filtering and balance checks.
- `FIN_LedgerMappings`: account mapping UI with tree/drag/drop behavior and apply mapping logic.
- `FIN_RowsSets`: row set, row line, row link, and row mapping setup.
- `FIN_GroupGeneral`: general setup for categories, scenarios, periods, exchange rates, and user positions.
- `FIN_GroupUsers`, `FIN_UserMap`: user master and user-to-entity assignment.
- `FIN_GroupExcelTemplates`: Excel template blob storage/maintenance for the Group Reporting Excel Add-in.

## Enums And Types

Custom enums:

- `FIN_DataSet`: `LedgerAccounts`, `LedgerMappings`, `LedgerData`, `LedgerAdjustments`, `InventoryData`.
- `FIN_DataSourceType`: `SQL`, `Excel`.
- `FIN_ExchAdjType`: `RateTable`, `Historic`.
- `FIN_RowMapping`: `Specific`, `Any`.
- `FIN_LogEntryType`: entity, ledger, inventory, accounts, adjustment, mapping, and forex log event types.

Custom EDTs include entity code/name, account number, data source, period start/end, row set/line identifiers, scenario, category, schedule template name, position, and user name.

## Status And Locking

- Period status uses standard AX `LedgerPeriodStatus` on `FIN_GroupPeriod.PeriodStatus` and `FIN_GroupEntityPeriod.PeriodStatus`.
- `FIN_GroupPeriod.insert` and `update` propagate entity-period records through `FIN_GroupEntityPeriod`.
- `FIN_GroupEntityPeriod` is the month-end progress tracking table for each entity and period. It stores `LockedByUser`, `LockedByAdmin`, lock timestamps, user/admin notes, period status, active flag, and status indicators such as `HasData`, `HasAdjustments`, and `HasForex`.
- User locking means the local company manager/director has reviewed the month-end numbers and indicates the company is done changing that period.
- Admin locking means group accountants have reviewed the entity period and lock it from the group side.
- `FIN_GroupEntityPeriod.lockByAdmin` and `lockByUser` set lock flags on matching `FIN_GroupLedgerData` rows for the entity/period where `Category == 'MAIN'`, then mark the entity-period record.
- Unlock methods reverse the matching lock flags.
- `FIN_GroupLedgerData.validateDelete` prevents delete when `PeriodClosed`, `LockedByAdmin`, or `LockedByUser` is already set.
- `FIN_GroupLedgerData.validateWrite` prevents edits when `PeriodClosed` is already set and fills `PeriodStart` from `TransDate` if needed.
- `FIN_GroupEntityDataSet.deleteData` blocks deletion/import replacement when relevant periods or records are locked.
- `FIN_GroupEntityPeriod.updateEntityStatus` sets `HasData` by checking `ACT` data and `HasAdjustments` by checking `ADJ` data for the entity/period.
- `FIN_GroupInventoryData` also carries period/category/scenario/dimension and lock fields, but the entity-period lock methods currently update `FIN_GroupLedgerData` in the inspected code.

Month-end usage model:

1. Ledger data imports continue periodically from company systems.
2. The local company reviews its month-end figures using the local/company or group reporting layout.
3. The local user locks the entity period, marking the period and matching data rows as user locked.
4. Group accountants review the now-stable numbers, add `ADJ` consolidation entries where needed, perform currency translation, and can then admin-lock the period.
5. Progress can be monitored across entities for an open period by checking which entity periods are open, user locked, admin locked, and whether data/adjustments/forex are present.

## Confirmed Observations

- Imports are driven by SQL text stored in `FIN_GroupEntityDataSet.SQLQuery`.
- `FIN_DataConnection.openConnection` rejects SQL containing `drop` or `delete` by string scan, then opens a SQL Native Client 11 connection.
- Query date tokens are literal `<STARTDATE>` and `<ENDDATE>`.
- `FIN_GroupEntityDataSet::loadData_bulk` uses a single transaction around the record insert loop.
- Batch data import only imports `FIN_DataSet::LedgerData`.
- Current ledger data import writes directly to `FIN_GroupLedgerData`; `FIN_GroupLedgerImportData` is legacy staging and should not be treated as the active import path.
- The batch start date is max of the suggested period start and one day after `latest_LockedDate`.
- Several hard-coded scenario/category values appear in business rules: `ACT`, `ADJ`, `OBA`, `CLS`, and `MAIN`.
- `FIN_GroupLedgerData.insert` creates missing ledger accounts with name `NEW FROM IMPORT!! PLEASE UPDATE!`.
- No AX reports or jobs were present in this export.
- This folder is not currently initialized as a git repository, so no git diff/status workflow is available yet.

## Improvement Opportunities

- Review `FIN_DataConnection.openConnection`: the error text for detecting `delete` says `DROP not allowed in query!`, which is misleading.
- Review SQL safety: string scanning for `drop` and `delete` is a weak guard and may also block valid text/comments while missing other harmful statements.
- Review lock helpers in `FIN_GroupLedgerData.lockData_Admin` and `lockData_User`: the loops set flags on selected buffers but the shown code does not call `update()` inside the loop.
- Review `FIN_GroupPeriod.validateUpdate`: the second select appears to compare `prevPer.PeriodStart > this.orig().PeriodStart` while selecting `nxtPer`; this may be a typo.
- Review spelling/naming inconsistencies such as `Descriptoin`, `FromAcountNum`, `ToAcountNum`, `descruct`, and several `DEL_` methods before expanding the model.
- Consider whether password storage in `FIN_GroupDataSourcePassword` is sufficient for the deployment security expectations.
