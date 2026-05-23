# Implementation Plan: To-Do Life Dashboard

## Overview

Build a client-side single-page dashboard using plain HTML, CSS, and Vanilla JavaScript. The implementation proceeds widget-by-widget, wiring each into a shared `StorageService` and a top-level `init()` function. Testing uses Vitest for unit tests and fast-check for property-based tests.

## Tasks

- [x] 1. Set up project structure and testing framework
  - Create `index.html` with semantic layout sections for each widget (greeting, timer, tasks, links, theme toggle)
  - Create `styles.css` with CSS custom properties for light/dark themes and `data-theme` attribute on `<body>`
  - Create `app.js` as an ES module with a stub `init()` function wired to `DOMContentLoaded`
  - Initialize a `package.json` and install Vitest and fast-check as dev dependencies
  - Create `app.test.js` as the test entry point
  - _Requirements: 7.1, 7.4_

- [x] 2. Implement StorageService
  - [x] 2.1 Implement `StorageService` with `KEYS`, `get()`, `set()`, and `loadAll()`
    - `get()` wraps `JSON.parse` in try/catch and returns `null` on failure
    - `set()` wraps `localStorage.setItem` in try/catch and returns `false` on `QuotaExceededError`
    - `loadAll()` reads all keys and substitutes defaults for `null` results
    - _Requirements: 7.1, 7.2, 7.3, 7.5, 7.6_
  - [-]* 2.2 Write unit tests for `StorageService`
    - Test `loadAll()` with no data returns all defaults
    - Test `loadAll()` with corrupt JSON returns defaults for that key, keeps valid keys
    - Test `set()` returns `false` when storage is unavailable
    - _Requirements: 7.2, 7.6_
  - [-]* 2.3 Write property test for task persistence round-trip (Property 10)
    - **Property 10: Task persistence round-trip**
    - **Validates: Requirements 4.3, 4.11, 7.3**

- [ ] 3. Implement GreetingWidget
  - [x] 3.1 Implement pure functions: `formatTime(date)`, `formatDate(date)`, `getGreetingPhrase(hour)`
    - `formatTime` returns `HH:MM:SS` zero-padded from a `Date` object
    - `formatDate` returns `DayName, DD MonthName YYYY` from a `Date` object
    - `getGreetingPhrase` maps hour 0-23 to one of four greeting strings
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.3, 2.4_
  - [-]* 3.2 Write property test for time format (Property 1)
    - **Property 1: Time format is always HH:MM:SS**
    - **Validates: Requirements 1.1**
  - [-]* 3.3 Write property test for date format (Property 2)
    - **Property 2: Date format is always correct**
    - **Validates: Requirements 1.2**
  - [-]* 3.4 Write property test for greeting phrase coverage (Property 3)
    - **Property 3: Greeting phrase covers all hours**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4**
  - [~] 3.5 Implement `GreetingWidget.init(userName)`, `startClock()`, `updateClock()`, `updateGreeting(userName)`
    - `startClock()` uses `setInterval` at 1000ms to call `updateClock()`
    - `updateGreeting` renders the greeting phrase with the current user name into the DOM
    - Wire name input field: trim input, validate 1-50 chars, save via `StorageService`, update greeting
    - _Requirements: 1.3, 1.4, 2.5, 2.6, 2.7_
  - [ ]* 3.6 Write property test for user name trimming and validation (Property 4)
    - **Property 4: User name trimming and validation**
    - **Validates: Requirements 2.6, 2.7**

- [ ] 4. Implement FocusTimerWidget
  - [x] 4.1 Implement pure functions: `formatDisplay(totalSeconds)` and `validateDuration(input)`
    - `formatDisplay` returns `MM:SS` zero-padded for any integer 0-3600
    - `validateDuration` returns the integer if 1-60 inclusive, otherwise `null`
    - _Requirements: 3.1, 3.8, 3.9_
  - [-]* 4.2 Write property test for timer display format (Property 5)
    - **Property 5: Timer display format is always MM:SS**
    - **Validates: Requirements 3.1**
  - [-]* 4.3 Write property test for duration validation (Property 6)
    - **Property 6: Duration validation accepts only 1-60**
    - **Validates: Requirements 3.8, 3.9**
  - [~] 4.4 Implement `FocusTimerWidget` stateful logic: `init()`, `start()`, `stop()`, `reset()`, `tick()`, `onComplete()`, `saveDuration()`
    - `start()` sets `isRunning = true` and begins `setInterval` calling `tick()` every 1000ms
    - `stop()` clears the interval and retains `remainingSeconds`
    - `reset()` clears the interval and restores `remainingSeconds` to `pomoDuration * 60`
    - `tick()` decrements `remainingSeconds`, guards against going below 0, calls `onComplete()` at 0
    - `onComplete()` plays an audio signal, shows a visual completion indicator, and disables the Start button
    - `saveDuration()` validates input, persists to `StorageService`, and resets the timer
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.10_

