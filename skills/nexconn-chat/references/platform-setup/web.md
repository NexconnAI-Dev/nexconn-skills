# Platform Notes — Web

This file is **navigation only** — it points to the docs to fetch and flags cross-doc differences. Channel coverage lives in SKILL.md; the channel capability matrix lives in `channel-guide.md`; per-doc descriptions and single-doc facts (voice/search support, member limits, etc.) live in the docs themselves. Run commands from the skill root: `rg chatui-web references/llms.txt`, then `bash scripts/fetch-docs.sh <path>`. The ⚠️ convention is defined in SKILL.md.

## Cross-doc differences worth knowing before you fetch

- Web Chat UI has the **narrowest feature set** of all platforms — the capability matrix in `/chatui-web.md` is the source of truth for what's missing (e.g. voice sending, message search). Check it before promising any feature on Web that mobile has.
- Delivered as **Web Components / custom elements**, not a regular widget tree — some structural layout changes are locked by the components; if the user needs them, accept the locked layout or move that surface to Chat SDK. (See `components.md`, `chat-ui/layout.md`.)

## Doc paths (fetch on demand)

- Core: `/chatui-web.md` (capability matrix — voice/search/member limits live here), `/chatui-web/quickstart.md`, `/chatui-web/chat-ui/switch.md` (feature switches)
- Profile/data: `/chatui-web/user/hooks.md`, `/chatui-web/user/overview.md`, `/chatui-web/user/update.md`
- UI/layout: `/chatui-web/components.md`, `/chatui-web/chat-ui/layout.md`, `/chatui-web/chat-ui/editor.md`
- To discover others, `rg chatui-web references/llms.txt` from the skill root.
