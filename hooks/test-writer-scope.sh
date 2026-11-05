#!/usr/bin/env bash
# PreToolUse(Read|Grep|Write|Edit) for acceptance-test-writer (registered in its
# frontmatter): keep it from reading the implementation and from writing
# anywhere but tests. Glob is allowed: it only lists names.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
case $TOOL in Read | Grep | Write | Edit) ;; *) exit 0 ;; esac
H=test-writer-scope
P=$(field .tool_input.file_path)
[ -n "$P" ] || P=$(field .tool_input.path)
rel=${P#"$PROJECT"/}

test_dir_re='(^|/)(tests?|__tests__|e2e|spec)(/|$)'
doc_dir_re='(^|/)(specs|docs|openspec)(/|$)'

is_test() {
  [[ $1 =~ $test_dir_re ]] && return 0
  case ${1##*/} in test_*.py | *_test.py | *_test.go | *.test.* | *.spec.*) return 0 ;; esac
  return 1
}
is_readable() {
  is_test "$1" && return 0
  [[ $1 =~ $doc_dir_re ]] && return 0
  case ${1##*/} in
  *.md | pyproject.toml | package.json | conftest.py | pytest.ini | setup.cfg | tsconfig*.json | \
    vitest.config.* | jest.config.* | go.mod) return 0 ;;
  esac
  return 1
}

# where: tool + top-level dir only, never the full path.
where() { case $rel in /*) echo "$TOOL outside-project" ;; */*) echo "$TOOL ${rel%%/*}/" ;; *) echo "$TOOL ./" ;; esac; }
ALT="derive the interface from the spec; if it is not specified, write a skipped test whose reason is the open question."
case $TOOL in
Read | Grep)
  if [ -z "$P" ]; then
    block $H reads-implementation "Grep without a path searches the whole repo, including the implementation." \
      "pass a path under tests/, specs/ or docs/. $ALT" "Grep (no path)"
  fi
  if ! is_readable "$rel"; then
    block $H reads-implementation "$TOOL on '$rel' would read implementation code." "$ALT" "$(where)"
  fi
  ;;
Write | Edit)
  if ! is_test "$rel"; then
    block $H writes-outside-tests "$TOOL on '$rel' is outside the test directories." \
      "write only test files (tests/, test_*.py, *.test.ts, *_test.go, ...)." "$(where)"
  fi
  ;;
esac
exit 0
