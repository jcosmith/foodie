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

The household is split into four storage domains, and each one is its own tab in the app: Freezer, Fridge, Pantry and Household. The switches in Options add or remove a tab. Switching one off keeps its items, and switching it on again brings them back.

| Domain | Storage places | Examples | Default | Status |
| --- | --- | --- | --- | --- |
| Freezer | Upright and chest freezers, the freezer compartment of a fridge | Frozen vegetables, meat, homemade meals | On | Built |
| Fridge | Fridge, drinks fridge, wine fridge | Milk, eggs, cheese, fresh vegetables, leftovers | On | Built |
| Pantry | Pantry, kitchen cupboards, cellar | Bread, pasta, rice, tins, spices, drinks | On | Built |
| Household | Cleaning cupboard, bathroom cabinet, laundry room, garden shed, garage | Dish soap, toilet paper, detergent, potting soil, batteries, plasters | Off | Basics built, full later |

**Food first.** The freezer, fridge, pantry and receipt scanning come first, until all of it is set up for regular use. Household supplies are firmly in scope: their bare bones (the Household tab, its storage places, a small catalog and restock rules) come early so a household can switch them on, and the full feature set follows later. Nothing built for food may prevent that expansion: core code speaks of products and stock rather than food, domains are data rather than a fixed list, dates are optional, and the receipt scanner matches against every domain (architecture section 10.7, "Keeping household supplies open").

Possessions that are not used up (tools, furniture, electronics) are out of scope.

The storage layout, dates, wording, reminders and statistics now work per domain. The architecture document describes the generalisation (section 10.7), fridge and pantry (10.8), household supplies (10.9) and receipt scanning (10.10).

## What exists today

Release 0.1.1 was the freezer app. The code since then (not yet released) is Foodie:

- **Storage domains:** Freezer, Fridge, Pantry and Household are each a tab with their own storage places, catalog and wording; Options switches them on and off without deleting anything. The bottom bar reads Home · Freezer · Fridge · Pantry · (Household) · Lists · More.
- **Storage layout:** storage places of every kind (freezers, fridges, pantries, cupboards, supply cupboards) with drawers, baskets or shelves that the user names, reorders, colours and archives.
- **Inventory:** stock batches with an exact quantity, a stored-on date, an optional best-before date and "opened on" with a shelf life after opening; partial removal, moving, discarding, correcting and undo, all written to an append-only movement log.
- **Product catalog:** translated seeded catalogs for each domain, user-defined products, categories with a shelf life in days, weeks or months, product icons.
- **Storage reminders:** a "Use soon" card and daily digest driven by the earliest of shelf life, best-before and opened-on dates; storage limits per category, grouped by storage area.
- **Restock and Lists:** minimum and target quantities per product, a shopping list that fills itself when stock runs low, and restocking in one step.
- **Receipt scanning** (optional, off by default): photograph a receipt, read it on the phone with a bundled text model, review flagged lines, add the rest; receipts are archived encrypted, searchable and learned per store.
- **Statistics:** charts of habits and waste around one shared filter, including a storage-area filter, with saved views.
- **Item pictures and barcode scanning** (both optional), on-device only.
- **Backup, restore and CSV export**, onboarding, and Options with tabs, optional features, language (English, German) and appearance.

The app package is `apps/foodie_app` and its Android application id and iOS bundle id are `io.github.jcosmith.foodie`. Foodie installs as its own app next to the former Freezer app; to take data over, make a backup in Freezer and restore it in Foodie.

## Planned

Steps 1 to 4 of the earlier plan (household foundation, fridge and pantry, household basics, receipt scanning) are built. Next:

1. **Household supplies, full:** the full catalog with storage places such as the cleaning cupboard or garden shed, covering cleaning, laundry, bathroom, kitchen paper, garden, pet, first aid, technical, baby and office supplies. Adding a supply offers to set a minimum right away, because the point is never running out. Expiry dates are only used where they exist (medicine, sun cream, batteries). Supplies never count as food waste.

Later ideas: consumption forecasts, QR labels for homemade meals, home-screen widgets, meal planning.

## Documents

- [`design/architecture.html`](design/architecture.html): the architecture the code follows, the technology decisions, the privacy measures and the plan for generalising from freezer to household, including the pantry, household supplies and receipt scanning modules. Open it in a browser.
- [`design/ui-examples.html`](design/ui-examples.html): interactive screen examples: the freezer app of release 0.1.1, followed by the household screens that are now built: the Fridge tab, adding with a best-before date, receipt review, the Lists tab with the receipt archive, the More tab, and the Options switches that add or remove the Freezer, Fridge, Pantry and Household tabs. Open it in a browser.
- [`release-notes/`](release-notes): notes for each published release.

## Glossary

| Term | Meaning | Name in code |
| --- | --- | --- |
| Storage domain | Freezer, fridge, pantry or household; each is a tab that is switched on or off | `StorageDomainIdentifier` |
| Storage place | A freezer, fridge, pantry or cupboard | `StoragePlace` |
| Storage kind | What kind of storage place it is | `StorageKind` |
| Compartment | A drawer, basket or shelf inside a storage place | `Compartment` |
| Product | Something the household keeps, such as peas or dish soap | `Product` |
| Stock batch | One physical package or box with its own date and remaining amount | `StockBatch` |
| Shelf life | How long a product keeps, in days, weeks or months; optionally a shorter one after opening | `recommendedMaximumStorageDays` |
| Receipt | A scanned shopping receipt with its pages, recognised text and parsed lines, kept in the archive | `Receipt` |
| Stored on | The day an item went into storage, shown as "Frozen on" for freezers | `storedOn` |
| Opened on | The day a package was opened; a shorter shelf life may apply from then | `openedOn` |
| Best before | The date printed on the package, called "expires" for supplies | `bestBeforeOn` |
| Movement | One recorded change: added, used, thrown away, moved or corrected | `InventoryMovement` |
| Restock rule | The minimum and target amount of a product to keep at home | `RestockRule` |
