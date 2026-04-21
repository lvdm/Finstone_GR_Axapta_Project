\--- FRONTEND CONTEXT START ---

\# AI Project Context — Finstone Group Reporting Excel Add-in



> \*\*Purpose of this document\*\*: This document is intended for AI agents (GitHub Copilot, etc.) to understand the full context of this project — its architecture, current state, goals, conventions, and known issues — so they can provide accurate and relevant assistance without needing repeated explanations.



\---



\## 1. Project Overview



\*\*Name\*\*: Finstone Group Reporting Excel Add-in  

\*\*Version\*\*: 2.0 (major rewrite)  

\*\*Status\*\*: Late-stage development — preparing for \*\*beta release\*\* to a select group of internal users  

\*\*Developer/Owner\*\*: Lean Van der Merwe (lvdm@finstone.net)



\### What It Does

A Microsoft Office Excel Task Pane Add-in that allows Finstone Group finance staff to:

\- Authenticate securely via their Azure AD (Microsoft 365) credentials

\- Browse and manage \*\*datasets\*\* — named configurations that define what financial data to pull (entity, category, year, month)

\- Load financial data (GL data, Inventory data) directly from the Finstone backend into Excel worksheets/tables

\- Manage \*\*Excel templates\*\* — standardised workbook layouts shared across users

\- Track data load performance metrics (server response time, network latency, Excel write time)



\### Business Context

Finstone is a multi-entity international group. Finance users need to pull GL and other financial data for specific entities and periods into Excel for reporting and analysis. The add-in replaces manual data exports and provides a structured, audited, authenticated data retrieval process.



\---



\## 2. Repository Structure



```

Finstone\_GR\_Excel-Addin/

├── frontend/                   # Excel Task Pane (Vue 3 + TypeScript)

│   ├── src/

│   │   ├── taskpane/           # Main application code

│   │   │   ├── components/     # Vue SFC components

│   │   │   ├── excel/          # Office.js Excel service

│   │   │   ├── bootstrap/      # Global state (appGlobal.ts)

│   │   │   ├── config.ts       # Azure AD + API config (current)

│   │   │   ├── config.ts.new   # Cleaner config (WIP replacement)

│   │   │   ├── AuthManagerv1.ts

│   │   │   ├── apiService.ts

│   │   │   ├── connectionChecker.ts  # Reactive 3-layer health check service

│   │   │   ├── themeManager.ts       # Runtime colour + layout theme switcher

│   │   │   ├── mainApp.ts

│   │   │   ├── types.ts

│   │   │   └── utils.ts

│   │   │   └── themes/               # CSS variable theme files

│   │   │       ├── layout-default.css

│   │   │       ├── layout-compact.css

│   │   │       ├── layout-windowed.css

│   │   │       ├── theme-office-blue.css

│   │   │       ├── theme-slate.css

│   │   │       ├── theme-midnight.css

│   │   │       ├── theme-green.css

│   │   │       ├── theme-purple.css

│   │   │       └── theme-high-contrast.css

│   │   ├── commands/           # Office ribbon commands

│   │   └── functions/          # Office custom functions

│   ├── manifest.xml            # Office Add-in manifest

│   ├── webpack.config.js

│   └── package.json

│

└── server/                     # Middleware API (Express + Node.js)

&#x20;   ├── src/

&#x20;   │   ├── server.ts

&#x20;   │   ├── config/

&#x20;   │   │   ├── azure.ts            # Server-side Azure AD config

&#x20;   │   │   ├── finstoneAPIConfig.ts # Remote API config + credentials

&#x20;   │   │   └── tokenUtils.ts

&#x20;   │   ├── controllers/

&#x20;   │   │   ├── usersController.ts

&#x20;   │   │   └── dataController.ts

&#x20;   │   ├── middleware/

&#x20;   │   │   └── auth.ts             # JWT validation middleware

&#x20;   │   ├── routes/

&#x20;   │   │   ├── userRoutes.ts

&#x20;   │   │   ├── dataRoutes.ts

&#x20;   │   │   └── statusRoutes.ts     # Health check proxy (Node → C# /health)

&#x20;   │   └── services/

&#x20;   │       ├── remoteAPIService.ts # Calls Finstone backend API

&#x20;   │       └── tokenService.ts     # OBO token acquisition + caching

&#x20;   └── package.json

```



\---



\## 3. Three-Tier Architecture



```

┌──────────────────────────────────────────────────────┐

│  TIER 1 — Excel Task Pane (Frontend)                 │

│  Vue 3 + TypeScript + MSAL Browser                   │

│  Dev port: https://localhost:3000                     │

│  Served via webpack-dev-server (or static build)     │

└─────────────────────────┬────────────────────────────┘

&#x20;                         │ Bearer JWT (Azure AD token)

&#x20;                         │ HTTP to localhost:3015

┌─────────────────────────▼────────────────────────────┐

│  TIER 2 — Middleware API Server (Backend)            │

│  Express.js + Node.js + TypeScript                   │

│  Port: 3015                                          │

│  Validates JWT, proxies to Finstone API via OBO      │

└─────────────────────────┬────────────────────────────┘

&#x20;                         │ OBO-delegated JWT token

&#x20;                         │ HTTP to 192.168.0.20:5001

┌─────────────────────────▼────────────────────────────┐

│  TIER 3 — Finstone Backend API (Legacy v1)           │

│  .NET Windows Service on local SQL Server machine    │

│  IP: 192.168.0.20:5001                               │

│  Talks directly to SQL Server (financial database)   │

│  Developer-owned, unchanged for this project phase   │

└──────────────────────────────────────────────────────┘

```



\*\*Important\*\*: The Finstone Backend API (Tier 3) is a separate project/service. Its API contract (endpoints, request/response shapes) has not changed in this phase. A full rewrite of Tier 3 to modern technology is planned for the \*\*next phase\*\*.



\---



\## 4. Technology Stack



\### Frontend (Excel Task Pane)

| Technology | Version | Purpose |

|---|---|---|

| TypeScript | 5.4.2 | Primary language |

| Vue 3 | Latest | UI framework (SFC with Composition API) |

| MSAL Browser | 4.11 | Azure AD OAuth2 authentication |

| Office.js | Latest | Excel API (task pane, worksheets, tables) |

| Webpack 5 | Latest | Bundling |

| Babel | Latest | Transpilation |

| Office UI Fabric Core | CSS | UI styling |

| jwt-decode | Latest | Token inspection client-side |



\### Backend (Middleware Server)

| Technology | Version | Purpose |

|---|---|---|

| TypeScript | 5.4.2 | Primary language |

| Express.js | 4.18.3 | HTTP framework |

| MSAL Node | 2.1.0 | Azure AD OBO token acquisition |

| Helmet.js | Latest | HTTP security headers |

| CORS | Latest | Cross-origin policy |

| express-rate-limit | Latest | Rate limiting |

| Axios | Latest | HTTP calls to Finstone API |

| Winston | Latest | Logging |

| node-cache | Latest | Token caching |



\---



\## 5. Authentication \& Security Architecture



\### Flow Summary

1\. \*\*User opens Excel\*\*, Add-in task pane loads

2\. \*\*Login.vue\*\* shown; user clicks "Sign in with Azure AD"

3\. \*\*AuthManagerv1\*\* initialises MSAL `PublicClientApplication` and triggers popup

4\. User authenticates at Azure AD portal

5\. Two tokens acquired and cached in `sessionStorage`:

&#x20;  - \*\*Graph Token\*\* — for Microsoft Graph (`/me` user info)

&#x20;  - \*\*API Token\*\* — for the middleware server (`api://<clientId>/access\_as\_user`)

6\. \*\*ApiService\*\* attaches the API token as `Authorization: Bearer <token>` on every server request

7\. \*\*Middleware auth.ts\*\* validates the JWT (signature, expiry, issuer, audience)

8\. \*\*Server uses OBO flow\*\* — exchanges the user's token + its own client credentials for a new token scoped to the Finstone API

9\. \*\*RemoteAPIService\*\* calls `192.168.0.20:5001` with the OBO token

10\. Data flows back through the chain into \*\*ExcelService\*\* which writes it to the worksheet



\### Token Lifecycle

\- Tokens cached for their full lifetime in `sessionStorage`

\- `AuthManagerv1` monitors expiry with a 5-minute buffer (`tokenRenewalOffsetSeconds: 300`)

