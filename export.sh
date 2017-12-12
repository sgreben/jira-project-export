#!/bin/sh

check_curl() {
    if ! which curl >/dev/null; then 
        >&2 printf "%s" "This script requires curl but it's not installed. Aborting."
        exit 1
    fi
}

check_jq() {
    if ! which jq >/dev/null; then 
        >&2 printf "%s" "This script requires jq but it's not installed. Aborting."
        exit 1
    fi
}

check_dependencies() {
    check_curl
    check_jq
}

check_dependencies

print_usage() {
  printf "%s\n" "

Usage:
  $(basename "$0") -auth=USER:PASS -url=URL -project=PROJECT -export=[issues|meta]

Options:
  -h | -help
    Print the help text.
  -auth=USER:PASS
    JIRA authentication (username, password).
  -url=URL
    JIRA server URL (including protocol, e.g. https://).
  -project=PROJECT
    JIRA project key.
  -export=issues
    Export the given project's issues as JSON to stdout.
  -export=meta
    Export the given project's metadata as JSON to stdout.
" >&2
}

while [ $# -gt 0 ] && [ "$1" != "" ]; do
case $1 in
    -auth=* )
        JIRA_AUTH="$1"
        JIRA_AUTH=${JIRA_AUTH#-auth=}
        ;;
    -url=* )
        JIRA_URL="$1"
        JIRA_URL=${JIRA_URL#-url=}
        ;;
    -project=* )
        JIRA_PROJECT="$1"
        JIRA_PROJECT=${JIRA_PROJECT#-project=}
        ;;
    -export=issues)
        JIRA_EXPORT=issues
        ;;
    -export=meta)
        JIRA_EXPORT=meta
        ;;
    -export=*)
        printf "%s\n" "Error: unknown value for -export: $1"
        print_usage
        exit 1
        ;;
    -h | -help )
        print_usage
        exit 0
        ;;
     *)
        printf "%s\n" "Error: Unknown option $1"
        print_usage
        exit 1
        ;;
esac
shift 1
done

complain_and_exit_if_params_unset() {
    if [ "${JIRA_AUTH:-}" = "" ]; then
        >&2 printf "%s\n" "Error: Missing argument: -auth"
        print_usage
        exit 1
    fi

    if [ "${JIRA_URL:-}" = "" ]; then
        >&2 printf "%s\n" "Error: Missing argument: -url"
        print_usage
        exit 1
    fi

    if [ "${JIRA_PROJECT:-}" = "" ]; then
        >&2 printf "%s\n" "Error: Missing argument: -project"
        print_usage
        exit 1
    fi

    if [ "${JIRA_EXPORT:-}" = "" ]; then
        >&2 printf "%s\n" "Error: Missing argument: -export"
        print_usage
        exit 1
    fi
}

complain_and_exit_if_params_unset

api() {
    curl -s -u "$JIRA_AUTH" -XGET -H"Content-Type: application/json" "$@"
}

issues() {
    # TODO: instead of trying to get all results in one go, use pagination
    project_issues_num=$(api "$JIRA_URL/rest/api/2/search?jql=project%3D%22$JIRA_PROJECT%22&maxResults=0" | jq -M .total)
    project_issues=$(api "$JIRA_URL/rest/api/2/search?jql=project%3D%22$JIRA_PROJECT%22&maxResults=$project_issues_num&fields=%2Aall")
    printf "%s" "$project_issues" | jq -M .
}

meta() {
    project_json=$(api "$JIRA_URL/rest/api/2/project/$JIRA_PROJECT")
    printf "%s" "$project_json" | jq -M .
}

case $JIRA_EXPORT in
    issues)
        issues
        ;;
    meta)
        meta
        ;;
esac