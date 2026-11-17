#!/bin/sh
# Runs entrypoint.sh for each kind of ref and checks the env vars it writes.
set -eu
cd "$(dirname "$0")/.."
sha=0123456789abcdef0123456789abcdef01234567
fail=0

check() {
  ref=$1 want_version=$2 want_branch=$3
  env_file=$(mktemp)
  GITHUB_REF=$ref GITHUB_SHA=$sha GITHUB_ENV=$env_file bash entrypoint.sh >/dev/null 2>&1
  got=$(grep -E '^(RELEASE_VERSION|GITOPS_BRANCH)=' "$env_file" | sort | tr '\n' ' ')
  want="GITOPS_BRANCH=$want_branch RELEASE_VERSION=$want_version "
  rm -f "$env_file"
  if [ "$got" = "$want" ]; then echo "ok   $ref"; else echo "FAIL $ref: got '$got', want '$want'"; fail=1; fi
}

check refs/heads/develop          0123456 develop
check refs/heads/feature/x        0123456 develop
check refs/pull/12/merge          0123456 develop
check refs/tags/1.4.0-rc_2        1.4.0-rc_2 homolog
check refs/tags/1.4.0-rc1         1.4.0-rc1 homolog
check refs/tags/1.4.0             1.4.0 release
exit $fail
