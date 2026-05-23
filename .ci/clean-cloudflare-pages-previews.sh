#!/bin/bash

set -euo pipefail

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Required command '$1' is not installed or not on PATH."
		exit 1
	fi
}

require_var() {
	local name="$1"
	if [ -z "${!name:-}" ]; then
		echo "Environment variable $name is required."
		exit 1
	fi
}

require_command python3
require_command curl
require_command jq
require_command grep
require_command sed
require_command tr

if [ "${GITHUB_EVENT_NAME:-}" = "delete" ]; then
	if [ "${GITHUB_REF_TYPE:-}" != "branch" ]; then
		echo "Skipping clean up: delete event is not a branch delete (ref_type=${GITHUB_REF_TYPE:-})."
		exit 0
	fi
	branch_name="${GITHUB_REF_NAME:-}"
else
	if [ -z "${MANUAL_BRANCH:-}" ]; then
		echo 'MANUAL_BRANCH is required for manual cleanup when GITHUB_EVENT_NAME is not "delete".'
		exit 1
	fi
	branch_name="${MANUAL_BRANCH}"
fi

if [ -z "${branch_name:-}" ]; then
	echo "Branch name is required for manual cleanup."
	exit 1
fi

require_var GITHUB_TOKEN
require_var GITHUB_REPOSITORY
require_var CLOUDFLARE_PROJECT_NAME
require_var CLOUDFLARE_ACCOUNT_ID
require_var CLOUDFLARE_API_TOKEN

project_name="${CLOUDFLARE_PROJECT_NAME}"
account_id="${CLOUDFLARE_ACCOUNT_ID}"
api_token="${CLOUDFLARE_API_TOKEN}"
github_repo="${GITHUB_REPOSITORY}"
owner="${github_repo%%/*}"
repo="${github_repo##*/}"

encoded_project_name="$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "${project_name}")"
encoded_env="$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "${project_name} (Preview)")"
encoded_branch="$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "${branch_name}")"

echo "Cleaning Cloudflare Pages preview deployments for branch: ${branch_name}"
echo "Cloudflare Pages project: ${project_name}"
echo "Environment: ${project_name} (Preview)"

github_deployments_json="$(curl -sS -H "Authorization: Bearer ${GITHUB_TOKEN}" \
	-H "Accept: application/vnd.github+json" \
	"https://api.github.com/repos/${owner}/${repo}/deployments?environment=${encoded_env}&ref=${encoded_branch}")"

if ! jq -e . > /dev/null <<< "${github_deployments_json}"; then
	echo "GitHub deployments query returned invalid JSON:"
	echo "${github_deployments_json}"
	exit 1
fi

if ! jq -e 'type == "array"' > /dev/null <<< "${github_deployments_json}"; then
	echo "GitHub deployments query returned unexpected JSON payload:"
	echo "${github_deployments_json}"
	exit 1
fi

mapfile -t deployment_ids < <(jq -r '.[].id // empty' <<< "${github_deployments_json}")
if [ "${#deployment_ids[@]}" -eq 0 ]; then
	echo "No GitHub deployments found for environment ${project_name} (Preview)."
fi

declare -A url_to_deploy_id=()
for deployment_id in "${deployment_ids[@]}"; do
	status_json="$(curl -sS -H "Authorization: Bearer ${GITHUB_TOKEN}" \
		-H "Accept: application/vnd.github+json" \
		"https://api.github.com/repos/${owner}/${repo}/deployments/${deployment_id}/statuses")"

	environment_url=$(jq -r '.[0].environment_url // empty' <<< "${status_json}")
	if [ -n "${environment_url}" ]; then
		url_to_deploy_id["${environment_url}"]="${deployment_id}"
	fi
done

cf_endpoint="https://api.cloudflare.com/client/v4/accounts/${account_id}/pages/projects/${encoded_project_name}/deployments"

call_cf_endpoint() {
	local query="$1"
	curl -sS -H "Authorization: Bearer ${api_token}" \
		-H "Content-Type: application/json" \
		"${cf_endpoint}${query}"
}