\- Silent refresh attempted via `acquireTokenSilent`; falls back to `acquireTokenPopup`

\- Auto-refresh loop runs every 15 minutes

\- `token-expired` event emitted to components before expiry



\### Azure AD Registration

\- \*\*Tenant ID\*\*: `a95d7616-c4ea-49d1-809d-a4d86fc1a26f`

\- \*\*Client ID\*\* (shared frontend + backend): `b5bf0440-e6b1-474a-a267-ec2c9f9cc1a7`

\- \*\*Finstone API App ID\*\* (Tier 3 scope): `938e275d-838c-441e-86f0-fddb3243bcd0`

\- \*\*Client Secret\*\*: Currently hardcoded in `finstoneAPIConfig.ts` — \*\*must be moved to environment variable before beta\*\*



\---



\## 6. Key Source Files — Responsibilities



\### Frontend



| File | Role |

|---|---|

| `taskpane/config.ts` | Azure AD config, API base URLs, scopes — current version |

| `taskpane/config.ts.new` | Cleaner refactored config — intended replacement; differs in logLevel (2 vs 3) and scope format |

| `taskpane/AuthManagerv1.ts` | Singleton MSAL manager; token acquisition, caching, refresh, events |

| `taskpane/apiService.ts` | Centralised HTTP client; injects auth headers; 401 retry logic |

| `taskpane/mainApp.ts` | Singleton orchestrator; initialises Vue after auth; manages dataset lifecycle |

| `taskpane/bootstrap/appGlobal.ts` | Exports shared singletons: `authManager`, `logger`, `mainApp`, Vue app ref |

| `taskpane/excel/excelService.ts` | Office.js wrapper; writes JSON to worksheets/tables; handles header mismatch |

| `taskpane/components/Login.vue` | Auth entry screen; loading state + login button |

| `taskpane/components/MainAppComponent.vue` | Main dashboard shell; header, menu, status bar; Data Sets + Excel Templates buttons are \*\*disabled when `userData` is null\*\* (offline); status bar shows 🔗/⚠️ connection icon |

| `taskpane/components/DataSets.vue` | Lists user's saved datasets; create/refresh actions |

| `taskpane/components/DataSetDetail.vue` | Dataset editor; parameters (entity/category/year/month), sheet/table names, column selection, perf metrics, load/save/delete |

| `taskpane/components/ExcelTemplates.vue` | Template browser; load/create templates |

| `taskpane/components/UserDataViewer.vue` | Debug: shows full user data JSON; includes Appearance section for switching theme/layout at runtime |

| `taskpane/components/LogViewer.vue` | Debug: shows runtime logs |

| `taskpane/components/ConnectionStatus.vue` | Slide-up panel showing Node → API → SQL connectivity status with latency |

| `taskpane/connectionChecker.ts` | Reactive service; exports `nodeLayer`, `apiLayer`, `sqlLayer` refs + `runCheck()` |

| `taskpane/themeManager.ts` | Applies CSS variable sets for colour themes and layout variants at runtime |

| `taskpane/themes/\*.css` | CSS variable definitions — 3 layout files + 6 colour theme files |

| `taskpane/userData.md` | Sample `UserData` JSON object for reference |



\### Backend



| File | Role |

|---|---|

| `config/azure.ts` | Server Azure AD config; CORS origins; rate limit settings |

| `config/finstoneAPIConfig.ts` | Remote API URLs, endpoints, OBO scopes, \*\*client secret (temp hardcoded)\*\* |

| `middleware/auth.ts` | JWT validation; populates `req.user` from token claims |

| `controllers/usersController.ts` | `GET /api/user` — merges token claims with Finstone user data; `PUT /api/user/preferences`; `POST /api/user/token` |

| `controllers/dataController.ts` | `GET /api/data/dynamicdata`; `POST /api/data/save`; `GET /api/data/templates`; `POST /api/data/save-template` |

| `services/remoteAPIService.ts` | Singleton; holds MSAL `ConfidentialClientApplication`; acquires OBO tokens; makes axios calls to Finstone API |

| `services/tokenService.ts` | OBO token acquisition logic; token caching with expiry |

| `routes/statusRoutes.ts` | `GET /api/status/api-sql` — calls C# `/health` via `remoteAPIService`, returns `{ success, api, sql, sqlError, timestamp }` |



\---



\## 7. Theme \& Layout System



The add-in uses a \*\*CSS custom property (variable) based\*\* theming system, applied at runtime without page reload. There are two independent axes:



\### Colour Themes

Defined as `:root { --clr-\* }` variable sets in individual CSS files and mirrored in `themeManager.ts`.



| Theme ID | File | Description |

|---|---|---|

| `office-blue` | `theme-office-blue.css` | Default — Microsoft Office brand blue |

| `slate` | `theme-slate.css` | Neutral dark header, softer feel |

| `midnight` | `theme-midnight.css` | Full dark mode |

| `green` | `theme-green.css` | Green accent |

| `purple` | `theme-purple.css` | Purple accent |

| `high-contrast` | `theme-high-contrast.css` | Accessibility high contrast |



\### Layout Variants

Defined as `:root { --panel-\*, --modal-\*, --sp-\*, --hdr-\*, ... }` variable sets.



| Layout ID | File | Description |

|---|---|---|

| `default` | `layout-default.css` | Full-width panels (recommended for narrow taskpane) |

| `compact` | `layout-compact.css` | Full-width + tighter spacing + smaller text |

| `windowed` | `layout-windowed.css` | Floating centred card style (max-width 500px) |



\### Key CSS Variables

| Variable | Purpose |

|---|---|

| `--panel-width`, `--panel-max-width` | Panel size constraints |

| `--panel-min-height` | Minimum panel height (700px across all layouts) |

| `--panel-max-height` | Maximum panel height |

| `--panel-radius`, `--panel-shadow` | Panel chrome |

| `--clr-primary`, `--clr-panel-header-bg` | Brand/accent colours |

| `--hdr-font-size`, `--hdr-padding` | Header typography |

| `--sp-xs` … `--sp-xxl` | Spacing scale |



\### Runtime Switching

`themeManager.ts` exports `setColourTheme(id)` and `setLayoutTheme(id)`. Both functions inject the chosen variable set onto `:root` as inline styles. The user switches themes via the \*\*Appearance\*\* section in `UserDataViewer.vue` (debug panel). The selection is persisted in `localStorage`.



\---



\## 8. Connectivity Health Check



A three-layer connectivity checker lets users (and developers) verify the full request chain from the browser to the database.



\### Architecture

```

Browser → Node (Tier 2) → C# WebAPI (Tier 3) → SQL Server

```



\### Frontend — `connectionChecker.ts`

Exports reactive refs and a `runCheck()` function:



| Export | Type | Description |

|---|---|---|

| `nodeLayer` | `Ref<LayerStatus>` | Node server reachability + latency |

| `apiLayer` | `Ref<LayerStatus>` | C# WebAPI reachability + latency |

| `sqlLayer` | `Ref<LayerStatus>` | SQL Server reachability via C# |

| `isChecking` | `computed` | True while any layer is being checked |

| `allOk` | `computed` | True when all three layers are `ok` |

| `hasError` | `computed` | True when any layer is `error` |

| `runCheck()` | `async fn` | Checks Node first; short-circuits API+SQL if Node fails |



`LayerStatus` shape: `{ state: 'idle'|'checking'|'ok'|'error', latencyMs?: number, error?: string }`



\### Frontend — `apiService.ts` health methods

| Method | Calls | Returns |

|---|---|---|

| `checkNodeHealth()` | `GET {serverRoot}/health` | `{ ok, latencyMs, error? }` |

| `checkApiSqlHealth()` | `GET {API\_BASE\_URL}/status/api-sql` | `{ ok, latencyMs, api, sql, apiError?, sqlError? }` |



> \*\*Important:\*\* `API\_BASE\_URL` includes the `/api` prefix (e.g. `https://host:3000/api`). `checkNodeHealth()` strips this suffix to reach the server root at `/health`. `checkApiSqlHealth()` calls `/status/api-sql` — do \*\*not\*\* add an extra `/api` prefix.



\### Node — `statusRoutes.ts`

\- Route: `GET /api/status/api-sql` (no client auth required)

\- Calls C# `GET /health` via `remoteAPIService.makeRequest()` (client credentials, 30s timeout, 3 retries)

\- Always returns HTTP 200; body: `{ success, api, sql, sqlError?, timestamp }`



