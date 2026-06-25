# Platform Notes — Android

This file is **navigation only** — it points to the docs to fetch and flags cross-doc differences. Channel coverage lives in SKILL.md; the channel capability matrix is available at [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic); per-doc descriptions and single-doc facts live in the docs themselves. Run commands from the skill root: `rg chatui-android references/llms.txt`, then `bash scripts/fetch-docs.sh <path>`. The ⚠️ convention is defined in SKILL.md.

## Cross-doc differences worth knowing before you fetch

- **Channel pinning** differs from iOS: Android Chat UI ships built-in long-press pin/unpin; iOS only displays pinned channels and needs Chat SDK for the action. (Compare `features/stick-to-top.md` across both platforms.)

## Doc paths (fetch on demand)

- Core: `/chatui-android.md`, `/chatui-android/import.md`, `/chatui-android/init.md`, `/chatui-android/android-os-version.md`, [release notes](https://docs.nexconn.ai/chatui-android/release-notes)
- Profile: `/chatui-android/user/userinfo.md`
- Channel list: `/chatui-android/key-functions/conversation-list.md`, `/chatui-android/customization/conversation-list-data-processor.md`
- Features: `/chatui-android/features/` → `message-mention.md`, `message-receipt.md`, `online-status.md`, `stick-to-top.md`, `typing-status.md`
- Chat SDK (Open / Community / message pinning): `/chatsdk-android.md`