cf_response="$(call_cf_endpoint "?page=1&per_page=50")"
if ! jq -e . > /dev/null <<< "${cf_response}"; then
	echo "Cloudflare response was invalid JSON:"
	echo "${cf_response}"
	exit 1
fi

if ! jq -e '.success == true' > /dev/null <<< "${cf_response}"; then
	err="$(jq -r 'if type == "object" then .errors[]?.message // .message // empty else empty end' <<< "${cf_response}" | tr '\n' ' ' | sed 's/  */ /g')"
	if printf '%s' "${err}" | grep -qi 'invalid list options'; then
		echo "Cloudflare list query failed with invalid list options; retrying without pagination parameters."
		cf_response="$(call_cf_endpoint "")"
		if ! jq -e . > /dev/null <<< "${cf_response}"; then
			echo "Cloudflare response was invalid JSON after retry:"
			echo "${cf_response}"
			exit 1
		fi
		if ! jq -e '.success == true' > /dev/null <<< "${cf_response}"; then
			echo "Cloudflare API error after retry:"
			jq -r '.errors // empty' <<< "${cf_response}"
			exit 1
		fi
	else
		echo "Cloudflare API error:"
		jq -r '.errors // empty' <<< "${cf_response}"
		exit 1
	fi
fi

if ! jq -e '.result != null' > /dev/null <<< "${cf_response}"; then
	echo "Cloudflare response did not contain deployment results:"
	echo "${cf_response}"
	exit 1
fi

matching_deployments="$(jq -c --arg branch "${branch_name}" '[.result[] | select( ( (.deployment_trigger.metadata.branch // .deployment_trigger.branch // .branch // .environment // "") == $branch ) and ( (.environment == "preview") or (.deployment_trigger.environment == "preview") or (.deployment_trigger.metadata.environment == "preview") or ((.url // "") | test("pages\\.dev$|workers\\.dev$"; "i")) ) )]' <<< "${cf_response}")"
matching_count="$(jq 'length' <<< "${matching_deployments}")"
if [ "${matching_count}" -eq 0 ]; then
	echo "No Cloudflare preview deployments found for branch ${branch_name}."
	exit 0
fi

deleted=0
declare -a deleted_urls=()
while IFS= read -r deployment; do
	url="$(jq -r '.url' <<< "${deployment}")"
	id="$(jq -r '.id' <<< "${deployment}")"
	branch_value="$(jq -r '(.deployment_trigger.metadata.branch // .deployment_trigger.branch // .branch // .environment // "")' <<< "${deployment}")"
	echo "Deleting Cloudflare Pages deployment ${id} for branch '${branch_value}' url=${url}"
	delete_response="$(curl -sS -X DELETE -H "Authorization: Bearer ${api_token}" \
		-H "Content-Type: application/json" \
		"${cf_endpoint}/${id}")"
	if ! jq -e '.success == true' > /dev/null <<< "${delete_response}"; then
		echo "Cloudflare deployment delete failed for id=${id} url=${url}"
		jq -r '.errors // empty' <<< "${delete_response}"
		exit 1
	fi
	deleted=$((deleted + 1))
	deleted_urls+=("${url}")
done < <(jq -c '.[]' <<< "${matching_deployments}")

if [ "${deleted}" -eq 0 ]; then
	echo "No matching Cloudflare preview deployments found to delete."
else
	echo "Deleted ${deleted} Cloudflare preview deployment(s)."
fi

if [ "${#url_to_deploy_id[@]}" -gt 0 ]; then
	for url in "${deleted_urls[@]}"; do
		github_id="${url_to_deploy_id[$url]:-}"
		if [ -n "${github_id}" ]; then
			echo "Marking GitHub deployment ${github_id} INACTIVE for ${url}"
			curl -sS -X POST -H "Authorization: Bearer ${GITHUB_TOKEN}" \
				-H "Accept: application/vnd.github+json" \
				-H "Content-Type: application/json" \
				-d '{"state":"inactive","environment_url":"","log_url":""}' \
				"https://api.github.com/repos/${owner}/${repo}/deployments/${github_id}/statuses"
		fi
	done
fi