\### Frontend — `ConnectionStatus.vue`

\- Slide-up panel accessed via the status bar (🔗 / ⚠️ icon)

\- Shows three rows: Node / Backend API / SQL — each with animated dot and latency

\- Auto-runs `runCheck()` when opened

\- The ⚠️ icon in the status bar turns on when `hasError` is true



\### Timeout Summary

| Leg | Timeout |

|---|---|

| Browser → Node (`checkNodeHealth`) | None (browser default) |

| Browser → Node (`checkApiSqlHealth`) | None (browser default) |

| Node → C# WebAPI | 30s per attempt, 3 retries (via `remoteAPIService`) |

| C# → SQL Server | 5 seconds (`CancellationTokenSource`) |



\---



\## 9. Finstone Backend API (Tier 3) — Endpoints



Base URL (dev): `http://192.168.0.20:5001`



| Endpoint | Method | Purpose |

|---|---|---|

| `/user` | GET | Authenticated user data including entities and periods |

| `/entities` | GET | List of entities visible to the user |

| `/data/dynamicdata` | GET | GL / financial data with query parameters |

| `/data/updateadjustmentdata` | POST | Save adjustment data |

| `/data/updatelockbyuser` | POST | Lock/unlock period by user |

| `/ExcelTemplate` | GET/POST | Excel template management |



\### UserData Shape (key fields)

```json

{

&#x20; "userId": "guid",

&#x20; "name": "string",

&#x20; "email": "string",

&#x20; "roles": \[],

&#x20; "entities": \[

&#x20;   {

&#x20;     "entityCode": "BR-DOR",

&#x20;     "entityName": "Dorking Brazil",

&#x20;     "shortCode": "DOR",

&#x20;     "countryCode": "BR",

&#x20;     "currencyCode": "BRL",

&#x20;     "parentEntityCode": "CH-CON-MQ",

&#x20;     "periods": \[

&#x20;       {

&#x20;         "entitycode": "string",

&#x20;         "active": 1,

&#x20;         "lockedbyadmin": 0,

&#x20;         "lockedbyuser": 1,

&#x20;         "periodstatus": 0,

&#x20;         "periodend": "2024-01-31T00:00:00"

&#x20;       }

&#x20;     ]

&#x20;   }

&#x20; ]

}

```



\---



\## 10. Dataset Configuration



A \*\*Dataset\*\* is a user-saved configuration that defines:

\- `name` — display name

\- `type` — data type (e.g. GL Data, Inventory Data)

\- Parameters: `entity`, `category`, `year`, `month`

\- `sheetName` — target Excel worksheet

\- `tableName` — target Excel table name

\- `columns` — selected columns to include

\- Performance metrics (stored after load): server response ms, network ms, Excel write ms



Datasets are saved as user preferences via `PUT /api/user/preferences`.



\---



\## 11. Current Development Priorities (Pre-Beta)



In order of priority:



1\. \*\*Move secrets to environment variables\*\*

&#x20;  - `server/src/config/finstoneAPIConfig.ts`: `clientSecret` is currently hardcoded with a fallback. Must be `process.env.CLIENT\_SECRET` only (no hardcoded fallback) before beta.

&#x20;  - All Azure IDs/URLs should move to `.env` files (with `.env.example` committed to repo).



2\. \*\*Review and merge `config.ts.new`\*\*

&#x20;  - `config.ts.new` is a cleaner version of `config.ts`. Key differences:

&#x20;    - `logLevel: 2` (Warning) vs current `logLevel: 3` (Verbose)

&#x20;    - API scope format: `api://<clientId>/access\_as\_user` (correct) vs current `api://localhost:3000/<clientId>/access\_as\_user` (incorrect for Azure-registered app)

&#x20;  - Decision needed: merge into `config.ts` and delete the `.new` file.



3\. \*\*Hosted deployment configuration\*\*

&#x20;  - `localhost` URLs need replacing with real hosted hostnames for external beta users

&#x20;  - Applies to: `redirectUri`, `corsOrigins`, `api.baseUrl` in both frontend and server configs

&#x20;  - The middleware server needs to be hosted somewhere accessible to beta users (currently only runs locally)



4\. \*\*Beta release testing\*\*

&#x20;  - A select group of internal Finstone finance users will participate

&#x20;  - Goal: validate data correctness, auth flow, performance, and UX



\---



\## 12. Next Phase Goals (Post-Beta)



\- \*\*Rewrite Finstone Backend API (Tier 3)\*\* to modern technologies — the API contract (endpoints/responses) will likely be updated at this point

\- \*\*Environment-specific configuration\*\* — proper dev/staging/production config separation

\- \*\*Role-based access control\*\* — `requiredClaims` blocks exist in config but are currently commented out; plan to enable roles/groups-based permissions

\- \*\*Error UX improvements\*\* — more descriptive error messages for end users

\- \*\*Exponential backoff / circuit breaker\*\* — current retry logic is linear; improve resilience for remote API calls

\- \*\*Consider HTTPS for middleware server\*\* — currently HTTP; TLS needed for production



\---



\## 13. Development Environment Setup



\### Prerequisites

\- Node.js (LTS)

\- npm

\- Office Add-in dev certificates (for `https://localhost:3000`)



\### Frontend

```bash

cd frontend

npm install

npm start          # Debug in Excel Desktop

npm run dev-server # Webpack dev server only

npm run build      # Production build

npm run build:dev  # Development build

```



\### Backend (Middleware Server)

```bash

cd server

npm install

npm run dev    # Development mode (watch)

npm run build  # Production build

npm start      # Production start

```



\### VS Code Tasks

Tasks are defined in `.vscode/tasks.json` and available via the workspace:

\- \*\*Build (Development)\*\* / \*\*Build (Production)\*\*

\- \*\*Debug: Excel Desktop\*\* — starts and sideloads the add-in

\- \*\*Dev Server\*\* — webpack dev server

\- \*\*Server: Dev Mode\*\* — backend in watch mode

\- \*\*Start All\*\* — parallel: Dev Server + Server Dev Mode



\---



\## 14. Known Issues \& Technical Debt



| Issue | Location | Severity |

|---|---|---|

| Client secret hardcoded as fallback | `finstoneAPIConfig.ts` | \*\*High\*\* — fix before beta |

| `config.ts` has wrong API scope format | `config.ts` | Medium — use `config.ts.new` format |

| localhost URLs in all configs | Various | Medium — needed before external hosting |

| Token cache key doesn't include user identity | `tokenService.ts` | Medium — potential cache collision in multi-user edge cases |

| `refreshCounter` trick for Vue reactivity | `DataSets.vue` | Low — could use `watch` + computed properly |

| No exponential backoff on remote API retries | `remoteAPIService.ts` | Low |

| Manual DOM event listeners may not clean up across modal cycles | Components | Low |



\---



\## 15. Conventions \& Patterns



\- \*\*Singleton pattern\*\* used for: `AuthManagerv1`, `MainApp`, `RemoteAPIService`

\- \*\*Event-driven auth\*\*: `AuthManagerv1` emits `authenticated`, `token-expired`, `auth-error` — components subscribe

\- \*\*`appGlobal.ts`\*\* is the shared state hub — import from here to get `authManager`, `mainApp`, `logger`

\- \*\*`ApiService.fetchWithAuth()`\*\* is the \*\*only\*\* place HTTP calls should originate from in the frontend — never fetch directly in components

\- \*\*`ExcelService`\*\* is the \*\*only\*\* place Office.js Excel APIs should be called — never call `Excel.run()` directly in components or other services

\- \*\*TypeScript strict mode\*\* is used — avoid `any` types

\- \*\*No `console.log`\*\* in production code — use the `logger` from `appGlobal.ts`



\--- FRONTEND CONTEXT END ---





\--- BACKEND CONTEXT START ---

\# AI Project Context — Finstone Group Reporting (Backend API)



This file is the authoritative reference for AI assistants and developers working on this solution.

Keep it updated as the project evolves.



\---



\## Finance Domain Model



This section describes the core business concepts that drive the data model and SQL view design. Read this before analysing or modifying any SQL object.



\### Entities



An \*\*Entity\*\* represents a group company. Each entity has:

\- A unique `ENTITYCODE` (e.g. `\_002`, `\_010`)

\- Its own \*\*LedgerTable\*\* — the chart of accounts (GL account structure) specific to that company

\- A base/reporting currency (`CURRENCYCODE`)

