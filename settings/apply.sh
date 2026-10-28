#!/usr/bin/env bash
# SPDX-License-Identifier: MIT OR Apache-2.0
#
# Applies the organisation settings declared in this directory. Each JSON file is the body of one
# REST request. Repository settings live with each repository, in its `ci/repo-settings/`.
#
# Only an organisation owner can change these settings, and the gh token needs the admin:org
# scope: `gh auth refresh -h github.com -s admin:org`.
#
# Usage: settings/apply.sh [--apply] [--org <name>]
#
#   Without --apply, it prints each request and changes nothing. With --apply, it sends the
#   requests with `gh api` as the logged-in account, then reads every setting back and fails if
#   one differs from its file. It needs `gh` and `jq`.
#
# Three settings have no API, so an owner sets them by hand on github.com:
# - the avatar: upload profile/media/avatar.png under Settings, Profile;
# - required two-factor authentication: Settings, Authentication security. Enabling it removes
#   every member without 2FA, so first check that this lists nobody:
#       gh api 'orgs/syntropyai-hq/members?filter=2fa_disabled' --jq '.[].login'
# - the pinned repositories on the organisation page.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
apply=false
org="syntropyai-hq"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) apply=true ;;
    --org)
      [ "$#" -ge 2 ] || { echo "error: --org needs a value" >&2; exit 2; }
      org="$2"
      shift
      ;;
    --org=*) org="${1#--org=}" ;;
    -h|--help) sed -n '4,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "error: unknown argument '$1'" >&2; exit 2 ;;
  esac
  shift
done

for tool in gh jq; do
  command -v "$tool" >/dev/null || { echo "error: $tool is not installed" >&2; exit 2; }
done
if ! [[ "$org" =~ ^[A-Za-z0-9-]+$ ]]; then
  echo "error: '$org' is not an organisation name" >&2
  exit 2
fi

api() {
  gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$@"
}

# Sends one request with a body file, or prints it on a dry run. Prints the response on --apply.
send() {
  local method="$1" endpoint="$2" body="$3"
  echo "$method /$endpoint  <- ${body#"$here"/}" >&2
  if [ "$apply" = true ]; then
    api --method "$method" "$endpoint" --input "$body"
  fi
}

# `subset(want; got)`: every field in want has the same value in got. Objects may hold more
# fields, and arrays are compared item by item, so defaults GitHub adds don't count as drift.
# shellcheck disable=SC2016 # $a and $b are jq variables
SUBSET='def subset($a; $b):
  if ($a | type) == "object" then ($b | type) == "object"
    and all($a | to_entries[]; . as $e | subset($e.value; $b[$e.key]))
  elif ($a | type) == "array" then ($b | type) == "array" and ($a | length) == ($b | length)
    and all(range($a | length); . as $i | subset($a[$i]; $b[$i]))
  else $a == $b end;'

# Fails unless every field in the body file matches the GET response.
check() {
  local endpoint="$1" body="$2" got
  got="$(api "$endpoint")"
  if jq -e --slurpfile want "$body" "$SUBSET"' subset($want[0]; .)' \
    <<<"$got" >/dev/null; then
    echo "ok   /$endpoint matches ${body#"$here"/}"
  else
    echo "FAIL /$endpoint differs from ${body#"$here"/}:" >&2
    jq --slurpfile want "$body" "$SUBSET"' . as $got | $want[0] | with_entries(select(subset(.value; $got[.key]) | not))
      | with_entries(.value = {want: .value, got: $got[.key]})' <<<"$got" >&2
    return 1
  fi
}

if [ "$apply" = true ]; then
  echo "Applying the settings in ${here#"$PWD"/} to $org as $(api user --jq .login)."
else
  echo "Dry run for $org: nothing is changed. Pass --apply to send these requests."
fi

# Profile, base permission, member privileges and DCO sign-off on web commits.
send PATCH "orgs/$org" "$here/org.json" >/dev/null

# The Actions policy first: the allow-list can be set only once the policy is `selected`.
# Repositories can narrow this list but not widen it.
send PUT "orgs/$org/actions/permissions" "$here/actions-permissions.json" >/dev/null
send PUT "orgs/$org/actions/permissions/selected-actions" "$here/actions-selected-actions.json" >/dev/null
# The default token for a workflow with no `permissions:` block: read-only, unable to approve.
send PUT "orgs/$org/actions/permissions/workflow" "$here/actions-workflow-permissions.json" >/dev/null

# The security configuration is matched by name: updated if it exists, created if not, then made
# the default for new public repositories. Existing repositories keep their own settings.
config="$here/security-configuration.json"
name="$(jq -r '.name' "$config")"
id=""
if listed="$(api "orgs/$org/code-security/configurations" 2>/dev/null)"; then
  id="$(jq -r --arg name "$name" '[.[] | select(.name == $name) | .id] | first // empty' <<<"$listed")"
elif [ "$apply" = true ]; then
  echo "error: cannot list security configurations; does the token have admin:org?" >&2
  exit 1
fi
if [ -n "$id" ]; then
  send PATCH "orgs/$org/code-security/configurations/$id" "$config" >/dev/null
else
  created="$(send POST "orgs/$org/code-security/configurations" "$config")"
  [ "$apply" = true ] && id="$(jq -r '.id' <<<"$created")"
fi
send PUT "orgs/$org/code-security/configurations/${id:-<id>}/defaults" \
  "$here/security-configuration-defaults.json" >/dev/null

if [ "$apply" = true ]; then
  echo "Checking the result."
  status=0
  check "orgs/$org" "$here/org.json" || status=1
  check "orgs/$org/actions/permissions" "$here/actions-permissions.json" || status=1
  check "orgs/$org/actions/permissions/selected-actions" "$here/actions-selected-actions.json" || status=1
  check "orgs/$org/actions/permissions/workflow" "$here/actions-workflow-permissions.json" || status=1
  check "orgs/$org/code-security/configurations/$id" "$config" || status=1
  want="$(jq -r '.default_for_new_repos' "$here/security-configuration-defaults.json")"
  if api "orgs/$org/code-security/configurations/defaults" | jq -e --argjson id "$id" --arg want "$want" \
    'any(.[]; .configuration.id == $id and .default_for_new_repos == $want)' >/dev/null; then
    echo "ok   security configuration '$name' is the default for new $want repositories"
  else
    echo "FAIL security configuration '$name' is not the default for new $want repositories" >&2
    status=1
  fi
  exit "$status"
fi
