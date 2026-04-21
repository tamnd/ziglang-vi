#!/usr/bin/env bash
set -euo pipefail

# Rewrites absolute URLs (/foo) in built HTML/CSS/XML output so they work
# from a project-site subpath like https://tamnd.github.io/ziglang-vi/.
# Leaves protocol-relative (//cdn) and external (http://) URLs alone.
#
# Usage: rewrite-base.sh <root-dir> <base-path>
#   rewrite-base.sh docs /ziglang-vi

root=${1:?root dir required}
base=${2:?base path required}
base=${base%/}

if ! [ -d "$root" ]; then
  echo "rewrite-base: $root does not exist" >&2
  exit 1
fi

# HTML, XML, and plain text (sitemaps etc.)
while IFS= read -r -d '' f; do
  perl -i -pe '
    s{(\b(?:href|src|action|poster|data-src|content)\s*=\s*")/(?!/)}{$1'"$base"'/}g;
    s{(\b(?:href|src|action|poster|data-src|content)\s*=\s*\x27)/(?!/)}{$1'"$base"'/}g;
  ' "$f"
done < <(find "$root" \( -name '*.html' -o -name '*.xml' -o -name '*.txt' \) -type f -print0)

# CSS: url(/...), url("/..."), url('/...')
while IFS= read -r -d '' f; do
  perl -i -pe '
    s{url\(\s*/(?!/)}{url('"$base"'/}g;
    s{url\(\s*"/(?!/)}{url("'"$base"'/}g;
    s{url\(\s*\x27/(?!/)}{url(\x27'"$base"'/}g;
  ' "$f"
done < <(find "$root" -name '*.css' -type f -print0)

echo "rewrite-base: rewrote absolute URLs under $root to prefix $base"