\- A parent entity for consolidation hierarchy (`PARENTENTITYCODE`) with a percentage ownership (`PERCOWNED`)

\- An `ISSTRUCTURE` flag: `0` = operating company, `1` = group structure entity (shared account framework)



\### Group Structure Entities (`ISSTRUCTURE = 1`)



One or more entities act as \*\*group account structures\*\* — they define the shared chart of accounts that all operating companies map their accounts into. Currently the only group structure entity is \*\*`\_002`\*\*, but the data model is designed to support multiple group structures simultaneously. All mapping tables use `TOENTITYCODE` to identify the target group structure, so SQL views must \*\*not\*\* hardcode `\_002` — they join on `TOENTITYCODE` to remain future-proof.



\### Account Mapping (`FIN\_GROUPLEDGERMAPPING` + `FIN\_GROUPLEDGERMAPHISTORY`)



Each operating entity's ledger accounts are mapped to a group structure entity's accounts via `FIN\_GROUPLEDGERMAPPING`:



```

FROMENTITYCODE  + FROMACOUNTNUM  →  TOENTITYCODE + TOACOUNTNUM

(e.g. \_010, 1000)                    (e.g. \_002, REVENUE)

```



\- `FIN\_GROUPLEDGERMAPPING` — the \*\*current / default\*\* mapping for each company account.

\- `FIN\_GROUPLEDGERMAPHISTORY` — \*\*time-bounded overrides\*\*: a mapping can change for a specific period range (e.g. account X maps to group account A for 2024, but maps to group account B from 2025 onwards).



\*\*Resolution rule (implemented in `GR\_BASE\_GL\_Data\_Mapped`):\*\*

1\. Check `FIN\_GROUPLEDGERMAPHISTORY` for a row where the GL transaction's `PERIODSTART` falls within `h.PERIODSTART .. h.PERIODEND` → use `h.TOACOUNTNUM`.

2\. If no history row matches → fall back to `FIN\_GROUPLEDGERMAPPING.TOACOUNTNUM`.

3\. If neither exists → return `'NA'`.



\### Entity History (`FIN\_GROUPENTITYHISTORY`)



Over time an entity may undergo significant changes (e.g. change of operating currency, restructure). When this happens a \*\*new entity code\*\* is not created for future transactions — instead, the historical transactions \*within the change period\* are \*\*reassigned\*\* to an alternative entity code via `FIN\_GROUPENTITYHISTORY`.



Each history row records:

\- `ENTITYCODE` — the original entity code that holds the data

\- `NEWENTITYCODE` — the code to assign to transactions falling within this period

\- `PERIODSTART` / `PERIODEND` — the date range during which this reassignment applies



\*\*Effect in reporting:\*\* When browsing the combined result set you can distinguish the "old" period of an entity (appears under `NEWENTITYCODE`) from its current transactions (appear under `ENTITYCODE`). All other mappings (account mapping, mapping history) continue to apply normally — entity history only changes which entity code is presented on the row.



This is implemented in `GR\_BASE\_Entity\_HistoryMap` (UNION of current entities and historical remaps) and applied in `GR\_BASE\_GL\_Data\_Mapped` via a correlated subquery on `GR\_BASE\_Entity\_HistoryMap`.



\### GL Amounts — Two Currency Fields



Every row in `FIN\_GROUPLEDGERDATA` carries two amounts:



| Column | Meaning |

|---|---|

| `AMOUNT` | Amount in the \*\*transaction currency\*\* (the currency of the original document) |

| `AMOUNTMST` | Amount in the \*\*entity base currency\*\* (the company's own reporting currency) |



`AMOUNTMST` is always expressed in the entity's base currency and is the primary amount used for group consolidation. `AMOUNT` retains the original foreign-currency value for reference.



\### ScenarioCode — Transaction Type



The `SCENARIOCODE` column on `FIN\_GROUPLEDGERDATA` classifies the nature of each set of entries:



| Code | Meaning |

|---|---|

| `ACT` | Actual — normal posted transactions |

| `OBA` | Opening Balance Adjustment |

| `CLS` | Closing Balance |



Consumers filter by `SCENARIOCODE` to select the relevant transaction set for their report.



\### Category — Data Version / Slice



The `CATEGORY` column on `FIN\_GROUPLEDGERDATA` is the mechanism for storing \*\*multiple parallel versions\*\* of ledger data for the same entity and period:



| Example Category | Meaning |

|---|---|

| `MAIN` | Standard company transactions in the entity base currency |

| `USD` | All transactions restated/translated to USD |

| `BUD` | Budget entries |

| \*(any user-defined value)\* | Any additional translation or planning version |



At query time the caller specifies which category they want; the views return only that slice. This is what the `Category` parameter does in API calls — it is passed through to the SQL filter.



\### Consolidation Hierarchy



Entities form a \*\*multi-level tree\*\* via `PARENTENTITYCODE`. There are two types of nodes in this tree:



| Node type | `ISSTRUCTURE` | Description |

|---|---|---|

| Operating company | `0` | A real trading entity with its own GL transactions |

| Consolidation group | `0` or `1` | A holding/intermediate entity that has no direct transactions — its numbers are the roll-up of its children |



The hierarchy can be arbitrarily deep. A typical structure looks like:



```

Group Root  (\_002 — group structure entity)

&#x20; └── Regional Holding  (\_010)

&#x20;       ├── Operating Company A  (\_011)

&#x20;       └── Operating Company B  (\_012)

&#x20; └── Operating Company C  (\_020)

```



Roll-up reporting is done by traversing this tree. The API uses `GR\_FN\_ChildEntities(@ParentEntity)` to retrieve the full subtree beneath any node, which is then used to aggregate GL data for consolidated totals.



`GR\_DIM\_Entity` exposes the flat entity list with `PARENTENTITYCODE` and `PERCOWNED` so the frontend can reconstruct the tree and drive hierarchy-aware reports. The `USERNAME` column on `GR\_DIM\_Entity` carries the user access assignment per entity (from `FIN\_GroupUserEntity`), which is how the security filter in `GR\_SEC\_DomainUser\_Entity` is populated.



\### Design Philosophy — Local Autonomy + Group Mapping



Each group company maintains its \*\*own GL structure and account numbering\*\*. Companies are not required to align their chart of accounts to the group structure. They load their data using their own account numbers and their own entity codes.



The \*\*account mapping layer\*\* (`FIN\_GROUPLEDGERMAPPING` + `FIN\_GROUPLEDGERMAPHISTORY`) is maintained centrally by the group accountant. It translates each company's accounts into the group chart of accounts. This means:



\- Companies focus on their own reporting obligations without needing to understand the group structure.

\- The group team manages the mapping rules and can change them over time (via mapping history) without requiring companies to change how they submit data.

\- Group consolidated reporting is produced entirely from the mapped data.



\### Currency Translation and the Category System



When a company's ledger data is \*\*translated to another currency\*\* (e.g. from local currency to the group reporting currency), the translated entries are loaded as a \*\*new Category\*\* rather than overwriting the originals. For example:



| Category | Content |

|---|---|

| `MAIN` | Company transactions in the entity's own base currency (`AMOUNTMST`) |

| `GBP` \*(example)\* | All entries restated in the group reporting currency via a separately loaded translation |

| `BUD` | Budget entries (same account/period structure, planning figures) |



This design means the original submission is never modified — translations and planning versions coexist alongside actuals. The caller selects the category they need at query time.



\### Period Management and Locking Workflow



Data submissions and period sign-off are tracked per entity in `FIN\_GROUPENTITYPERIOD` (surfaced through `GR\_DIM\_EntityPeriod`). The workflow has two sign-off levels:



```

1\. Entity data is loaded for a period

&#x20;      ↓

2\. Local manager reviews and marks the period as complete  (LOCKEDBYUSER / LOCKEDBYUSERON)

&#x20;      ↓

3\. Group accountant reviews and locks the period           (LOCKEDBYADMIN / LOCKEDBYADMINON)

&#x20;      ↓

&#x20;  Period is now immutable — no further data changes allowed

```



Key columns on `FIN\_GROUPENTITYPERIOD`:



| Column | Meaning |

|---|---|

| `ACTIVE` | Whether this is the currently open/active period for the entity |

| `PERIODSTATUS` | Overall status of the period (data loaded, in progress, complete, etc.) |

| `PERIODSTART` / `PERIODEND` | Date range for this reporting period |

| `LOCKEDBYUSER` | Flag set by the local manager when the period data is confirmed complete |

| `LOCKEDBYUSERON` | Timestamp of the user lock |

| `NOTESBYUSER` | Optional notes from the local manager |

| `LOCKEDBYADMIN` | Flag set by the group accountant to fully lock the period |

| `LOCKEDBYADMINON` | Timestamp of the admin lock |

| `NOTESBYADMIN` | Optional notes from the group accountant |



This register gives the group team full visibility of the period-end close status across all entities — which entities have submitted data, which managers have signed off, and which the group accountant has locked.



\### RowSets — Custom Report Structures



RowSets provide a way to define \*\*custom report layouts\*\* without creating new entities. They are independent of the entity chart-of-accounts hierarchy and allow any combination of company accounts (across dimensions) to be mapped to a named row in a bespoke report template.



\*\*Example:\*\* A RowSet called `CASHFLOW` with 20 `FIN\_GROUPROWLINE` rows drives a Simple Cash Flow report. Each row has a line number the Excel report uses as a lookup key — the user places a formula referencing line 5 and the data for that line is whatever accounts were mapped to it.



\#### Tables



| Table | Purpose |

|---|---|

| `FIN\_GROUPROWSET` | Defines a named report structure (`ROWSETCODE` + `ROWSETNAME`) |

| `FIN\_GROUPROWLINE` | The individual rows of a RowSet — each has a `ROWLINENO`, `ROWLINENAME`, and optional LEVEL0–LEVEL4 hierarchy labels for grouping/pivoting |

| `FIN\_GROUPROWMAPPING` | Maps a company account (`FROMENTITYCODE` + `FROMACOUNTNUM`) to a RowSet row (`TOROWSETCODE` + `TOROWLINENO`), with per-dimension matching rules |



All three tables use `DATAAREAID = 'fin'`.



\#### `FIN\_GROUPROWLINE` Hierarchy (LEVEL0–LEVEL4)



The five level columns mirror the same structure as the ledger chart of accounts. They are \*\*user-defined labels\*\* — there is no requirement to match ledger hierarchy values. Their primary use case is to support pivot table grouping in Excel. The key output field for report linkage is `ROWLINENO`.



\#### `FIN\_GROUPROWMAPPING` Dimension Matching



Each mapping row specifies how to match the three GL dimensions:



| `\*\_MAP\_TYPE` value | Meaning |

|---|---|

| `0` | \*\*Specific\*\* — only match rows where the GL dimension equals `\*\_MAP\_VALUE` |

| `1` | \*\*All\*\* — match any value for this dimension (dimension is ignored in the filter) |



Example mapping row: `FROMENTITYCODE = '\_010'`, `FROMACOUNTNUM = '1000'`, `TOROWSETCODE = 'CASHFLOW'`, `TOROWLINENO = 5`, `DEPARTMENT\_MAP\_TYPE = 0`, `DEPARTMENT\_MAP\_VALUE = 'SALES'`, `COSTCENTER\_MAP\_TYPE = 1`, `PURPOSE\_MAP\_TYPE = 1` → maps account 1000 of entity \_010, but \*\*only\*\* for the SALES department, to line 5 of the CASHFLOW rowset.



\#### Mapping Source — Company Account Number



`FROMACOUNTNUM` is the \*\*company's own account number\*\* (the entity's local GL account, same domain as `FROMACOUNTNUM` in `FIN\_GROUPLEDGERMAPPING`). The group entity `\_002` can also be mapped to a RowSet directly — allowing group-account-level RowSet mappings in addition to per-entity mappings.



