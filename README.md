# jira-project-export

A little shell script to extract issues and metadata for a JIRA project as JSON. If you just want to copy&paste the API call, look [here](https://github.com/sgreben/jira-project-export/blob/master/export.sh#L112) (everything else is parsing CLI args)

## Prerequisites

- `curl`
- `jq`
- Your JIRA server's REST API must be accessible.

## Example

```bash
$ ./export.sh -auth=user:pass -url=https://localhost/jira -project=ABC -export=issues
{
  "expand": "schema,names",
  "startAt": 0,
  "maxResults": 123,
  "total": 123,
  "issues": [
    ...
  ]
}
```

## Usage

```text
Usage:
  export.sh -auth=USER:PASS -url=URL -project=PROJECT -export=[issues|meta]

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
```
