# Platform Notes — iOS

This file is **navigation only** — it points to the docs to fetch and flags cross-doc differences. Channel coverage lives in SKILL.md; the channel capability matrix lives in `channel-guide.md`; per-doc descriptions and single-doc facts live in the docs themselves. Run commands from the skill root: `rg chatui-ios references/llms.txt`, then `bash scripts/fetch-docs.sh <path>`. The ⚠️ convention is defined in SKILL.md.

## Cross-doc differences worth knowing before you fetch

- **Channel pinning** differs from Android: iOS Chat UI only *displays* pinned channels and has **no built-in pin/unpin UI** — the action needs Chat SDK channel APIs. Don't promise built-in pinning UI on iOS. (See `features/stick-to-top.md`.)
- **Data center**: defaults to Singapore — `areaCode` must be set explicitly when the App Key belongs elsewhere, or connection silently targets the wrong region. (See `init.md`.)

## Doc paths (fetch on demand)

- Core: `/chatui-ios.md`, `/chatui-ios/import.md`, `/chatui-ios/init.md`, [release notes](https://docs.nexconn.ai/chatui-ios/release-notes)
- Profile: `/chatui-ios/user/userinfo.md`
- Channel list: `/chatui-ios/key-functions/conversation-list.md`
- Features: `/chatui-ios/features/` → `message-mention.md`, `message-receipt.md`, `online-status.md`, `stick-to-top.md`, `typing-status.md`
- Chat SDK (Open / Community / pin-unpin action / message pinning): `/chatsdk-ios.md`