\#### Key Design Points for SQL Views



\- When joining GL data to a RowSet mapping, match on `FROMENTITYCODE`, `FROMACOUNTNUM`, and evaluate each dimension's `\_MAP\_TYPE` / `\_MAP\_VALUE`:

&#x20; - `MAP\_TYPE = 1` (All) → no dimension filter needed for that dimension

&#x20; - `MAP\_TYPE = 0` (Specific) → `GL.dimension = MAP\_VALUE`

\- A GL row that matches multiple mapping rows should be handled intentionally (sum to same line, or flag as ambiguous — TBD when views are built).

\- The resulting output view (`GR\_OUT\_RowSet\_Data` or similar) should return `ROWSETCODE`, `ROWLINENO`, and aggregated amounts so the Excel add-in can VLOOKUP/INDEX-MATCH on line number.



\#### SQL Objects (deployed)



| Object | Type | SQL file | Purpose |

|---|---|---|---|

| `GR\_DIM\_RowSet` | View | \[SQL/Views\_v2/GR\_DIM\_RowSet.sql](SQL/Views\_v2/GR\_DIM\_RowSet.sql) | RowSet header dimension — list of available RowSets |

| `GR\_DIM\_RowLine` | View | \[SQL/Views\_v2/GR\_DIM\_RowLine.sql](SQL/Views\_v2/GR\_DIM\_RowLine.sql) | RowSet lines dimension — all lines per RowSet with LEVEL0-4 hierarchy labels |

| `GR\_OUT\_RowSet\_Data` | View | \[SQL/Views\_v2/GR\_OUT\_RowSet\_Data.sql](SQL/Views\_v2/GR\_OUT\_RowSet\_Data.sql) | GL data aggregated and mapped to RowSet line numbers, with dimension filtering applied |



\---



\### GL Dimensions



Each `FIN\_GROUPLEDGERDATA` row is broken down by three analytical dimensions in addition to account and entity:



| Column | Meaning |

|---|---|

| `COSTCENTER` | Cost centre |

| `PURPOSE` | Purpose / project code |

| `DEPARTMENT` | Department |



\---



\## Solution Overview



| Item | Detail |

|---|---|

| Solution | `FinstoneReports.sln` |

| Framework | .NET 9 (upgraded from .NET 5) |

| Hosting | Windows Service (`UseWindowsService`) |

| Deployment folder | `dist/` (produced by the \*\*Publish\*\* VS Code task) |

| Service deploy script | `deploy-service.ps1` |



\### Projects



| Project | Type | Target | Purpose |

|---|---|---|---|

| `FinstoneReportsWebAPI` | ASP.NET Core Web API | `net9.0 / win-x64` | REST API host, JWT auth, controllers |

| `FinstoneReportsEF` | Class Library | `net9.0` | EF Core data layer — DbContexts \& models |



> `FinstoneReportsDynamicsAX` was removed from the solution (legacy Dynamics AX 2009 connector, no longer used).



\---



\## Controllers



| Controller | Route | Auth | Purpose |

|---|---|---|---|

| Various data controllers | `/api/…` | `\[Authorize]` | GL data, entity/period dimensions, templates |

| `HealthController` | `GET /health` | `\[Authorize]` | Connectivity health check — returns API + SQL layer status |



\### `HealthController` — `GET /health`

Used by the Node middleware (via client credentials) to verify the C# API and SQL Server are reachable.



\- \*\*Auth:\*\* `\[Authorize]` — called from Node using client credentials token

\- \*\*Response (always HTTP 200):\*\*

&#x20; ```json

&#x20; { "api": "ok", "sql": "ok|error", "sqlError": "...", "timestamp": "..." }

&#x20; ```

\- \*\*SQL check:\*\* `ExecuteSqlRawAsync("SELECT 1")` with a \*\*5-second `CancellationToken`\*\*

\- \*\*Dependency:\*\* Injects `AX5\_MQContext` + `ILogger<HealthController>`



\---



\## Authentication



\- \*\*Scheme:\*\* Azure AD / JWT Bearer

\- \*\*Audience:\*\* `api://938e275d-838c-441e-86f0-fddb3243bcd0`

\- \*\*Authority:\*\* `https://login.microsoftonline.com/a95d7616-c4ea-49d1-809d-a4d86fc1a26f`



\---



\## Data Layer (FinstoneReportsEF)



\### Database Contexts



\#### `AX5\_MQContext`

\- \*\*Server:\*\* `192.168.0.20\\AX`

\- \*\*Database:\*\* `Ax5\_MQ`

\- \*\*Auth:\*\* Windows Integrated Security

\- \*\*SQL Server version:\*\* 2008



\#### `BS\_Context`

\- \*\*Server:\*\* `192.168.0.20\\BS`

\- \*\*Database:\*\* `BS\_Group`

\- \*\*Auth:\*\* Windows Integrated Security

\- \*\*SQL Server version:\*\* 2008

