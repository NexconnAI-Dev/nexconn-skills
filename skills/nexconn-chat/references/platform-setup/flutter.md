# Platform Notes — Flutter

This file is **navigation only** — it points to the docs to fetch and flags cross-doc differences. Channel coverage lives in SKILL.md; the channel capability matrix lives in `channel-guide.md`; per-doc descriptions and single-doc facts live in the docs themselves. Run commands from the skill root: `rg chatui-flutter references/llms.txt`, then `bash scripts/fetch-docs.sh <path>`. The ⚠️ convention is defined in SKILL.md.

## Cross-doc differences worth knowing before you fetch

- Chat UI **is** available on Flutter (package `ai_nexconn_chatui_plugin`) — both mounting the built-in Chat UI and building your own against Chat SDK are viable. Don't assume Flutter is Chat-SDK-only.
- The Chat UI package re-exports the SDK types the UI needs through a single entry point, so you rarely import the Chat SDK package directly. (See `init.md` / `import.md`.)
- **Customization is builder-based**, unlike the other platforms: Flutter splits into a *config* layer (`customization/config/`) and a *builder* layer (`customization/builder/`) for replacing widgets. (See `customization.md`.)
- **Channel pinning ships built-in** on Flutter Chat UI (`features/channel-pin.md`) — note the path is `channel-pin.md` here, not `stick-to-top.md` as on Android/iOS/Web.

## Doc paths (fetch on demand)

- Core: `/chatui-flutter.md`, `/chatui-flutter/import.md`, `/chatui-flutter/init.md`, `/chatui-flutter/chatui-config-guide.md`, [release notes](https://docs.nexconn.ai/chatui-flutter/release-notes)
- Key functions: `/chatui-flutter/key-functions/` → `channel-list.md`, `chat-page.md`, `input.md`, `listener.md`
- Profile: `/chatui-flutter/user/userinfo.md`, `/chatui-flutter/user/group-info.md`
- Features: `/chatui-flutter/features/` → `message-mention.md`, `message-forward.md`, `message-reference.md`, `channel-pin.md`, `unread.md`, `draft.md`, `voice-message.md`, `file-message.md`, `image-gif-message.md`, `short-video-message.md`, `delete-message-for-all.md`
- Customization: `/chatui-flutter/customization.md`, `customization/config/` (`channel-page.md`, `chat-page.md`, `input.md`, `bubble.md`), `customization/builder/` (`channel-page.md`, `chat-page.md`, `message-bubble.md`)
- Chat SDK (Open / Community / direct SDK use): `/chatsdk-flutter.md`
- To discover anything not listed, `rg chatui-flutter references/llms.txt` from the skill root.
