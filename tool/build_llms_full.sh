#!/usr/bin/env sh
# Regenerates llms-full.txt: a single-file context bundle for AI assistants and
# coding agents (see https://llmstxt.org). Run from the repo root after editing
# README.md, doc/guides/*.md or CHANGELOG.md.
set -eu
cd "$(dirname "$0")/.."
OUT=llms-full.txt
{
  echo "# flutter_passkey_service: full documentation bundle"
  echo
  echo "> Generated on $(date -u +%Y-%m-%d) from README.md, doc/guides/*.md and CHANGELOG.md. Short index: llms.txt. Source: https://github.com/minhtri1401/flutter_passkey_service"
  echo
  for f in README.md doc/guides/error-reference.md doc/guides/server-integration.md doc/guides/troubleshooting.md CHANGELOG.md; do
    echo
    echo "<!-- ===== BEGIN $f ===== -->"
    echo
    cat "$f"
    echo
    echo "<!-- ===== END $f ===== -->"
  done
} > "$OUT"
echo "wrote $OUT ($(wc -c < "$OUT") bytes)"