\- Currently has no mapped entities (reserved for future use).



\### ⚠️ SQL Server 2008 Compatibility Constraints



Any SQL written for these databases must be compatible with SQL Server 2008. Key limitations:



| Feature | Status |

|---|---|

| `CREATE OR ALTER VIEW/FUNCTION` | ❌ Not supported — use `IF EXISTS DROP` + `CREATE` |

| `STRING\_AGG()` | ❌ Not available — use `FOR XML PATH` workaround |

| `CONCAT\_WS()` | ❌ Not available |

| `TRY\_CAST()` / `TRY\_CONVERT()` | ❌ Not available |

| `LEAD()` / `LAG()` / `FIRST\_VALUE()` | ❌ Not available |

| `OFFSET … FETCH NEXT` (pagination) | ❌ Not available — use `ROW\_NUMBER()` |

| `IIF()` | ❌ Not available — use `CASE WHEN` |

| `CHOOSE()` | ❌ Not available |

| `FORMAT()` | ❌ Not available |

| `SEQUENCE` objects | ❌ Not available |

| `THROW` | ❌ Not available — use `RAISERROR` |

| Common Table Expressions (CTE) | ✅ Available (SQL 2005+) |

| `ROW\_NUMBER()` / `RANK()` | ✅ Available |

| `CROSS APPLY` / `OUTER APPLY` | ✅ Available |

| Table-valued functions | ✅ Available |



> When generating or modifying any SQL for this project, always target \*\*SQL Server 2008 compatibility\*\*. Use `CASE WHEN` instead of `IIF`, `ROW\_NUMBER()` for pagination, `FOR XML PATH` for string aggregation, and `DROP`/`CREATE` instead of `CREATE OR ALTER`.



\---



\## Security Architecture — How Row-Level Security Works



This is a \*\*dual-access\*\* system. The same SQL views are used both by the Backend API and by users connecting directly from Excel.



\### Direct Excel Access (Windows credentials)



```

Excel user (e.g. FINSTONE\\john)

&#x20; └── Connects to SQL Server with their own Windows credentials

&#x20;       └── GR\_SEC\_DomainUser\_Entity filters to only john's allowed entities

&#x20;             └── All views built on GR\_SEC\_DomainUser\_Entity auto-filter the result

```



\### Backend API Access (service account)



```

Frontend (Excel Add-in)  →  JWT token (contains username)

&#x20; └── Backend API (runs as FINSTONE\\LEANADMIN)

&#x20;       └── GR\_SEC\_DomainUser\_Entity returns ALL entities (LEANADMIN bypass)

&#x20;             └── SQL views return full unfiltered data

&#x20;                   └── API filters result set in code based on JWT username

```



\### The Security View: `GR\_SEC\_DomainUser\_Entity`



```sql

\-- Returns ENTITYCODE rows the current SQL connection user is allowed to see.

\-- LEANADMIN (the API service account) bypasses the filter and sees everything.

WHERE UPPER(DOMAINUSER) = UPPER(SYSTEM\_USER)

&#x20;  OR UPPER(SYSTEM\_USER) = 'FINSTONE\\LEANADMIN'

```



\*\*Why the `\_Users` suffix existed on old views:\*\* it was a developer marker meaning "this view's result set respects the user access list — either via SQL (direct) or via API code (indirect)". The actual filtering gate is `GR\_SEC\_DomainUser\_Entity`. The new `GR\_\*` naming removes this ambiguity.



\*\*Rule:\*\* Never remove or bypass `GR\_SEC\_DomainUser\_Entity` from any view in the chain. It is the single point of access control for direct SQL connections.



\---



\### SQL Objects mapped in EF



> \*\*EF now points to the v2 `GR\_\*` views\*\* (SQL/Views\_v2/ and SQL/Functions\_v2/). The v1 `BI\_\*` views in SQL/Views/ remain deployed for the legacy Excel add-in (direct SQL connection users).



\#### Views (read-only, `HasNoKey` + `ToView`)



| SQL View Name (v2) | EF Model Class | SQL file | v1 equivalent |

|---|---|---|---|

| `GR\_DIM\_Scenario` | `Bi360DimScenario` | \[SQL/Views\_v2/GR\_DIM\_Scenario.sql](SQL/Views\_v2/GR\_DIM\_Scenario.sql) | `BI360\_DIM\_Scenario` |

| `GR\_DIM\_Category` | `BiDimCategory` | \[SQL/Views\_v2/GR\_DIM\_Category.sql](SQL/Views\_v2/GR\_DIM\_Category.sql) | `BI\_DIM\_Category` |

| `GR\_DIM\_Entity` | `BiDimEntity` | \[SQL/Views\_v2/GR\_DIM\_Entity.sql](SQL/Views\_v2/GR\_DIM\_Entity.sql) | `BI\_DIM\_Entities\_Users` |

| `GR\_DIM\_EntityPeriod` | `BiDimEntityPeriodUser` | \[SQL/Views\_v2/GR\_DIM\_EntityPeriod.sql](SQL/Views\_v2/GR\_DIM\_EntityPeriod.sql) | `BI\_DIM\_EntityPeriod\_Users` |

| `GR\_DIM\_RowSet` | `GrDimRowSet` | \[SQL/Views\_v2/GR\_DIM\_RowSet.sql](SQL/Views\_v2/GR\_DIM\_RowSet.sql) | \*(new)\* |

| `GR\_DIM\_RowLine` | `GrDimRowLine` | \[SQL/Views\_v2/GR\_DIM\_RowLine.sql](SQL/Views\_v2/GR\_DIM\_RowLine.sql) | \*(new)\* |

| `GR\_OUT\_GL\_GroupData` | `BiOutGlGroupFullDataLvdm` | \[SQL/Views\_v2/GR\_OUT\_GL\_GroupData.sql](SQL/Views\_v2/GR\_OUT\_GL\_GroupData.sql) | `BI\_OUT\_GL\_Group\_Full\_Data\_lvdm` |

| `GR\_OUT\_Invent\_GroupData` | `BiOutInventGroupDataLvdm` | \[SQL/Views\_v2/GR\_OUT\_Invent\_GroupData.sql](SQL/Views\_v2/GR\_OUT\_Invent\_GroupData.sql) | `BI\_OUT\_Invent\_Group\_Data\_lvdm` |

| `GR\_OUT\_RowSet\_Data` | `GrOutRowSetData` | \[SQL/Views\_v2/GR\_OUT\_RowSet\_Data.sql](SQL/Views\_v2/GR\_OUT\_RowSet\_Data.sql) | \*(new)\* |



\#### Tables (read/write, `ToTable`)



| SQL Table Name | EF Model Class | Notes |

|---|---|---|

| `FIN\_GROUPEXCELTEMPLATES` | `FinGroupexceltemplate` | Excel template definitions |

| `FIN\_GROUPLEDGERDATA` | `FinGroupledgerdatum` | Ledger data entries |

| `FIN\_GROUPUSERLOG` | `FinGroupuserlog` | User action log (`HasNoKey`) |



\#### Table-Valued Functions



| SQL Function Name (v2) | EF Model Class | SQL file | v1 equivalent | Usage |

|---|---|---|---|---|

| `GR\_FN\_ChildEntities` | `BIChildEntities\_FN` | \[SQL/Functions\_v2/GR\_FN\_ChildEntities.sql](SQL/Functions\_v2/GR\_FN\_ChildEntities.sql) | `BI\_Child\_Entities` | `context.GR\_FN\_ChildEntities("PARENT\_CODE")` |



\#### RowSet EF Model Classes (manually authored — not scaffolded)



| Class | File | DbSet | Notes |

|---|---|---|---|

| `GrDimRowSet` | `FinstoneReportsEF/Models/GrDimRowSet.cs` | `GrDimRowSets` | `Rowsetcode`, `Rowsetname`, audit fields |

| `GrDimRowLine` | `FinstoneReportsEF/Models/GrDimRowLine.cs` | `GrDimRowLines` | `Rowsetcode`, `Rowlineno`, `Rowlinename`, `RowName`, LEVEL0-4 Sort/Name, `Recid` |

| `GrOutRowSetData` | `FinstoneReportsEF/Models/GrOutRowSetData.cs` | `GrOutRowSetData` | `RowSetCode`, `RowLineNo`, LEVEL0-4, `EntityCode`, `Year`, `TimePeriod`, `Scenariocode`, `Category`, `Currency`, `Amount`, `AmountMst` |



