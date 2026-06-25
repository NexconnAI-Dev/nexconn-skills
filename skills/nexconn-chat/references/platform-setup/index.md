# Nexconn Chat Platform Notes

Each platform file is **navigation only**: it points to the official docs to fetch and flags cross-doc differences (e.g. iOS has no built-in pin/unpin UI while Android does). It deliberately does **not** repeat single-doc facts — those live in the docs and are fetched on demand.

Channel coverage is **not** here either — it lives in SKILL.md. The channel capability matrix is available at [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic.md), the source of truth for per-channel capabilities.

Once the target platform is known, open that platform's file for the doc map and difference flags:

| Platform | File |
| --- | --- |
| Web | `platform-setup/web.md` |
| Android | `platform-setup/android.md` |
| iOS | `platform-setup/ios.md` |
| Flutter | `platform-setup/flutter.md` |

## Fetching official docs (applies to all platforms)

Each platform file ends with an **on-demand doc index** — a list of official doc paths, *not* a reading list. The platform file tells you *which* doc answers a given question; fetch that single path for the actual facts (feature defaults, limits, API names, parameters, config objects):

All commands in the platform files are written to run from the **skill root** (the `nexconn-chat/` directory), e.g.:

```
bash scripts/fetch-docs.sh <path>      # e.g. bash scripts/fetch-docs.sh /chatui-android.md
rg chatui-android references/llms.txt  # discover paths not listed in a platform file
```

`fetch-docs.sh` writes into `references/cache/` and manages freshness itself — it re-downloads a cached file once it passes the staleness threshold (14 days by default) and falls back to a stale copy when offline, so you normally don't manage the cache by hand. Use `--force` to refresh immediately.

The ⚠️ convention (e.g. `⚠️ Unverified`) is defined in SKILL.md.
