# Server contract

`src/server/GameServer.server.luau` belongs in `ServerScriptService`. `Recipes` is a ModuleScript inside `ReplicatedStorage.PizzaChief`. The server creates these children of `PizzaChief`:

- `Action`: RemoteEvent; client calls `FireServer(actionName, argument)`.
- `State`: RemoteEvent; server sends one full snapshot after actions and every 0.2 seconds.
- `GetState`: RemoteFunction; client invokes once during initialization for a full snapshot.

Actions are `StartPractice(recipeId?)`, `SelectRecipe(recipeId)`, `Add(ingredientId)`, `Remove(ingredientId)`, `Clear`, `Bake`, `Heat(normalizedPower)`, `Serve`, `Menu`, `JoinRoom`, and `LeaveRoom`. `Heat` accepts a finite number from 0 to 1, clamped by the server. Inventory permits three portions of any ingredient and twenty portions overall. The server checks the current phase before changing ingredients, heat, or score. Requests have a token bucket of 25 with 15 tokens replenished per second.

Every snapshot has `phase`, `mode`, `recipeId`, `ingredients`, `startedAt`, `deadline`, `temperature`, `heat`, `bakeElapsed`, `bakeDuration`, `bakeQuality`, `result`, `message`, `queued`, `serverNow`, and `room`. `phase` is `menu`, `prep`, `bake`, `ready`, or `result`; `mode` is `practice` or `competition`. Times use `workspace:GetServerTimeNow()`. A zero deadline means unlimited practice preparation.

`room` has `phase` (`waiting`, `countdown`, `active`, or `finished`), `players`, `startsAt`, `endsAt`, `recipeId`, `winner`, `minPlayers`, `maxPlayers`, `member`, `queued`, and `queuedCount`. Player rows contain `userId`, `name`, `done`, optional `total`, `quality`, `speed`, `elapsed`, and `forfeited`. The winner is either nil or `{userId, name, total}`. Results from `Recipes.Score` also receive elapsed seconds, rounded to one decimal.

## Cooking model

Power sets a temperature target from 260 to 520 degrees, with a pair of sinusoidal disturbances. Temperature approaches that target exponentially; the initial oven temperature is 50 degrees below the recipe target. Each simulated interval earns full bake credit inside the target ±25-degree band, dropping linearly to zero at ±115 degrees. `bakeQuality` is the integrated mean credit, expressed as 0–100. Time in the oven is the recipe's `bakeTime`, after which it becomes ready to serve. This is an arcade model, not a food-safety simulation.

The simulation clamps an individual Heartbeat step to 0.25 seconds so a stalled frame does not award an entire bake. The match deadline remains a wall clock deadline. Clients never provide elapsed time, temperature, bake quality, or a score.

## Competition lifecycle

Two to six players form a local-server room. Two joined players trigger a ten-second countdown, cancelled if the count drops below two. All participants start the same recipe together with a 90-second deadline. Joining during a round queues the player for the next room. The queue is also limited to six.

Serving locks the entry. Standings sort by combined score, then quality, then faster elapsed time, then stable user ID. The round ends when everyone has served/forfeited, or the deadline expires. A ready pizza is automatically served at the deadline; unfinished pizzas get zero. Leaving or disconnecting during an unfinished round forfeits that entry. Already-served results remain valid. The room winner must have a positive score. `leaderstats.Wins`, `Best`, and `Level` mirror earned profile progress; the profile owns the durable data when storage is available.

Results stay in the room for twelve seconds. Queued players then enter a fresh waiting room. Each player's personal result card and frozen final standings persist until the player explicitly starts again, joins a new room, or returns to the menu. Completed participants are not silently enrolled in another match.

## Manual acceptance checks

These are a checklist, not claims that a multi-client run has been performed.

1. Practice: add recipe ingredients, remove/re-add a portion, bake, vary power, and serve. Confirm client and server state agree and the result has both quality and speed.
2. Repeat with unrelated extras and with the wrong temperature; both should reduce quality. Empty pizza cannot start baking.
3. Send `Serve` in prep, `Add` in bake, an unknown ingredient, NaN/Infinity heat, and excessive portions; none should grant a score or invalid state.
4. Start Studio with two clients. Join both, confirm one shared countdown, recipe, start time, and deadline. Submit both and confirm matching rankings/winner on both clients.
5. Join a third client mid-round; confirm it queues and does not receive a fresh timer within the existing match.
6. Leave during countdown and during an active round. Confirm countdown cancellation and forfeit respectively. Disconnecting must not leave a round waiting forever.
7. Let a ready pizza and an unfinished pizza time out; the former is scored and the latter receives zero. Check the next lobby after twelve seconds.

This prototype provides rooms inside one Roblox server. Cross-server matchmaking remains outside this implementation. Published servers now support progression persistence as described below.

