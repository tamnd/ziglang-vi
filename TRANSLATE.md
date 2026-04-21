# How to Contribute a Translation

Step-by-step guide for translating pages into Vietnamese (`vi-VN`). Read
[ROADMAP.md](ROADMAP.md) first — it defines what's in scope and the phase
order. Use [GLOSSARY.md](GLOSSARY.md) for terminology.

## 1. Prerequisites

- A Zig toolchain matching upstream's requirement (`build.zig.zon` pins the
  minimum). The simplest way to juggle versions is
  [anyzig](https://github.com/marler8997/anyzig) or
  [zigup](https://github.com/marler8997/zigup).
- System packages for running code samples in the learn section: `tar`,
  `zlib`, `jq`.
- Editor support for Zine's templating language is optional but
  recommended — see the [Zine editor docs](https://zine-ssg.io/docs/editors/).

You do **not** need to install GPG or anything else site-specific. The site
is built entirely by `zig build`.

## 2. Local preview

From the repo root:

```
zig build serve
```

Open the printed URL, then browse `/vi-VN/` to see Vietnamese pages. The
server hot-reloads on file changes.

If a page 404s in Vietnamese but works in English, the file either (a)
doesn't exist under `content/vi-VN/` yet — Zine falls back to `en-US` — or
(b) has a syntax error in frontmatter. Zine's CLI prints the exact line.

## 3. What to translate

The authoritative list is [ROADMAP.md §4](ROADMAP.md#4-translation-scope).
At a high level:

- ✅ `content/en-US/*.smd` (top-level pages) → mirror under `content/vi-VN/`.
- ✅ `content/en-US/learn/*.smd` → mirror under `content/vi-VN/learn/`.
- ✅ `i18n/en-US.ziggy` → create `i18n/vi-VN.ziggy` with the same keys.
- ❌ `content/en-US/devlog/` — do not translate (upstream rule).
- ❌ `content/en-US/news/` — do not translate (upstream rule).
- ❌ `layouts/`, `assets/`, `build.zig`, `src/`, `zig-code/`, `zine.ziggy`
  (except the one locale entry) — leave alone so upstream sync stays clean.

## 4. Anatomy of a translated `.smd` file

Every `.smd` has a Ziggy frontmatter block between `---` markers, then
Markdown-like prose (Supermarkdown). Translate the **string values** in
frontmatter and the prose body; leave **keys, dates, layout names, and code
blocks** alone.

### 4.1 Frontmatter rules

```diff
 ---
-.title = "Home",
+.title = "Trang chủ",
 .author = "",
 .date = @date("2024-08-07:00:00:00"),
 .layout = "index.shtml",
 .custom = {
-    "mobile_menu_title": "Home",
+    "mobile_menu_title": "Trang chủ",
 },
 ---
```

- `.title`, `.custom.mobile_menu_title`: translate.
- `.author`: leave as upstream wrote it.
- `.date`: **never change**. It tracks upstream publication so the news/learn
  index can sort consistently across locales.
- `.layout`: never change. These are template file names.
- `.custom.OSs` (on `download.smd`) and any other arrays of platform tokens:
  leave as-is — they're machine keys, not prose.

### 4.2 Body rules

Translate:
- Prose, headings (`##`), list items, table headers/cells.
- Image `alt` text: `![alt here](/img/foo.svg)`.
- Link text: `[link text](url)` — translate the text, keep the URL.

Do **not** translate:
- Fenced code blocks of any language (`` ``` ``, `` ```zig ``, `` ```console ``).
- Inline `code spans` for identifiers, file paths, flags.
- Zine template directives such as `[]($section.id("slogan"))`,
  `[]($link.page("learn"))` — the argument string is a key, not text.
- URLs and `#anchor` fragments inside links.

### 4.3 Tone

- Neutral, informative. If the English text is playful ("⚡ Maintain it with
  Zig"), keep the emoji but render the heading in plain Vietnamese.
- No "you / your" pronouns in prose. Rewrite "you can" as "có thể" (subject
  implied) or passive. Use "chúng ta" only when the English is explicitly
  inclusive.
- Keep the English term on first use for widely-untranslated jargon
  (`comptime`, `allocator`, `toolchain`); consult GLOSSARY.md.

## 5. Translating `i18n/vi-VN.ziggy`

The phrase map powers labels that appear across layouts (navigation, buttons,
footers). First time:

```
cp i18n/en-US.ziggy i18n/vi-VN.ziggy
```

Then translate each value in place. Keys must match `en-US` exactly — don't
rename, add, or delete keys; that is upstream's job.

```diff
-.get_started = "GET STARTED",
+.get_started = "BẮT ĐẦU",
```

Keep the capitalization pattern from the English source (ALL CAPS stays
upper-cased; Title Case stays title-cased). When Vietnamese text is
meaningfully longer than the English and risks breaking the layout, prefer
a shorter rewrite over editing the CSS.

## 6. Registering a new locale (once, already done in Phase 0)

`zine.ziggy` has a `.locales = [ ... ]` array. Vietnamese is added as:

```ziggy
{
    .code = "vi-VN",
    .name = "Tiếng Việt",
    .site_title = "Ngôn ngữ lập trình Zig",
    .content_dir_path = "content/vi-VN",
},
```

Do not touch the `en-US` entry's `.output_prefix_override = ""` — that is
what keeps the English site at `/` instead of `/en-US/`.

## 7. PR conventions

- **Branch name**: `vi-<file-basename>` (e.g. `vi-samples`, `vi-overview-p1`).
- **Title**: `vi-VN: translate <path>` (e.g.
  `vi-VN: translate learn/samples.smd`).
- **Commits**: atomic per file when practical. Commit message in English,
  subject under 72 chars.
- **Body**: link the English source at the current pin; note any terminology
  choices that deviate from `GLOSSARY.md` and why; flag layout issues.
- **Scope**: one tier-scoped PR at a time — don't bundle `community.smd`
  with `learn/overview.smd`.

### PR checklist

- [ ] `zig build serve` works locally and the new page renders under `/vi-VN/`.
- [ ] Terminology matches `GLOSSARY.md`; new terms added to GLOSSARY in the
      same PR.
- [ ] No edits to `layouts/`, `assets/`, or upstream `content/en-US/`.
- [ ] No changes to `.date` in frontmatter.
- [ ] Code fences and URLs untouched.
- [ ] Long Vietnamese phrases don't overflow buttons / cards on the front page.

## 8. Reviews

Expect at least one Vietnamese-reading reviewer. If a PR sits without a
review for a week, ping the issue tracker. Reviewers should spot-check:

1. Every paragraph has a Vietnamese counterpart (no silent drops).
2. Headings and `mobile_menu_title` match the glossary.
3. Links still point to valid targets (prose translation can accidentally
   break Markdown link syntax).
4. Frontmatter keys and dates are unchanged.

## 9. Upstream sync (for maintainers)

After upstream adds or changes an `.smd` under `content/en-US/`:

1. Merge upstream into `main`. Update the pin in `ROADMAP.md §1` and the
   changelog at the bottom of that file.
2. For each new/changed English file, open a follow-up translation PR in
   the phase where that file lives.
3. For new keys in `i18n/en-US.ziggy`, add Vietnamese values to
   `i18n/vi-VN.ziggy` **inside the sync PR** (a partial phrase map is worse
   than a reviewed translation).
4. If upstream renames or deletes a translated file, delete the `vi-VN`
   counterpart in the same commit.

Re-syncs should not rewrite history on `main`; use merge commits so the
pinned-commit trail stays readable.
