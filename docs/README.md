# Foodie: household inventory

Foodie helps a private household keep track of what it has at home and what it needs to buy. It started as an app for the freezer; the goal is the whole household: freezer, fridge, pantry, kitchen cupboards and the supplies a household regularly stocks up on, such as cleaning products, toiletries or paper goods.

Everything stays on the phone. Foodie has no account, no server and no network access.

## Mission

Help a household always know three things, without effort and without giving its data away:

1. **What do we have, and where?** Every item sits in a storage place the household defines itself: a freezer drawer, a fridge shelf, a pantry shelf, the cupboard under the sink.
2. **What should we use first?** Food that has been stored a long time or is close to its best-before date is surfaced before it goes to waste.
3. **What do we need to buy?** Items the household always wants at home go on the shopping list when they run low, and what was bought goes back into stock in one step.

## Principles

These apply to every feature, present and planned.

**Privacy first: no data leaves the app.**
No network code, no analytics, no crash reporting, no cloud sync, no online product databases. The Android release build has no `INTERNET` permission, so the operating system blocks all network access. The database and pictures are encrypted on the device, and OS backups are switched off. Data only leaves the phone when the user exports an encrypted backup or a CSV file themselves.

**Modular, readable Flutter, mobile first.**
The app is a Dart pub workspace: a thin app shell, shared core packages, and one package per user-facing feature. Each feature has the same four layers (presentation, application, domain, data) and plugs into the shell through one `FeatureModule` contract. Names are English and descriptive. The app targets Android and iOS phones.

**Clean, self-explanatory, simple UI.**
The most frequent actions (put something in, take some out, tick off the shopping list) take one or two taps and need no explanation. Screens show only what helps the next decision. Optional features (barcode scanning, pictures) can be switched off and then disappear completely. Nothing relies on colour alone, and every chart can be shown as a table.

## Scope

The household is split into three storage domains. Each one beyond the freezer can be switched on or off in Config → Optional features; switching one off hides its items and keeps them.

| Domain | Storage places | Examples | Default | Status |
| --- | --- | --- | --- | --- |
| Freezer | Upright and chest freezers, the freezer compartment of a fridge | Frozen vegetables, meat, homemade meals | Always on | Built |
| Pantry | Fridge, pantry, kitchen cupboards, cellar | Milk, eggs, bread, pasta, tins, spices, drinks | On | Planned |
| Household supplies | Cleaning cupboard, bathroom cabinet, laundry room, garden shed, garage | Dish soap, toilet paper, detergent, potting soil, batteries, plasters | Off | Planned |

Possessions that are not used up (tools, furniture, electronics) are out of scope.

What is built today works for every domain in principle (products, quantities, restock rules, shopping list), but the storage layout, the wording and the reminders are written for freezers. The architecture document describes how they generalise (section 10.7) and designs pantry management (10.8), household supplies (10.9) and receipt scanning (10.10).

## What exists today

Release 0.1.1 contains:

- **Storage layout:** freezers with drawers, baskets or shelves that the user names, reorders, colours and archives.
- **Inventory:** stock batches with an exact quantity, partial removal (take 200 g of a 1 kg bag), moving, discarding, correcting and undo. Every change is written to an append-only movement log.
- **Product catalog:** a translated seeded catalog of frozen foods, user-defined products, categories with recommended storage durations, product icons.
- **Storage reminders:** an "eat soon" card and a daily digest notification for items stored a long time.
- **Restock and shopping list:** minimum and target quantities per product, a shopping list that fills itself when stock runs low, a "runs out in" estimate.
- **Insights:** charts of habits and waste around one shared filter, with saved views.
- **Item pictures and barcode scanning** (both optional), on-device only.
- **Backup, restore and CSV export**, onboarding, and a Config tab with language (English, German) and appearance.

The code still uses the original freezer names (`apps/freezer_app`, `Freezer`, `frozenOn`). Renaming follows the generalisation step by step; see the architecture document.

## Planned

In order:

1. **Household foundation:** neutral wording ("Use soon", a "Stock" tab with a domain switch that only appears when more than one domain is on), storage domains, and two new module contributions (storage kinds and seeded catalog). Shelf lives can be entered in days, weeks or months, so a product can be good for just one or two days. Best-before and "opened on" dates become reminder triggers.
2. **Pantry management** (optional, on by default): fridge, pantry and cupboard storage places, a best-before date on every item with quick chips (+1 day, +3 days, +1 week), "mark as opened" with a shelf life after opening (milk 3 days), and a pantry catalog. Items that go off tomorrow appear in today's "Use soon" card and tomorrow's digest.
3. **Household supplies** (optional, off by default): storage places such as the cleaning cupboard or garden shed, and a catalog of cleaning, laundry, bathroom, kitchen paper, garden, pet, first aid, technical, baby and office supplies. Adding a supply offers to set a minimum right away, because the point is never running out. Expiry dates are only used where they exist (medicine, sun cream, batteries). Supplies never count as food waste.
4. **Receipt scanning** (optional, off by default): photograph a shopping receipt, and on-device text recognition reads it and suggests the purchases to add. Lines that match no known product are flagged at the top of the review list so the user can pick a product, create one or ignore the line; nothing is added without confirmation. What the user confirms is learned per store, so the next receipt needs fewer taps. Every receipt is archived (images encrypted, card and loyalty numbers masked in the text) and its text is searchable, for example "olive oil" across a year of shopping. No receipt or text ever leaves the phone.

Later ideas: consumption forecasts, QR labels for homemade meals, home-screen widgets, meal planning.

## Documents

- [`design/architecture.html`](design/architecture.html): the architecture the code follows, the technology decisions, the privacy measures and the plan for generalising from freezer to household, including the pantry, household supplies and receipt scanning modules. Open it in a browser.
- [`design/ui-examples.html`](design/ui-examples.html): interactive screen examples of the app as built today (freezer). Open it in a browser.
- [`release-notes/`](release-notes): notes for each published release.

## Glossary

| Term | Meaning | Name in code today |
| --- | --- | --- |
| Storage domain | Freezer, pantry or household supplies; the unit that is switched on or off | (planned) |
| Storage place | A freezer, fridge, pantry or cupboard | `Freezer` |
| Storage kind | What kind of storage place it is | `StorageKind` |
| Compartment | A drawer, basket or shelf inside a storage place | `Compartment` |
| Product | Something the household keeps, such as peas or dish soap | `Product` |
| Stock batch | One physical package or box with its own date and remaining amount | `StockBatch` |
| Shelf life | How long a product keeps, in days, weeks or months; optionally a shorter one after opening | `recommendedMaximumStorageDays` |
| Receipt | A scanned shopping receipt with its pages, recognised text and parsed lines, kept in the archive | (planned) |
| Best before | The date printed on the package, called "expires" for supplies | `bestBeforeOn` |
| Movement | One recorded change: added, used, thrown away, moved or corrected | `InventoryMovement` |
| Restock rule | The minimum and target amount of a product to keep at home | `RestockRule` |
