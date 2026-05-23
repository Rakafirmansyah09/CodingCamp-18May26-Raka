$dest = "C:\Users\User\.kiro\CodingCamp-18May26-Raka\.kiro\specs\todo-life-dashboard\design.md"

$content = @'
# Design Document: To-Do Life Dashboard

## Overview

The To-Do Life Dashboard is a client-side single-page application (SPA) built with plain HTML, CSS, and Vanilla JavaScript. It runs entirely in the browser with no build step, no framework, and no backend. All user data is persisted via the browser's `localStorage` API.

The application is structured as a single `index.html` file that loads a stylesheet (`styles.css`) and a JavaScript module (`app.js`). The JS module is organized into discrete widget controllers, a storage service, and a theme manager — all wired together by a top-level `init()` function that runs on `DOMContentLoaded`.

### Key Design Decisions

- **No framework**: Vanilla JS keeps the project dependency-free and maximally portable. DOM manipulation is done with standard `querySelector` / `addEventListener` patterns.
- **Module pattern**: Each widget is encapsulated in its own JS object/module to avoid global state pollution and make unit testing straightforward.
- **Single source of truth in localStorage**: All persistent state is written to `localStorage` immediately on change. On load, the app reads from `localStorage` and falls back to defaults if data is missing or corrupt.
- **CSS custom properties for theming**: Light/dark themes are implemented via a `data-theme` attribute on `<body>` and CSS custom properties, enabling instant theme switching without a page reload.

---

## Architecture

The application follows a simple **widget-based MVC-lite** architecture. There is no virtual DOM or reactive framework — each widget owns its DOM subtree and updates it directly.

```mermaid
graph TD
    A[index.html] --> B[app.js - init]
    B --> C[GreetingWidget]
    B --> D[FocusTimerWidget]
    B --> E[TaskListWidget]
    B --> F[QuickLinksWidget]
    B --> G[ThemeManager]
    B --> H[StorageService]

    C --> H
    D --> H
    E --> H
    F --> H
    G --> H
```

### Initialization Flow

```mermaid
sequenceDiagram
    participant Browser
    participant app.js
    participant StorageService
    participant Widgets

    Browser->>app.js: DOMContentLoaded
    app.js->>StorageService: loadAll()
    StorageService-->>app.js: { userName, tasks, links, pomoDuration, theme }
    app.js->>Widgets: init(data)
    Widgets-->>Browser: Render initial state
    app.js->>GreetingWidget: startClock()
```

---

## Components and Interfaces

### StorageService

Responsible for all `localStorage` reads and writes. Centralizes error handling for storage failures.

```js
StorageService = {
  KEYS: {
    USER_NAME: 'tld_userName',
    TASKS: 'tld_tasks',
    LINKS: 'tld_links',
    POMO_DURATION: 'tld_pomoDuration',
    THEME: 'tld_theme',
  },

  // Returns parsed value or null on failure
  get(key),

  // Writes value as JSON; returns true on success, false on quota/error
  set(key, value),

  // Loads all app state, applying defaults for missing/corrupt keys
  loadAll(),
}
```

If `set()` returns `false`, the calling widget shows a non-blocking warning banner.

---

### GreetingWidget

Manages the clock display and personalized greeting.

```js
GreetingWidget = {
  init(userName),
  startClock(),           // setInterval every 1000ms
  updateClock(),          // updates time/date DOM elements
  updateGreeting(userName),
  getGreetingPhrase(hour), // pure function
  formatTime(date),        // pure function -> "HH:MM:SS"
  formatDate(date),        // pure function -> "Day, DD Month YYYY"
}
```

`getGreetingPhrase`, `formatTime`, and `formatDate` are pure functions with no side effects, making them straightforward to test.

---

### FocusTimerWidget

Manages the Pomodoro countdown timer.

```js
FocusTimerWidget = {
  init(pomoDuration),
  start(),
  stop(),
  reset(),
  tick(),                          // called by setInterval every 1000ms
  formatDisplay(totalSeconds),     // pure -> "MM:SS"
  validateDuration(input),         // pure, returns int 1-60 or null
  saveDuration(minutes),
  onComplete(),                    // plays audio, shows indicator, disables Start
}
```