\#### Stored Procedures



| SP | Output model | Notes |

|---|---|---|

| \*(name unknown — check controllers)\* | `Bi\_SP\_StatusOut` | Returns a `statusOut` string parameter |



\---



\## Re-scaffolding EF Models



The EF models were scaffolded from the database by name (not the entire DB) using `dotnet ef dbcontext scaffold` with explicit `--table` flags. This keeps only the objects actually used by the API in the project.



\### Command to re-scaffold `AX5\_MQContext` (v2 — GR\_ views)



```powershell

dotnet ef dbcontext scaffold `

&#x20; "Data Source=192.168.0.20\\AX;Initial Catalog=Ax5\_MQ;Integrated Security=True;TrustServerCertificate=True" `

&#x20; Microsoft.EntityFrameworkCore.SqlServer `

&#x20; --project FinstoneReportsEF `

&#x20; --startup-project FinstoneReportsWebAPI `

&#x20; --output-dir Models `

&#x20; --context AX5\_MQContext `

&#x20; --context-namespace FinstoneReportsEF.Models `

&#x20; --namespace FinstoneReportsEF.Models `

&#x20; --force `

&#x20; --table GR\_DIM\_Scenario `

&#x20; --table GR\_DIM\_Category `

&#x20; --table GR\_DIM\_Entity `

&#x20; --table GR\_DIM\_EntityPeriod `

&#x20; --table GR\_OUT\_GL\_GroupData `

&#x20; --table GR\_OUT\_Invent\_GroupData `

&#x20; --table FIN\_GROUPEXCELTEMPLATES `

&#x20; --table FIN\_GROUPLEDGERDATA `

&#x20; --table FIN\_GROUPUSERLOG

```



> \*\*Note:\*\* Table-valued functions (`BI\_Child\_Entities`) and stored procedures cannot be scaffolded via `--table`. They must be added manually to the context after scaffolding, as they currently are in `AX5\_MQContext.cs`.



> \*\*Warning:\*\* Re-scaffolding with `--force` will overwrite `AX5\_MQContext.cs` and the model files. Any manual customisations (e.g. the `BI\_Child\_Entities` function registration) must be re-applied afterwards. Consider using partial classes to protect customisations.



\---



\## SQL Folder



The `SQL/` folder holds source-controlled copies of all custom SQL objects deployed to `Ax5\_MQ`.



\- \*\*`SQL/Views/` and `SQL/Functions/`\*\* — v1 objects (`BI\_\*` naming). Keep deployed for the \*\*legacy Excel add-in\*\* (direct SQL connections). Do not modify.

\- \*\*`SQL/Views\_v2/` and `SQL/Functions\_v2/`\*\* — v2 objects (`GR\_\*` naming). Used by the \*\*Backend API\*\* (EF Core). This is the active development line.



\### v2 Deployment order (GR\_ objects — deploy to SQL Server in this order)



```

1\. GR\_SEC\_DomainUser\_Entity        (no view dependencies — deploy first)

2\. GR\_BASE\_Entity\_HistoryMap       (depends on: GR\_SEC\_DomainUser\_Entity)

3\. GR\_BASE\_Ledger\_CompanyAccounts  (depends on: GR\_SEC\_DomainUser\_Entity)

4\. GR\_BASE\_Ledger\_GroupAccounts    (no view dependencies)

5\. GR\_BASE\_GL\_Data\_Mapped          (depends on: GR\_BASE\_Entity\_HistoryMap, GR\_SEC\_DomainUser\_Entity)

6\. GR\_DIM\_Scenario                 (no view dependencies)

7\. GR\_DIM\_Category                 (no view dependencies)

8\. GR\_DIM\_Entity                   (depends on: GR\_BASE\_Entity\_HistoryMap)

9\. GR\_DIM\_EntityPeriod             (no view dependencies)

10\. GR\_OUT\_GL\_GroupData            (depends on: GR\_BASE\_GL\_Data\_Mapped, GR\_BASE\_Ledger\_CompanyAccounts, GR\_BASE\_Ledger\_GroupAccounts)

11\. GR\_OUT\_Invent\_GroupData        (depends on: GR\_SEC\_DomainUser\_Entity)

12\. GR\_DIM\_RowSet                  (no view dependencies — tables only)

13\. GR\_DIM\_RowLine                 (no view dependencies — tables only)

14\. GR\_OUT\_RowSet\_Data             (depends on: GR\_BASE\_GL\_Data\_Mapped, GR\_OUT\_GL\_GroupData)

\--- Functions ---

15\. GR\_FN\_ChildEntities            (depends on: GR\_BASE\_Entity\_HistoryMap)

```



\### v2 Full dependency map



```

GR\_OUT\_GL\_GroupData                         ← EF mapped

&#x20; ├── GR\_BASE\_GL\_Data\_Mapped

&#x20; │     ├── GR\_BASE\_Entity\_HistoryMap

&#x20; │     │     └── GR\_SEC\_DomainUser\_Entity

&#x20; │     │           └── FIN\_GROUPUSERS (table)

&#x20; │     │               FIN\_GROUPUSERENTITY (table)

&#x20; │     ├── FIN\_GROUPLEDGERDATA (table)

&#x20; │     ├── FIN\_GROUPLEDGERMAPPING (table)

&#x20; │     └── FIN\_GROUPLEDGERMAPHISTORY (table)

&#x20; ├── GR\_BASE\_Ledger\_CompanyAccounts

&#x20; │     ├── GR\_SEC\_DomainUser\_Entity

&#x20; │     ├── FIN\_GROUPLEDGERTABLE (table)

&#x20; │     ├── FIN\_GROUPENTITIES (table)

&#x20; │     └── FIN\_GROUPENTITYHISTORY (table)

&#x20; └── GR\_BASE\_Ledger\_GroupAccounts

&#x20;       ├── FIN\_GROUPLEDGERTABLE (table)

&#x20;       └── FIN\_GROUPENTITIES (table)



GR\_OUT\_Invent\_GroupData                     ← EF mapped

&#x20; ├── GR\_SEC\_DomainUser\_Entity

&#x20; └── FIN\_GROUPINVENTORYDATA (table)



GR\_DIM\_Entity                               ← EF mapped

&#x20; ├── GR\_BASE\_Entity\_HistoryMap

&#x20; └── FIN\_GroupUserEntity (table)



GR\_DIM\_EntityPeriod                         ← EF mapped  (tables only)

GR\_DIM\_Category                             ← EF mapped  (tables only)

GR\_DIM\_Scenario                             ← EF mapped  (tables only)



GR\_FN\_ChildEntities (function)              ← EF mapped

&#x20; └── GR\_BASE\_Entity\_HistoryMap

```



\### v1 Deployment order (BI\_ objects — legacy, reference only)



```

1\. BI\_DIM\_DomainUser\_Entity

2\. BI\_DIM\_Entities\_History\_Map

3\. BI360\_DIM\_Ledger\_CompanyAccounts\_lvdm

4\. BI360\_DIM\_Ledger\_GroupAccounts\_lvdm

5\. BI\_OUT\_GL\_Group\_Data\_lvdm\_historical\_mapped

6\. BI\_OUT\_GL\_Group\_Full\_Data\_lvdm

7\. BI\_OUT\_Invent\_Group\_Data\_lvdm

8\. BI\_DIM\_Category

9\. BI360\_DIM\_Scenario

10\. BI\_DIM\_Entities\_Users

11\. BI\_DIM\_EntityPeriod\_Users

12\. BI\_Child\_Entities  (function)

```



\### SQL folder structure



```

SQL/

&#x20; Views/                                              ← v1 (legacy Excel add-in, do not modify)

&#x20;   BI\_DIM\_DomainUser\_Entity.sql

&#x20;   BI\_DIM\_Entities\_History\_Map.sql

&#x20;   BI360\_DIM\_Ledger\_CompanyAccounts\_lvdm.sql

&#x20;   BI360\_DIM\_Ledger\_GroupAccounts\_lvdm.sql

&#x20;   BI360\_DIM\_Scenario.sql

&#x20;   BI\_DIM\_Category.sql

&#x20;   BI\_DIM\_Entities\_Users.sql

&#x20;   BI\_DIM\_EntityPeriod\_Users.sql

&#x20;   BI\_OUT\_GL\_Group\_Data\_lvdm\_historical\_mapped.sql

&#x20;   BI\_OUT\_GL\_Group\_Full\_Data\_lvdm.sql

