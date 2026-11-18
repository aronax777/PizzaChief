# Mobile kitchen and first pizza — 2026-11-17

## Mobile interface

The client selects a compact layout when the safe UI area is narrower than 1000 px or shorter than 600 px. It lays out controls at native UI size instead of scaling down the 1440×900 desktop canvas. `CoreUISafeInsets` protects the controls from Roblox chrome and device cutouts. `StarterGui.ScreenOrientation = Sensor` allows portrait and landscape.

- Portrait: stacked cooking guidance, pizza preview, ingredient cards, and scrollable supporting content. The main cooking action stays fixed above the bottom navigation.
- Short landscape: two-column kitchen with a single bottom action row; temperature controls and the turn timing window remain visible together.
- Menu, results, recipe book, record card, and language picker have compact layouts. Result continuation remains fixed on screen.
- Ingredient cards use four items per page on compact screens, with 44 px add/remove buttons. Existing eight-card desktop pages are preserved.
- Resizing and rotation rebuild presentation while retaining authoritative cooking state. A heat-slider drag belongs to its initiating touch, so another finger cannot steal or release it.
- The compact menu includes the current persistence status below the collection. Studio remains session-only.

`src/shared/MobileLayout.luau` reflows existing controls and callbacks; scoring and game actions remain in the same server pipeline.

## First pizza

New players see the first-pizza invitation in the main menu. Their first `StartShift` enters an untimed Margherita lesson unless they have completed or skipped it, or already completed a regular order. Existing profiles therefore keep their normal career entry.

The lesson reveals tomato → mozzarella → basil → olive oil. The server permits only the current ingredient and its required portions, and refuses to bake an incomplete recipe. Removing an ingredient restores the corresponding instruction. On phones, the current ingredient occupies the same card position so subsequent steps do not require hunting through the pantry.

The player then uses the real oven, heat controls, turn window, and Serve action. Turning is taught but optional; missing its window does not block completion. There is no order deadline or speed penalty for reading guidance. Tutorial total equals cooking quality. Guided results do not grant XP, career stars, records, badges, or combo changes.

Only serving a fully baked lesson pizza sets `tutorialCompleted`. `tutorialDismissed` separately records the explicit Skip action, which starts a normal shift. Both booleans pass through the existing profile sanitization and lease-based saving. Leaving for the menu does not mark completion. The menu offers lesson replay after completion, dismissal, or prior career progress. All 17 catalogs include the new copy.

## Validation

- 228 isolated check executions, representing 179 distinct assertions: cooking/rooms, tutorial gates and transitions, profile save/reload, shutdown, progression and recipes.
- Eight assertions on the actual Studio client/server: lesson start, ingredient assembly, real baking and perfect turn, serve, completion, no career rewards, career continuation, replay and skip (some assertions cover multiple conditions).
- Simulator inspection on iPhone 17 Pro portrait, Samsung Galaxy A06 portrait/landscape, and iPad Pro M5 landscape. Rotation was exercised during baking.
- Native mouse input exercised ingredient addition, serving, career continuation, recipe/language modals, the full ingredient catalog and its next page.
- Compact-layout scans found no active buttons below the 44 px design target or offscreen fixed actions in the recorded scenarios. Catalog checks cover 17 × 294 translations and matching placeholders.
- Ukrainian and Arabic tutorial screens inspected visually. The new translations have not had independent native-speaker review.

Evidence: `tests/mobile-tutorial-validation.json`, `tests/scan_mobile_ui.luau`, and `screenshots/mobile/`. Run the Python harness generators, then execute their generated Luau chunks in Studio Edit mode. These tests use an in-memory DataStore substitute and never write cloud profiles.

This is simulator and automated gameplay validation, not a physical-device performance/touch test or a human usability study. The earlier two-player network Battle test was not repeated. Studio was stopped and reset to the default viewport after testing.

Both `PizzaChief.rbxlx` and `dist/PizzaChief.rbxlx` include the update and are checked against all 30 embedded source files. This update has not been published to Roblox.