State held in the widget:
- `remainingSeconds` — current countdown value
- `intervalId` — reference to the active setInterval, or null
- `isRunning` — boolean flag
- `pomoDuration` — configured duration in minutes

---

### TaskListWidget

Manages the to-do task list.

```js
TaskListWidget = {
  init(tasks),
  addTask(title),          // returns null if title invalid
  deleteTask(id),
  toggleComplete(id),
  startEdit(id),
  confirmEdit(id, newTitle),
  cancelEdit(id),
  renderList(),
  validateTitle(title),    // pure
  generateId(),            // returns unique string ID
}
```

---

### QuickLinksWidget

Manages the quick-access links panel.

```js
QuickLinksWidget = {
  init(links),
  addLink(label, url),
  deleteLink(id),
  normalizeUrl(url),       // pure — prepends https:// if needed
  validateLink(label, url), // pure
  renderLinks(),
}
```

---

### ThemeManager

Manages light/dark theme switching.

```js
ThemeManager = {
  init(savedTheme),
  toggle(),
  apply(theme),            // sets data-theme on <body>
  current(),
}
```

---

## Data Models

All data is stored in `localStorage` as JSON strings under namespaced keys.

### AppState (in-memory)

```js
{
  userName: string,       // default: "there"
  tasks: Task[],          // default: []
  links: Link[],          // default: []
  pomoDuration: number,   // minutes, default: 25
  theme: string,          // "light" | "dark", default: "light"
}
```

### Task

```js
{
  id: string,        // unique identifier (e.g. crypto.randomUUID())
  title: string,     // 1-200 characters
  completed: boolean // default: false
}
```

### Link

```js
{
  id: string,    // unique identifier
  label: string, // 1-100 characters
  url: string,   // 1-2048 characters, always starts with http:// or https://
}
```

### LocalStorage Keys

| Key | Type | Default |
|---|---|---|
| `tld_userName` | string | `"there"` |
| `tld_tasks` | Task[] (JSON) | `[]` |
| `tld_links` | Link[] (JSON) | `[]` |
| `tld_pomoDuration` | number (JSON) | `25` |
| `tld_theme` | string (JSON) | `"light"` |

### Validation Rules Summary

| Field | Rule |
|---|---|
| User_Name | 1-50 chars after trim; whitespace-only keeps previous |
| Task title (add) | Non-empty, max 200 chars |
| Task title (edit) | Non-empty saves; empty keeps original |
| Pomodoro duration | Integer 1-60 inclusive |
| Link label | Non-empty, max 100 chars |
| Link URL | Non-empty, max 2048 chars; http/https auto-prepended |
| Links count | Max 50 |

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Time format is always HH:MM:SS

*For any* `Date` object, `GreetingWidget.formatTime(date)` SHALL return a string matching the pattern `HH:MM:SS` where HH is 00-23, MM is 00-59, and SS is 00-59.

**Validates: Requirements 1.1**

### Property 2: Date format is always correct

*For any* `Date` object, `GreetingWidget.formatDate(date)` SHALL return a string in the format `<DayName>, <DD> <MonthName> <YYYY>` using the correct day-of-week name, zero-padded day, full month name, and four-digit year.

**Validates: Requirements 1.2**

### Property 3: Greeting phrase covers all hours

*For any* integer hour in the range 0-23, `GreetingWidget.getGreetingPhrase(hour)` SHALL return exactly one of "Good Morning", "Good Afternoon", "Good Evening", or "Good Night" — with no hour left unclassified.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

### Property 4: Timer display format is always MM:SS

*For any* non-negative integer `totalSeconds` in the range 0 to 3600, `FocusTimerWidget.formatDisplay(totalSeconds)` SHALL return a string matching the pattern `MM:SS` where MM is 00-59 and SS is 00-59.

**Validates: Requirements 3.1**

### Property 5: Duration validation accepts only 1-60

*For any* integer input, `FocusTimerWidget.validateDuration(input)` SHALL return the integer if it is between 1 and 60 inclusive, and SHALL return null for any value outside that range.

