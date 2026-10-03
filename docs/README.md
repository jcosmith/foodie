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

| Area | Examples | Status |
| --- | --- | --- |
| Freezer | Upright and chest freezers, the freezer compartment of a fridge, with their drawers, baskets or shelves | Built |
| Fridge | Shelves, door, vegetable drawer | Planned |
| Pantry and kitchen cupboards | Dry goods, tins, spices, drinks, baking supplies | Planned |
| Household supplies | Cleaning products, laundry, toiletries, paper goods, batteries, light bulbs | Planned |

What is built today works for every area in principle (products, quantities, restock rules, shopping list), but the storage layout, the wording and the reminders are written for freezers. The architecture document describes how they generalise (section 10.7).

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

In rough order:

1. **Storage areas beyond the freezer:** fridge, pantry, cupboard and supply storage kinds with their own templates and default compartment names.
2. **Dates that fit each area:** a neutral "stored on" date instead of "frozen on", best-before dates as a first-class reminder trigger, and an optional "opened on" date for things that spoil once opened.
3. **A household catalog:** seeded categories and products for the pantry, fridge and household supplies, next to the existing frozen foods.
4. **Wording for the whole household:** "use soon" instead of "eat soon", a "Stock" tab instead of "Freezer", discard reasons that are not freezer specific.
5. **Restock for non-food items:** household supplies are mostly about never running out, so restock rules and the shopping list become the main tool for them.

Later ideas: consumption forecasts, QR labels for homemade meals, home-screen widgets, meal planning.

## Documents

- [`design/architecture.html`](design/architecture.html): the architecture the code follows, the technology decisions, the privacy measures and the plan for generalising from freezer to household. Open it in a browser.
- [`design/ui-examples.html`](design/ui-examples.html): interactive screen examples of the app as built today (freezer). Open it in a browser.
- [`release-notes/`](release-notes): notes for each published release.

## Glossary

| Term | Meaning | Name in code today |
| --- | --- | --- |
| Storage place | A freezer, fridge, pantry or cupboard | `Freezer` |
| Storage kind | What kind of storage place it is | `StorageKind` |
| Compartment | A drawer, basket or shelf inside a storage place | `Compartment` |
| Product | Something the household keeps, such as peas or dish soap | `Product` |
| Stock batch | One physical package or box with its own date and remaining amount | `StockBatch` |
| Movement | One recorded change: added, used, thrown away, moved or corrected | `InventoryMovement` |
| Restock rule | The minimum and target amount of a product to keep at home | `RestockRule` |