&#x20;   BI\_OUT\_Invent\_Group\_Data\_lvdm.sql

&#x20; Functions/                                          ← v1 (legacy)

&#x20;   BI\_Child\_Entities.sql

&#x20; Views\_v2/                                           ← v2 (Backend API — active)

&#x20;   GR\_SEC\_DomainUser\_Entity.sql                      ← row-level security gate (deploy first)

&#x20;   GR\_BASE\_Entity\_HistoryMap.sql                     ← entity rename history map

&#x20;   GR\_BASE\_Ledger\_CompanyAccounts.sql                ← company chart of accounts

&#x20;   GR\_BASE\_Ledger\_GroupAccounts.sql                  ← group chart of accounts

&#x20;   GR\_BASE\_GL\_Data\_Mapped.sql                        ← aggregated GL with entity/account remapping

&#x20;   GR\_DIM\_Scenario.sql                               ← scenario dimension (EF mapped)

&#x20;   GR\_DIM\_Category.sql                               ← category dimension (EF mapped)

&#x20;   GR\_DIM\_Entity.sql                                 ← entity dimension (EF mapped)

&#x20;   GR\_DIM\_EntityPeriod.sql                           ← period dimension (EF mapped)

&#x20;   GR\_OUT\_GL\_GroupData.sql                           ← main GL output (EF mapped)

&#x20;   GR\_OUT\_Invent\_GroupData.sql                       ← inventory output (EF mapped)

&#x20;   GR\_DIM\_RowSet.sql                                 ← RowSet header dimension (EF mapped)

&#x20;   GR\_DIM\_RowLine.sql                                ← RowSet line detail with LEVEL0-4 (EF mapped)

&#x20;   GR\_OUT\_RowSet\_Data.sql                            ← RowSet GL output with dimension filter (EF mapped)

&#x20; Functions\_v2/                                       ← v2 (Backend API — active)

&#x20;   GR\_FN\_ChildEntities.sql                           ← recursive entity hierarchy TVF (EF mapped)

```



\### GR\_ Naming Scheme



| Tier | Pattern | Purpose |

|---|---|---|

| Security | `GR\_SEC\_\*` | Row-level security filters — always the base of any view chain |

| Base | `GR\_BASE\_\*` | Internal dependency views — not EF-mapped, not consumed by API directly |

| Dimension | `GR\_DIM\_\*` | Reference/lookup data — EF-mapped |

| Output | `GR\_OUT\_\*` | Fact/reporting data — EF-mapped |

| Function | `GR\_FN\_\*` | Table-valued functions — EF-mapped |



\### Key design notes



\- \*\*Row-level security\*\* is implemented entirely in SQL via `BI\_DIM\_DomainUser\_Entity`, which filters on `SYSTEM\_USER`. The Windows identity of the service account (`FINSTONE\\LEANADMIN`) bypasses the filter and sees all entities — individual user connections are restricted.

\- \*\*Entity history mapping\*\* (`BI\_DIM\_Entities\_History\_Map`) handles entity code renames over time. Historical GL transactions are remapped to new entity codes using `FIN\_GROUPENTITYHISTORY` and a period date range.

\- \*\*Group account mapping\*\* (`FIN\_GROUPLEDGERMAPPING` / `FIN\_GROUPLEDGERMAPHISTORY`) translates company-level accounts to group consolidation accounts (`\_002` entity).



\---



\## API Endpoints



\### `UserController` — `GET /user`



Returns the full `UserModel` for the authenticated user. Populated in this order:



1\. \*\*Entities\*\* — from `GR\_DIM\_Entity` filtered by `Username`

2\. \*\*EntityPeriods\*\* — from `GR\_DIM\_EntityPeriod` filtered by entity + username + `Active == 1` (nested under each entity)

3\. \*\*ExcelTemplates\*\* — from `FIN\_GROUPEXCELTEMPLATES` (public or owned by user)

4\. \*\*Scenarios\*\* — from `GR\_DIM\_Scenario` (all)

5\. \*\*Categories\*\* — from `GR\_DIM\_Category` (all)

6\. \*\*RowSets\*\* — from `GR\_DIM\_RowSet` (all), each with nested `Lines` from `GR\_DIM\_RowLine` (ordered by `Rowlineno`)

7\. \*\*DataSets\*\* — empty placeholder `DataSetModel`



\### `DataController` — `POST /data/dynamicdata`



Main GL/Inventory data retrieval. Accepts `DataSetModel` body with `Parameters` list:



| Parameter name | Required | Notes |

|---|---|---|

| `entityCode` | ✅ | Single entity or parent (children resolved via `GR\_FN\_ChildEntities`) |

| `category` | optional | e.g. `MAIN`, `GBP`, `BUD` |

| `year` | optional | Defaults to current year |

| `month` | optional | Filter to specific month |



`DataType` field on `DataSetModel` switches between `GLData` (default, queries `GR\_OUT\_GL\_GroupData`) and `InventData` (queries `GR\_OUT\_Invent\_GroupData`).



\### `DataController` — `POST /data/rowdata` \*(new)\*



RowSet data retrieval. Same `DataSetModel` structure as `dynamicdata` with one additional required parameter:



| Parameter name | Required | Notes |

|---|---|---|

| `entityCode` | ✅ | Single entity or parent (children resolved via `GR\_FN\_ChildEntities`) |

| `rowSetCode` | ✅ | Which RowSet to retrieve (e.g. `CASHFLOW`) |

| `category` | optional | e.g. `MAIN`, `GBP` |

| `year` | optional | Defaults to current year |

| `month` | optional | Filters on `TimePeriod` column |



Queries `GR\_OUT\_RowSet\_Data`. Excludes `CLS` scenario. Returns `DataResponseModel` with same envelope as `dynamicdata`. Supports optional `Columns` projection via `DynamicSelectGenerator`.



\### `UserModel` — Key Models



| Class | File | Purpose |

|---|---|---|

| `UserModel` | `Models/UserModel.cs` | Top-level user object — includes `RowSets` list |

| `RowSetModel` | `Models/UserModel.cs` | `RowSetCode`, `RowSetName`, `List<RowLineModel> Lines` |

| `RowLineModel` | `Models/UserModel.cs` | Full RowLine including `RowLineNo`, `RowLineName`, `RowName`, LEVEL0-4 Sort/Name |

| `PeriodModel` | `Models/UserModel.cs` | `TimePeriod`, `Year`, `Month`, `MonthName`, `StartDate`, `EndDate` |



\---



\## VS Code Tasks



| Task | Shortcut | Description |

|---|---|---|

| \*\*Build\*\* | `Ctrl+Shift+B` | Debug build of the full solution |

| \*\*Publish\*\* | Terminal → Run Task | Cleans `dist/`, then publishes single-file release build to `dist/` |



\---



\## Deployment



1\. Run the \*\*Publish\*\* task → produces `dist/FinstoneReportsWebAPI.exe` + `appsettings.json`

2\. Copy `dist/` contents to `F:\\FinstoneDataService\\` on the server

3\. Run `deploy-service.ps1` as Administrator (first-time only) to register the Windows Service

4\. For updates: stop the service, overwrite files, start the service



```powershell

Stop-Service  -Name FinstoneReportsWebAPI

\# copy dist/ contents to F:\\FinstoneDataService\\

Start-Service -Name FinstoneReportsWebAPI

```



\---



\## Known Issues / Technical Debt



| Item | Detail |

|---|---|

| Hardcoded connection strings | `AX5\_MQContext` and `BS\_Context` have connection strings in source code. Should be moved to `appsettings.json` / user secrets. |

| Hardcoded AAD config | Audience and Authority in `Startup.cs` are hardcoded. Should be in `appsettings.json`. |

| CA2017 warnings | `DataController.cs` has 14 logging template placeholder mismatches. Low risk but should be cleaned up. |

| Hardcoded `\_002` group entity | `GR\_BASE\_GL\_Data\_Mapped` hardcodes `TOENTITYCODE = '\_002'` in both the `FIN\_GROUPLEDGERMAPHISTORY` correlated subquery and the `FIN\_GROUPLEDGERMAPPING` join. The data model supports multiple group structure entities (`ISSTRUCTURE = 1`), but the view currently only resolves mappings to `\_002`. When a second group structure is introduced, these literals must be replaced with a dynamic join against the set of group structure entities. |



\--- BACKEND CONTEXT END ---

