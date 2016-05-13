#!/bin/bash
set -e
[ -z "$FERRIS_BUELLER_ROOT" -a -d ferris-bueller -a -f ferris-bueller.sh ] && FERRIS_BUELLER_ROOT=ferris-bueller
FERRIS_BUELLER_ROOT=${FERRIS_BUELLER_ROOT:-/opt/ferris-bueller}
export BUNDLE_GEMFILE="$FERRIS_BUELLER_ROOT/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG
exec "$FERRIS_BUELLER_ROOT/ruby/bin/ruby" -rbundler/setup "$FERRIS_BUELLER_ROOT/bin/ferris-bueller" $@