**Validates: Requirements 3.8, 3.9**

### Property 6: Adding a valid task grows the list by one

*For any* task list and any non-empty title string of 1-200 characters, calling `TaskListWidget.addTask(title)` SHALL increase the task list length by exactly 1 and the new task SHALL have the provided title and `completed: false`.

**Validates: Requirements 4.1**

### Property 7: Whitespace-only and empty task titles are rejected

*For any* string composed entirely of whitespace characters (including the empty string), `TaskListWidget.validateTitle(title)` SHALL return false, and calling `addTask` with such a title SHALL leave the task list unchanged.

**Validates: Requirements 4.2**

### Property 8: Toggle completion is an involution

*For any* task, toggling its completion status twice SHALL return the task to its original completion state (i.e., `toggle(toggle(task)) == task`).

**Validates: Requirements 4.4, 4.5**

### Property 9: Task persistence round-trip

*For any* array of tasks, serializing the array to localStorage via `StorageService.set` and then reading it back via `StorageService.get` SHALL produce an array that is deeply equal to the original.

**Validates: Requirements 4.3, 7.3**

### Property 10: URL normalization always produces http/https prefix

*For any* URL string, `QuickLinksWidget.normalizeUrl(url)` SHALL return a string that begins with either `"http://"` or `"https://"`. If the input already starts with `"http://"` or `"https://"`, the output SHALL equal the input unchanged.

**Validates: Requirements 5.3**

### Property 11: Link validation rejects out-of-bounds inputs

*For any* label and URL pair, `QuickLinksWidget.validateLink(label, url)` SHALL return invalid if the label is empty, the URL is empty, the label exceeds 100 characters, or the URL exceeds 2048 characters; and SHALL return valid otherwise.

**Validates: Requirements 5.2**

### Property 12: User name trimming and validation

*For any* string input to the name field, the system SHALL trim leading and trailing whitespace before validation. If the trimmed result is between 1 and 50 characters, it SHALL be accepted. If the trimmed result is empty (whitespace-only input), the previous name SHALL be retained unchanged.

**Validates: Requirements 2.6, 2.7**

---

## Error Handling

### localStorage Failures

- All `localStorage.setItem` calls are wrapped in try/catch.
- On failure (e.g., `QuotaExceededError`), `StorageService.set()` returns `false`.
- The calling widget checks the return value and, if `false`, displays a non-blocking warning banner (e.g., a dismissible toast at the top of the page).
- The application continues operating in-memory for the current session.

### Corrupt or Unreadable Data on Load

- `StorageService.get(key)` wraps `JSON.parse` in try/catch.
- On parse failure, it returns `null`.
- `StorageService.loadAll()` treats `null` as "no data" and substitutes the default value for that key.
- No unhandled errors are thrown; the app silently falls back to defaults.

### Input Validation

- All validation is synchronous and happens before any state mutation.
- Invalid inputs display inline validation messages adjacent to the relevant input field.
- Validation messages are cleared on the next valid submission attempt.

### Timer Edge Cases

- If the timer reaches 00:00, the Start button is disabled until Reset is clicked.
- The `tick()` function guards against going below 0 seconds.

---

## Testing Strategy

### Unit Tests (Vitest or Jest)

Unit tests focus on the pure functions and stateless logic in each widget. These are fast, deterministic, and do not require a DOM.

**GreetingWidget**
- `formatTime`: specific examples for midnight, noon, single-digit hours/minutes/seconds
- `formatDate`: specific examples for known dates
- `getGreetingPhrase`: boundary values at 5, 12, 18, 22, 0, 4

**FocusTimerWidget**
- `formatDisplay`: 0 seconds, 59 seconds, 60 seconds, 3600 seconds
- `validateDuration`: boundary values 0, 1, 60, 61, non-integer strings, negative numbers

**TaskListWidget**
- `validateTitle`: empty string, whitespace-only, 1 char, 200 chars, 201 chars

**QuickLinksWidget**
- `normalizeUrl`: already-prefixed URLs, bare domains, empty string
- `validateLink`: all boundary combinations of label/URL length

