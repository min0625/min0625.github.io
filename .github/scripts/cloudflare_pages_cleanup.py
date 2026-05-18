#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import NoReturn


def fail(message: str) -> NoReturn:
  print(message, file=sys.stderr)
  raise SystemExit(1)


def get_required_env(name: str) -> str:
  value = os.getenv(name, '').strip()
  if not value:
    fail(f'Missing required environment variable: {name}')
  return value


def get_branch_name() -> str:
  event_name = os.getenv('GITHUB_EVENT_NAME', '').strip()

  if event_name == 'workflow_dispatch':
    branch = os.getenv('INPUT_BRANCH', '').strip()
    if not branch:
      fail('Missing required workflow_dispatch input: branch')
    return branch

  event_path = os.getenv('GITHUB_EVENT_PATH', '').strip()
  if not event_path:
    fail('Missing required environment variable: GITHUB_EVENT_PATH')

  with open(event_path, encoding='utf-8') as event_file:
    event = json.load(event_file)

  if event_name == 'delete':
    if event.get('ref_type') != 'branch':
      fail('Delete event did not target a branch.')

    branch = str(event.get('ref', '')).strip()
    if not branch:
      fail('Delete event payload did not include the deleted branch name.')
    return branch

  fail(f'Unsupported event: {event_name}')


def request_json(url: str, method: str, token: str) -> dict[str, object]:
  request = urllib.request.Request(
    url,
    headers={
      'Authorization': f'Bearer {token}',
      'Content-Type': 'application/json',
    },
    method=method,
  )

  try:
    with urllib.request.urlopen(request) as response:
      return json.load(response)
  except urllib.error.HTTPError as error:
    details = error.read().decode('utf-8', errors='replace')
    fail(f'Cloudflare API request failed ({error.code}): {details}')
  except urllib.error.URLError as error:
    fail(f'Cloudflare API request failed: {error.reason}')


def list_branch_deployment_ids(
  account_id: str,
  project: str,
  token: str,
  branch: str,
) -> list[str]:
  deployment_ids: list[str] = []
  page = 1
  per_page = 100

  while True:
    query = urllib.parse.urlencode({'page': page, 'per_page': per_page})
    url = (
      'https://api.cloudflare.com/client/v4/accounts/'
      f'{account_id}/pages/projects/{project}/deployments?{query}'
    )
    response = request_json(url, 'GET', token)

    if response.get('success') is not True:
      fail(f"Failed to list deployments: {json.dumps(response.get('errors', []))}")

    result = response.get('result', [])
    if not isinstance(result, list):
      fail('Cloudflare API returned an unexpected deployments response.')

    for deployment in result:
      if not isinstance(deployment, dict):
        continue

      metadata = deployment.get('deployment_trigger', {})
      if isinstance(metadata, dict):
        metadata = metadata.get('metadata', {})

      if (
        isinstance(metadata, dict)
        and metadata.get('branch') == branch
        and isinstance(deployment.get('id'), str)
      ):
        deployment_ids.append(deployment['id'])

    result_info = response.get('result_info', {})
    if not isinstance(result_info, dict):
      break

    total_pages = result_info.get('total_pages')
    if isinstance(total_pages, int) and page >= total_pages:
      break

    if len(result) < per_page:
      break

    page += 1

  return deployment_ids


def delete_deployment_ids(
  account_id: str,
  project: str,
  token: str,
  deployment_ids: list[str],
) -> int:
  failed = 0

  for deployment_id in deployment_ids:
    url = (
      'https://api.cloudflare.com/client/v4/accounts/'
      f'{account_id}/pages/projects/{project}/deployments/'
      f'{deployment_id}?force=true'
    )
    response = request_json(url, 'DELETE', token)

    if response.get('success') is True:
      print(f'Deleted deployment: {deployment_id}')
      continue

    print(
      f"Failed to delete deployment {deployment_id}: "
      f"{json.dumps(response.get('errors', []))}",
      file=sys.stderr,
    )
    failed += 1

  return failed


def main() -> None:
  account_id = get_required_env('CF_ACCOUNT_ID')
  api_token = get_required_env('CF_API_TOKEN')
  project = get_required_env('CF_PROJECT')
  branch = get_branch_name()

  print(f'Cleaning up Cloudflare Pages deployments for branch: {branch}')

  deployment_ids = list_branch_deployment_ids(
    account_id=account_id,
    project=project,
    token=api_token,
    branch=branch,
  )
  print(f'Found {len(deployment_ids)} deployment(s) to delete for branch: {branch}')

  if not deployment_ids:
    return

  failed = delete_deployment_ids(
    account_id=account_id,
    project=project,
    token=api_token,
    deployment_ids=deployment_ids,
  )
  deleted = len(deployment_ids) - failed
  print(f'Total deleted: {deleted}, failed: {failed}')

  if failed:
    raise SystemExit(1)


if __name__ == '__main__':
  main()
