# indico-fetcher

A simple utility to fetch indico meetings information from the command line.

## EXAMPLE:

```bash
indico-fetcher --api-key API_KEY --api-secret API_SECRET /event/EVENT_ID | jq ".results[0].title"
```