**StorageService**
- `loadAll` with no data → returns all defaults
- `loadAll` with corrupt JSON → returns defaults for that key, keeps valid keys

### Property-Based Tests (fast-check)

Property-based tests use [fast-check](https://github.com/dubzzz/fast-check) to generate random inputs and verify universal properties. Each test runs a minimum of 100 iterations.

**Property 1: Time format is always HH:MM:SS**
- Generator: arbitrary `Date` objects
- Assertion: output matches `/^\d{2}:\d{2}:\d{2}$/` with valid ranges
- Tag: `Feature: todo-life-dashboard, Property 1: Time format is always HH:MM:SS`

**Property 2: Date format is always correct**
- Generator: arbitrary `Date` objects
- Assertion: output matches expected day/month name pattern
- Tag: `Feature: todo-life-dashboard, Property 2: Date format is always correct`

**Property 3: Greeting phrase covers all hours**
- Generator: integers 0-23
- Assertion: result is one of the four valid phrases, no hour is unclassified
- Tag: `Feature: todo-life-dashboard, Property 3: Greeting phrase covers all hours`

**Property 4: Timer display format is always MM:SS**
- Generator: integers 0-3600
- Assertion: output matches `/^\d{2}:\d{2}$/` with valid ranges
- Tag: `Feature: todo-life-dashboard, Property 4: Timer display format is always MM:SS`

**Property 5: Duration validation accepts only 1-60**
- Generator: arbitrary integers (including out-of-range)
- Assertion: returns integer for 1-60, null otherwise
- Tag: `Feature: todo-life-dashboard, Property 5: Duration validation accepts only 1-60`

**Property 6: Adding a valid task grows the list by one**
- Generator: arbitrary task arrays + non-empty strings (1-200 chars)
- Assertion: list length increases by 1, new task has correct title and completed=false
- Tag: `Feature: todo-life-dashboard, Property 6: Adding a valid task grows the list by one`

**Property 7: Whitespace-only and empty task titles are rejected**
- Generator: strings composed only of whitespace characters
- Assertion: validateTitle returns false, list unchanged
- Tag: `Feature: todo-life-dashboard, Property 7: Whitespace-only and empty task titles are rejected`

**Property 8: Toggle completion is an involution**
- Generator: arbitrary Task objects
- Assertion: double-toggle returns original completed state
- Tag: `Feature: todo-life-dashboard, Property 8: Toggle completion is an involution`

**Property 9: Task persistence round-trip**
- Generator: arbitrary Task arrays
- Assertion: serialize then deserialize produces deeply equal array
- Tag: `Feature: todo-life-dashboard, Property 9: Task persistence round-trip`

**Property 10: URL normalization always produces http/https prefix**
- Generator: arbitrary strings
- Assertion: result starts with http:// or https://; already-prefixed inputs unchanged
- Tag: `Feature: todo-life-dashboard, Property 10: URL normalization always produces http/https prefix`

**Property 11: Link validation rejects out-of-bounds inputs**
- Generator: arbitrary label/URL pairs including boundary lengths
- Assertion: validation result matches expected accept/reject based on rules
- Tag: `Feature: todo-life-dashboard, Property 11: Link validation rejects out-of-bounds inputs`

**Property 12: User name trimming and validation**
- Generator: arbitrary strings including whitespace-padded and whitespace-only strings
- Assertion: trimmed 1-50 char strings accepted; whitespace-only retains previous name
- Tag: `Feature: todo-life-dashboard, Property 12: User name trimming and validation`

### Integration / Manual Tests

- Theme toggle applies CSS changes within 200ms (manual visual check)
- Dashboard loads with no localStorage data → all defaults shown
- Dashboard loads with pre-populated localStorage → all data restored
- localStorage quota exceeded → warning banner shown, app continues
- Cross-browser smoke tests: Chrome, Firefox, Edge, Safari
'@

[System.IO.File]::WriteAllText($dest, $content, [System.Text.Encoding]::UTF8)
Write-Host "Written: $((Get-Item $dest).Length) bytes"
