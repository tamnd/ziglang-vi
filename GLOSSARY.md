# Translation Glossary (en → vi)

Preferred Vietnamese renderings for terms used across `content/vi-VN/` and
`i18n/vi-VN.ziggy`. One row = one decision. When a term is genuinely
ambiguous, the row records both options and a rule for choosing.

**How to use**

- Before coining a new rendering, grep this table and the existing
  `content/vi-VN/` for prior use.
- When you add a term here, also fix prior occurrences in the same PR if the
  decision changes what's already committed.
- Keep the "Keep EN" column honest: if a term is kept untranslated, say *why*
  (proper noun, API name, community idiom) so future reviewers don't
  second-guess it.

## Style notes (apply throughout)

- Proper nouns and product names stay in English: `Zig`, `LLVM`, `Clang`,
  `WebAssembly`, `libc`, `musl`, `glibc`, `GCC`, `Rust`, `C`, `D`, `C++`.
- Command names, flags, and identifiers stay in English and in `code span`:
  `zig build`, `--target`, `comptime`, `@import`, `anyerror`.
- Acronyms keep their English form on first use, with a Vietnamese gloss in
  parentheses if the acronym is not already common in VN tech writing
  (`ABI`, `ISA`, `AOT`, `JIT`, `RAII`).
- Numbers and units use a non-breaking space: `8 KB`, `2 GB`, `10 ms`.
- "1.0", "0.15.1" etc. are version strings — do not localize the decimal.

## Core Zig terms

| English                 | Vietnamese (preferred)               | Keep EN? | Notes                                                           |
|-------------------------|--------------------------------------|----------|-----------------------------------------------------------------|
| Zig                     | Zig                                  | yes      | Product name; never translate.                                  |
| Zig compiler            | trình biên dịch Zig                  |          | "trình biên dịch" preferred over "bộ biên dịch".                |
| toolchain               | bộ công cụ                           |          | Use "toolchain" on first mention when it refers to a named one. |
| build system            | hệ thống build                       |          | Do not translate "build" in `build.zig`, `zig build`, etc.      |
| `build.zig`             | `build.zig`                          | yes      | Always in code span; never translated.                          |
| comptime                | comptime                             | yes      | Keyword — keep. Concept prose: *thời gian biên dịch* as gloss.   |
| runtime                 | runtime                              | yes      | Kept as-is in prose; "thời gian chạy" only for contrast with comptime. |
| allocator               | bộ cấp phát (bộ nhớ)                 |          | Prefer the short form; add "(bộ nhớ)" on first mention per page.|
| memory allocation       | cấp phát bộ nhớ                      |          |                                                                 |
| error union             | error union                          | yes      | Zig-specific type; keep English, gloss once as *hợp-lỗi*.        |
| tagged union            | tagged union                         | yes      | Keep English on first mention.                                  |
| optional (type)         | kiểu optional                        |          |                                                                 |
| slice                   | slice                                | yes      | Zig data structure name; keep English.                          |
| pointer                 | con trỏ                              |          |                                                                 |
| struct                  | struct                               | yes      | Keep English when referring to the language construct.          |
| trait / interface       | interface                            | yes      | Zig has no traits; use "interface" for duck-typed contracts.    |
| target                  | nền tảng đích                        |          | In `--target` flag prose.                                       |
| cross-compilation       | biên dịch chéo                       |          |                                                                 |
| host                    | máy chủ biên dịch                    |          | In cross-compilation context only; otherwise "host".            |
| standard library        | thư viện chuẩn                       |          |                                                                 |
| `std`                   | `std`                                | yes      | Module name; never translated.                                  |
| package manager         | trình quản lý gói                    |          |                                                                 |
| dependency              | dependency                           | yes      | Keep English in tooling prose; "phụ thuộc" only for concept.    |
| release                 | bản phát hành                        |          |                                                                 |
| tagged release          | phiên bản được gắn thẻ               |          |                                                                 |
| source tarball          | tarball mã nguồn                     |          |                                                                 |

