# Vietnamese Translation Roadmap

This document is the working plan for translating [ziglang.org](https://ziglang.org/)
into Vietnamese (`vi-VN`). It describes the scope, phases, conventions, and
upstream-sync policy. Project-level docs (this file, `README.md`, PR bodies,
issues, commits) are written in English; only content shipped to readers of the
site is in Vietnamese.

## 1. Upstream & Pinning

- **Upstream:** https://codeberg.org/ziglang/ziglang.org
- **Site generator:** [Zine](https://zine-ssg.io) (multilingual static site)
- **Initial pin:** `6f3e0a1be4d51958be45bf36926112634cf3d0a8` (2026-04-20,
  `fix code sample`).

The initial commit (`Import source from ziglang/ziglang.org@6f3e0a1`) mirrors
the upstream working tree verbatim at the pin above. All subsequent commits are
either (a) translation work on top of that tree, or (b) a re-sync commit that
bumps the pin and replays the translation on the new upstream tree.

## 2. Goals & Non-Goals

**Goals**

- Ship a complete `vi-VN` locale that Zine builds alongside the upstream locales.
- Match the upstream site structure so Vietnamese readers land on equivalent URLs.
- Stay mergeable with upstream: prefer additions under `content/vi-VN/` and a
  single `i18n/vi-VN.ziggy` file, with a minimal diff to `zine.ziggy`.
- Keep the translation terminology consistent through a project glossary.

**Non-Goals**

- Do **not** translate `devlog/` and `news/` entries — upstream explicitly
  excludes them from translation (see `README.md` §"Writing a Translation").
- Do **not** translate inline Zig code, CLI output, identifiers, or file paths
  inside `.smd` code fences.
- Do **not** fork the Zine build system; we ship content, not tooling.
- Do **not** propose upstream changes from this repo. Fixes to upstream
  (typos, broken samples, build issues) are filed separately on Codeberg.

## 3. Repository Layout (delta vs. upstream)

Files that get added or changed in this repo relative to upstream:

| Path                          | Change        | Notes                                     |
|-------------------------------|---------------|-------------------------------------------|
| `content/vi-VN/`              | **add**       | Vietnamese copies of translatable `.smd`. |
| `i18n/vi-VN.ziggy`            | **add**       | Translated phrase map (mirrors `en-US`).  |
| `zine.ziggy`                  | **modify**    | Add one entry under `.locales = [ ... ]`. |
| `ROADMAP.md`                  | **add**       | This file.                                |
| `GLOSSARY.md`                 | **add**       | English → Vietnamese term table.          |
| `TRANSLATE.md`                | **add**       | Step-by-step guide for contributors.      |
| `README.md`                   | **modify**    | Prepend a short vi-VN section + upstream link. |

Everything else (`layouts/`, `assets/`, `build.zig`, `src/`, `zig-code/`, etc.)
stays byte-identical to upstream so we can fast-forward during sync.

## 4. Translation Scope

Inventory of English source files under `content/en-US/` and an initial
priority tier. Line counts are from the pinned tree.

### Tier 1 — Landing experience (must translate)

| File                                     | Lines | Notes                              |
|------------------------------------------|------:|------------------------------------|
| `content/en-US/index.smd`                |    61 | Front page slogan + features grid. |
| `content/en-US/download.smd`             |    23 | Download page frontmatter.         |
| `content/en-US/learn/index.smd`          |    52 | Learn hub.                         |
| `i18n/en-US.ziggy`                       |    ~24 keys | Phrases used across layouts.  |

### Tier 2 — Learn track (the bulk of reader value)

| File                                        | Lines |
|---------------------------------------------|------:|
| `content/en-US/learn/getting-started.smd`   |   157 |
| `content/en-US/learn/samples.smd`           |    48 |
| `content/en-US/learn/tools.smd`             |    41 |
| `content/en-US/learn/why_zig_rust_d_cpp.smd`|   158 |
| `content/en-US/learn/overview.smd`          |   670 |
| `content/en-US/learn/build-system.smd`      |   466 |

### Tier 3 — Community & governance

| File                                         | Lines |
|----------------------------------------------|------:|
| `content/en-US/community.smd`                |   251 |
| `content/en-US/code-of-conduct.smd`          |   100 |
| `content/en-US/zsf.smd`                      |    84 |
| `content/en-US/download/community-mirrors.smd` | 114 |

### Out of scope

- `content/en-US/devlog/` (per upstream rule).
- `content/en-US/news/` (per upstream rule).
- `src/documentation/*` — the language reference is tracked and released
  separately by `ziglang/zig`; website doesn't own its text.

**Total translatable content:** ~2,225 lines of `.smd` + ~24 `i18n` keys across
**12 files** — a tractable body of work for a small team.

## 5. Phase Plan

Each phase lands as one or more PRs against `main`. Merging Tier N does not
block starting Tier N+1, but reviews prefer the order below so that readers
landing on the home page always see a coherent experience.

### Phase 0 — Scaffolding (this PR and the next)

- [ ] Land `ROADMAP.md` (this PR).
- [ ] Add `GLOSSARY.md` seed (~30 terms: *comptime*, *allocator*, *build
      system*, *standard library*, *toolchain*, *target*, *cross-compilation*,
      *error union*, *tagged union*, *coroutine*, …).
- [ ] Add `TRANSLATE.md` (local preview, frontmatter rules, PR checklist).
- [ ] Register `vi-VN` in `zine.ziggy` with a stub `content/vi-VN/index.smd` so
      the site builds with the new locale from day one.
- [ ] Copy `i18n/en-US.ziggy` → `i18n/vi-VN.ziggy` and translate the 24 keys.

### Phase 1 — Tier 1 content

- [ ] Translate `index.smd` (slogan, three feature blocks, CTA buttons).
- [ ] Translate `download.smd` frontmatter.
- [ ] Translate `learn/index.smd`.

### Phase 2 — Tier 2 Learn track

- [ ] `getting-started.smd`
- [ ] `samples.smd`, `tools.smd`
- [ ] `why_zig_rust_d_cpp.smd`
- [ ] `overview.smd` (split into sub-PRs by top-level `##` section — ~6 PRs).
- [ ] `build-system.smd` (split similarly — ~5 PRs).

### Phase 3 — Tier 3 Community

- [ ] `community.smd`, `code-of-conduct.smd`, `zsf.smd`,
      `download/community-mirrors.smd`.

### Phase 4 — Review pass

- [ ] Full read-through of every Vietnamese page against the English source.
- [ ] Terminology sweep against `GLOSSARY.md` (automated grep where possible).
- [ ] Typography pass: curly quotes, non-breaking spaces before units, em-dash
      vs hyphen.

### Phase 5 — Upstream inclusion (stretch)

- [ ] Once the translation is stable and reviewed, propose upstream adoption
      via a PR to `codeberg.org/ziglang/ziglang.org` that adds the `vi-VN`
      locale. This repo then becomes a staging ground for future updates.

## 6. Translation Conventions

### 6.1 File-level rules

- Every translated `.smd` keeps the **same filename and path** under
  `content/vi-VN/` as its English counterpart under `content/en-US/`.
- Frontmatter keys (`.title`, `.layout`, `.date`, `.author`, `.custom`) stay
  in English; only the **string values** that render to readers get translated.
- Do not change `.date` on translation — that field tracks upstream publication.

### 6.2 What to translate vs. leave alone

Translate:
- Prose, headings, list items, table headers, image alt text.
- Button labels, navigation labels, menu titles (including
  `custom.mobile_menu_title`).
- Phrase keys in `i18n/vi-VN.ziggy`.

Leave alone:
- Code inside fenced blocks ```` ``` ```` (any language).
- CLI commands, shell output, file paths, environment variables.
- Identifiers that appear inline as `code spans`.
- URLs and anchor fragments.
- Zine template tags (`[]($section.id("…"))`, `[]($link.…)`, etc.).

### 6.3 Tone & register

- **Voice:** informative, neutral, technical. Avoid marketing fluff even where
  the English source is playful — Vietnamese technical writing prefers
  clarity over cleverness.
- **Pronoun / address:** no second-person pronoun in prose (rewrite "you can
  …" as "có thể …" or passive). Use "chúng ta" only when the English text is
  explicitly inclusive ("we", "let's").
- **Anglicisms:** keep widely-used English terms (Zig, compiler, build,
  toolchain, kernel) untranslated on first reference; gloss once in
  parentheses if the Vietnamese equivalent is stable (see `GLOSSARY.md`).

### 6.4 Typography

- Use curly quotes `"…"` and `'…'` in prose (not `"…"` or `'…'`).
- Use em-dash `—` (U+2014) for parenthetical breaks; never ` - ` in prose.
- Non-breaking space (U+00A0) between a number and its unit (`8 KB`, `2 GB`).
- Keep English punctuation rules (space after comma, no space before `:` `;`).

## 7. Tooling & Local Preview

The site builds with Zine; no changes to the build pipeline are expected.

```
zig build serve
```

Translators should `zig build serve` and browse
`http://localhost:<port>/vi-VN/` before opening a PR to confirm the
Vietnamese pages render without breaking the layout. Spatial constraints on
the front page (buttons, feature cards) are the most common failure mode —
shorten or reword the Vietnamese text rather than editing layouts.

Minimum Zig version tracks whatever upstream `build.zig.zon` requires at the
current pin; do not bump it here.

## 8. Upstream Sync Policy

**Cadence:** re-sync with upstream after each Zig release (roughly quarterly),
plus an ad-hoc sync when upstream makes structural changes (new content file,
renamed layout, new phrase in `i18n/`).

**Procedure:**

1. Rebase or merge upstream `main` into `main` of this repo. Prefer merge to
   preserve pinned-commit history.
2. For each new or changed English `.smd` under `content/en-US/`, open a
   translation-update PR in the same phase where that file lives.
3. For each new key in `i18n/en-US.ziggy`, add the Vietnamese counterpart to
   `i18n/vi-VN.ziggy` in the sync PR itself (a stub site is worse than a
   reviewed translation).
4. Update the "Initial pin" line in §1 to the new upstream hash and the
   `CHANGELOG` section below.

**Conflict handling:** if upstream renames or deletes a translated file,
delete the `vi-VN` counterpart in the same commit; keeping stale translations
is worse than a missing page (Zine falls back to the English version).

## 9. Contribution Process

- One tier-scoped PR at a time; avoid "translate 3 unrelated files" PRs.
- PR title: `vi-VN: translate <path>` (e.g. `vi-VN: translate learn/samples.smd`).
- PR body: link the English source, note any terminology choices that could
  be controversial, and flag anything that did not fit the existing layout.
- Reviews require at least one Vietnamese-reading reviewer. Silence for a
  week on a PR = ping on the issue tracker.
- Commits on translation branches are atomic per file when practical.

## 10. Open Questions

These are unresolved and will be decided as the work progresses. Listed here
so future contributors don't re-open settled questions silently.

1. **Zig-specific jargon:** do we translate `comptime`, `build.zig`, `zon`?
   Tentative answer: no for the keyword, yes for the concept in prose
   (*thời-gian-biên-dịch* as a gloss).
2. **Language-reference link:** the Learn section points at
   `ziglang.org/documentation/master/` — that document isn't translated.
   Should Vietnamese pages link to the English reference with a note, or
   keep the link and let readers discover the gap? Tentative: link + note.
3. **Date format:** upstream uses ISO-like `2024-08-07`; Vietnamese
   convention is `07/08/2024`. Tentative: keep ISO to match frontmatter and
   avoid locale-dependent layouts.
4. **Name of the host project:** "Zig Programming Language" →
   "Ngôn ngữ lập trình Zig" (confirmed by other locales' pattern) —
   entered as `site_title` in `zine.ziggy`.

## 11. Changelog

- *2026-04-21* — Roadmap drafted. Pinned upstream at `6f3e0a1`.
