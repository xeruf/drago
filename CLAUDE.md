# drago — drag and drop files out of the macOS terminal

Native AppKit CLI (Swift Package, no dependencies), a GTK-free counterpart to dragon/ripdrag.
Read `README.md` before changing flags or behavior — it is the user-facing contract.

## Commands

```sh
swift build                                   # dev build → .build/debug/drago
swift build 2>&1 | grep -E 'error|warning'    # lint gate — must be clean before every commit
swift test                                    # full suite
swift test --filter OptionsTests/testResolve  # single test
```

## Commit & release rules   ← UNIVERSAL

- **Commit incrementally and atomically** —
  one cohesive change per commit, never bundle unrelated changes or defer commits into one late batch.
- **Every commit green**: lint + tests clean before each commit, not just at session end.
- **Conventional Commits** (`feat:`, `fix:`, `test:`, `docs:`, `chore:` …).
- Keep `README.md` / `docs/` in step with behavior changes in the same series.
- **`CHANGELOG.md` is curated, not per-commit**:
  user-observable deltas only, grouped by version, curated at bump time.
- **Version bumps** (pre-1.0 `0.x`, breaking → minor):
  propose after a major change or once small ones pile up; never bump silently mid-feature.

## Code standards   ← UNIVERSAL

- Max ~300 lines per file; split at natural boundaries. Modularity over bloat.
- Comments only for non-obvious constraints;
  side-effectful effects get a one-line `// why:` (trigger + observable result).
- **Semantic linebreaks** in Markdown/docs: one clause per line.
- Tests: behavior over implementation detail;
  extract pure logic so it's testable without the framework.

## Working with subagents & tools   ← UNIVERSAL

- Offload research and large implementations to subagents rather than crowding one session:
  a **Sonnet** subagent for scoped research or mechanical work,
  an **Opus** subagent for design-heavy or cross-cutting implementation.
  Hand each the full spec + the relevant `docs/` pointer.
- For "where does X live" questions, prefer a code-graph tool over growing Architecture below.
- Large mechanical refactors go through a codemod
  (jscodeshift / ts-morph / `gofmt -r`), not hand edits —
  write it, run it, review the diff.

## Architecture

- `Sources/DragoCore/` — pure logic: option parsing (`Options.swift`), path/URL resolution, output formatting. No AppKit, unit-tested.
- `Sources/drago/` — AppKit shell: `main.swift` (CLI entry), `AppDelegate.swift` (window), `DragItemView.swift` (drag source), `DropTargetView.swift` (drop target).

## Invariants (do not "simplify" away)

- Short flags stay compatible with dragon's where they overlap (`-x -a -A -t -k -p -T -i -I`) — users alias one wrapper across Linux and macOS.
- stdout carries only dropped/dragged paths, one per line, line-buffered — it is meant to be piped; messages go to stderr.
- The window floats by default (`-N` opts out) — at normal level it disappears behind the terminal once that is focused.
- `DragItemView.acceptsFirstMouse` returns true — otherwise the first click only focuses the window and the drag never starts.
- Drop handling defers `onDone` to the next runloop turn so the source app receives the accepted drop before we terminate.

## Extended docs   ← UNIVERSAL convention

- Decisions, rationale, and major turning points live in `docs/`, not inline; this file points.
- **One fact, one home**: each topic owned by exactly one doc;
  narrative docs (history, status, plans) link into it, never restate it.
- **Delete plan docs once shipped** — don't leave a stale third copy.
- Before editing any `.md` file, read its first three lines — heading, scope, neighbors — keep them true in the same edit,
  put what the scope excludes where the neighbors point, and keep file-describing prose to those lines.