- [~] 5. Checkpoint - Ensure all tests pass
  - Run `npx vitest --run` and confirm all passing. Ask the user if any questions arise.

- [ ] 6. Implement TaskListWidget
  - [~] 6.1 Implement `validateTitle(title)` and `generateId()`
    - `validateTitle` returns `false` for empty or whitespace-only strings, and for strings exceeding 200 chars
    - `generateId` returns a unique string using `crypto.randomUUID()`
    - _Requirements: 4.1, 4.2_
  - [ ]* 6.2 Write property test for adding a valid task (Property 7)
    - **Property 7: Adding a valid task grows the list by one**
    - **Validates: Requirements 4.1**
  - [ ]* 6.3 Write property test for invalid task title rejection (Property 8)
    - **Property 8: Invalid task titles are rejected**
    - **Validates: Requirements 4.2**
  - [~] 6.4 Implement `TaskListWidget.init(tasks)`, `addTask()`, `deleteTask()`, `toggleComplete()`, and `renderList()`
    - `addTask` validates title, creates a `Task` object, appends to list, persists via `StorageService`, re-renders
    - `deleteTask` removes by id, persists, re-renders
    - `toggleComplete` flips `completed`, persists, re-renders; apply strikethrough style for completed tasks
    - `renderList` rebuilds the task list DOM from the in-memory array
    - Display inline validation message on empty submission; clear on next valid submission
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.10, 4.11, 4.12_
  - [ ]* 6.5 Write property test for toggle completion involution (Property 9)
    - **Property 9: Toggle completion is an involution**
    - **Validates: Requirements 4.4, 4.5**
  - [~] 6.6 Implement inline edit mode: `startEdit()`, `confirmEdit()`, `cancelEdit()`
    - `startEdit` replaces the task title element with a pre-filled `<input>`
    - `confirmEdit` on Enter or save-click: if non-empty, updates title and persists; if empty, restores original
    - `cancelEdit` on Escape: discards changes and restores original title
    - _Requirements: 4.6, 4.7, 4.8, 4.9_

- [ ] 7. Implement QuickLinksWidget
  - [~] 7.1 Implement `normalizeUrl(url)` and `validateLink(label, url)`
    - `normalizeUrl` prepends `https://` if the URL does not already start with `http://` or `https://`
    - `validateLink` returns invalid for empty label, empty URL, label > 100 chars, URL > 2048 chars
    - _Requirements: 5.2, 5.3_
  - [ ]* 7.2 Write property test for URL normalization (Property 11)
    - **Property 11: URL normalization always produces http/https prefix**
    - **Validates: Requirements 5.3**
  - [ ]* 7.3 Write property test for link validation (Property 12)
    - **Property 12: Link validation rejects out-of-bounds inputs**
    - **Validates: Requirements 5.2**
  - [~] 7.4 Implement `QuickLinksWidget.init(links)`, `addLink()`, `deleteLink()`, and `renderLinks()`
    - `addLink` validates label and URL, normalizes URL, enforces 50-link max, persists, re-renders
    - `deleteLink` removes by id, persists, re-renders
    - `renderLinks` builds link buttons that open URLs in a new tab (`target="_blank"`)
    - Display inline validation messages for all rejection cases including max-limit reached
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

- [ ] 8. Implement ThemeManager
  - [~] 8.1 Implement `ThemeManager.init(savedTheme)`, `toggle()`, `apply(theme)`, and `current()`
    - `apply` sets `data-theme` attribute on `<body>` to `"light"` or `"dark"`
    - `toggle` flips the current theme, calls `apply`, persists to `StorageService`, updates toggle control label/icon
    - `init` reads saved theme (default `"light"`) and calls `apply`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

- [ ] 9. Wire everything together in `app.js`
  - [~] 9.1 Implement the top-level `init()` function
    - Call `StorageService.loadAll()` to get `AppState`
    - Initialize all widgets in order: `ThemeManager`, `GreetingWidget`, `FocusTimerWidget`, `TaskListWidget`, `QuickLinksWidget`
    - Implement the non-blocking warning toast banner shown when `StorageService.set()` returns `false`
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [~] 10. Final checkpoint - Ensure all tests pass
  - Run `npx vitest --run` and confirm all tests pass. Ask the user if any questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at logical milestones
- Property tests (fast-check) validate universal correctness properties across random inputs
- Unit tests (Vitest) validate specific examples and boundary values
- The `StorageService` must be implemented before any widget that depends on persistence

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "3.1", "4.1"] },
    { "id": 3, "tasks": ["3.2", "3.3", "3.4", "4.2", "4.3", "6.1"] },
    { "id": 4, "tasks": ["3.5", "4.4", "6.2", "6.3", "7.1"] },
    { "id": 5, "tasks": ["3.6", "6.4", "6.5", "7.2", "7.3"] },
    { "id": 6, "tasks": ["6.6", "7.4"] },
    { "id": 7, "tasks": ["8.1"] },
    { "id": 8, "tasks": ["9.1"] }
  ]
}
```