## Isolated validation performed

`python3 tests/build_room_harness.py` generates `tests/generated-room-validation.luau` from the current server file. Execute that chunk in the correct Studio's Server or Edit data model. It uses the actual installed Recipes module and substitutes local fake Players, remotes, clock, and Heartbeat; it installs no production scripts or test hooks. The package lookup fails immediately if the correct game is not open.

On 2026-11-06 all 19 assertions passed in Roblox Studio. These cover cooking, invalid input, countdown cancellation, shared recipe/timing, queues, timeout/forfeit behavior, replay, and persisted standings. With the final disturbance of 55 and 25 degrees, idle power earned 86.53% bake quality and active control earned 99.81%. Exact output is recorded in `tests/validation-results.json`. This validates server logic with simulated participants; actual multi-client networking remains untested by this harness.


## Version 2: the repeat-play loop

New dependencies: `ReplicatedStorage.PizzaChief.GameRules` and `ServerScriptService.ProfileStore` (ModuleScripts). The client receives `profile`, `shift`, `contract`, and `dailyChallenge` alongside every normal snapshot.

New actions:

- `StartShift`: starts a three-order career shift. A deterministic server seed selects recipes from the rank's unlocked career pool. Order one is the classic challenge (90 seconds); order two has stronger oven drift (80 seconds); order three is rush hour (65 seconds).
- `NextOrder`: valid only after a nonfinal shift result. Advances exactly one stage, clears the pizza and starts a new server deadline.
- `StartDaily`: starts the same UTC-day recipe and modifier for every player. Repeat attempts are unlimited; the 60 XP target bonus is granted only on the first qualifying clear of the captured UTC day (85 points).

Practice still exposes all recipes. Recipe unlocks broaden the career pool; they do not give competitive stats. Battles last 90 seconds and all players get identical recipe conditions regardless of rank.

`shift` fields are `stage`, `total=3`, cumulative `score` (0–300), current `combo`, `finished`, `completed`, a fixed `unlockedRecipes` pool for this shift, and internal deterministic `seed`. A shift ends after three results, including failures. A failed order scores zero and resets the session combo; it does not erase progress. Successful 80+ orders grow the combo up to five across modes, menus and shifts within the same play session. New sessions start at zero without any login penalty. The recipe pool is frozen at shift start, so a rank-up cannot introduce a repeat during that shift. A finished shift worth at least 150 points grants 30 bonus XP and increments `shiftFinishes`. `bestShift` tracks the highest completed total. `contract` contains recipe, localized description, goal, deadline duration, heat multiplier and temperature tolerance.

`profile` fields include XP/rank (`xp`, `level`, `title`, `nextXP`, `progress`, `unlockedRecipes`), `completed`, `perfects`, `totalStars`, `battleWins`, `bestCombo`, `shiftFinishes`, `dailyClears`, `bestShift`, `recipeBest`, `dailyBest={day,score}`, `badges`, and `persistence`. Each `recipeBest[id]` has highest `score` and highest `stars`. Total stars count the best per-recipe collection, never repeated rewards for the same stars.

Daily personal-best comparisons use only the same UTC-day challenge record, independently from unrestricted practice records. Each result includes `previousBest`, `personalBest`, `delta`, and `reward={xp,stars,combo,nextCombo,headline,leveledUp,newRank,unlocked,contractBonus?,dailyBonus?,shiftBonus?}`. Scores and rewards are computed from the completed server session. Repeated `Serve`, premature submission, altered ingredients after baking, and client-supplied result data cannot award extra progress. A zero-result timeout gives no order XP; other successful orders in that shift remain counted. A final timeout can still receive the separate 30 XP shift-completion bonus when earlier orders brought the finished shift to at least 150 points. Room wins are awarded once when the server finalizes standings.

## Profile persistence

`ProfileStore` uses `PizzaChiefProfiles_v2` with one key per Roblox user. Studio and unpublished places intentionally use session-only profiles and report `persistence="session"`; no DataStore calls are made there. Published servers use `UpdateAsync` to acquire a 150-second session lease, refresh/save every 45 seconds, and release on departure or shutdown. A live lease owned by a different server is never overwritten. Failed or contended loads use a temporary local profile and report `unavailable`; these profiles are never saved over existing data. A late load finishing after departure releases its lease.

Stored input is sanitized to finite bounded values. Recipe collections are bounded. A save verifies ownership before writing, so an expired lease taken over by another server cannot overwrite its progress. Save failures preserve local progress and show `unavailable`; subsequent autosaves retry while ownership remains valid. Shutdown waits at most eight seconds for saves. Network failure or server termination can still lose the most recent unsaved progress; live DataStore operation must be tested after publication. No live persistence tests were run in this unpublished Studio place.