## Web / site terms

| English                 | Vietnamese (preferred)               | Keep EN? | Notes                                                           |
|-------------------------|--------------------------------------|----------|-----------------------------------------------------------------|
| Home                    | Trang chủ                            |          | Used as `mobile_menu_title`.                                    |
| Download                | Tải xuống                            |          | Noun form. Verb "to download" → "tải xuống".                   |
| Learn                   | Học                                  |          | Section title; short enough for nav.                            |
| Community               | Cộng đồng                            |          |                                                                 |
| Documentation           | Tài liệu                             |          |                                                                 |
| Release Notes           | Ghi chú phát hành                    |          |                                                                 |
| Language Reference      | Tham chiếu ngôn ngữ                  |          |                                                                 |
| Standard Library Docs   | Tài liệu thư viện chuẩn              |          |                                                                 |
| Source                  | Mã nguồn                             |          | As in "download the source".                                    |
| Get Started             | Bắt đầu                              |          | CTA button; short form.                                         |
| Getting Started         | Bắt đầu với Zig                      |          | Page title; longer form for heading.                            |
| Full overview           | Tổng quan đầy đủ                     |          |                                                                 |
| More code samples       | Xem thêm ví dụ mã                    |          |                                                                 |
| Join a Community        | Tham gia cộng đồng                   |          |                                                                 |
| See all Communities     | Xem tất cả cộng đồng                 |          |                                                                 |
| Learn More              | Tìm hiểu thêm                        |          |                                                                 |
| Latest Release          | Bản phát hành mới nhất               |          |                                                                 |
| Unstable                | Không ổn định                        |          | In version dropdown.                                            |
| Latest Stable           | Bản ổn định mới nhất                 |          |                                                                 |
| ← Back to               | ← Quay lại                           |          | Back-navigation link prefix.                                    |
| This page is also …     | Trang này cũng có các bản dịch sau:  |          | Locale switcher intro.                                          |

## Governance / community

| English                     | Vietnamese (preferred)               | Keep EN? | Notes                                               |
|-----------------------------|--------------------------------------|----------|-----------------------------------------------------|
| Code of Conduct             | Quy tắc ứng xử                       |          |                                                     |
| Zig Software Foundation     | Zig Software Foundation              | yes      | Legal entity name; never translated. Abbrev "ZSF". |
| community mirror            | máy nhân bản cộng đồng               |          | For the download mirror network.                    |
| contributor                 | người đóng góp                       |          |                                                     |
| maintainer                  | người bảo trì                        |          |                                                     |
| sponsor                     | nhà tài trợ                          |          |                                                     |
| donation                    | khoản đóng góp                       |          |                                                     |

## Always keep in English (or code form)

- File paths: `src/`, `lib/`, `build.zig`, `build.zig.zon`, `~/.zig`.
- CLI invocations: `zig init`, `zig build test`, `zig run`, `zig cc`.
- Import strings: `@import("std")`, `@cImport(...)`.
- Built-in function names: `@sizeOf`, `@typeOf`, `@embedFile`, `@compileError`.
- Environment variables: `ZIG_GLOBAL_CACHE_DIR`, `PATH`.
- Platform tokens: `x86_64`, `aarch64`, `linux-gnu`, `windows-msvc`, `macos`.

## Open questions

Unresolved terminology. Resolve in a PR that updates this file.

1. **"safety-checked"** vs **"safe mode"** — do we use "chế độ an toàn" for
   both, or distinguish? Leaning: distinguish ("an toàn được kiểm tra" vs
   "chế độ an toàn").
2. **"undefined behavior"** — "hành vi không xác định" reads well; keep EN
   in parentheses on first use.
3. **"panic"** — leave in English; the VN gloss "dừng đột ngột" is awkward.
4. **"async/await"** — keep English; Zig's semantics differ from VN tech
   writing's usual async/await connotation from JS/C#.
