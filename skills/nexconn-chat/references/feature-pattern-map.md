# Common IM Feature → Nexconn Pattern Map

This file is loaded when a user's screenshot or mockup contains modern IM features beyond a basic message timeline (e.g. self chat, stickers, scheduled send, reactions, link preview, folders, voice messages, anonymized forward).

It maps each feature to:
- **Layer**: SDK built-in / SDK-supported (with config) / Application-layer / Application-server / Pending review / Cross-skill (Call) / Out-of-scope / Unsupported.
- **Pattern**: how to wire it.
- **Verify**: what to check in cached docs or installed SDK before promising the capability.

> **Verification rule**: Rows with `⚠️` are commonly requested but **not yet documented in this skill**. Before writing implementation code, search `references/llms.txt`, run `bash scripts/fetch-docs.sh <path>` from the skill root for the relevant doc, or treat the feature as application-layer / application-server with an explicit TODO.

## Quick map

| Feature (as it appears in mockups) | Layer | Pattern (one-liner) | Verify |
| --- | --- | --- | --- |
| Self chat / Saved Messages / "Cloud notes" | Application-layer pattern over SDK | Prefer an app-owned saved-message channel/user; only use Direct(target=current user) after confirming the platform allows it | Confirm Direct(self,self) is not blocked server-side |
| Scheduled message / Send later | Application-server + Pending review | Client persists draft + send-time; app server queues and sends at T unless an official SDK/server scheduler is verified | ⚠️ Search scheduled/send-later docs before promising |
| Send when online | Application-server + presence + Pending review | App server waits for recipient presence, then sends when online; client only renders the queued state | ⚠️ Requires verified presence API |
| Send without sound (silent send) | Application-layer or server push config + Pending review | Prefer official push/silent-notification config if available; otherwise store a flag in message extras and suppress local sound in the app | ⚠️ Verify push config / message extras per platform |
| Edit message (1h window etc.) | SDK + Application-layer policy | See `application-layer-rules.md` "Edit window pattern" | OK |
| Recall / unsend (Xm window) | SDK + Application-layer policy | See `application-layer-rules.md` "Recall window pattern" | OK |
| Pin message / Pinned header | Pending review | If native: use SDK API; if not: store pin state in app server, render via custom header | ⚠️ Pin API not yet captured in skill |
| Emoji reactions on bubble | Pending review | If native: use reactions API; if not: app-layer pattern using backend state keyed by `{messageId, userId}` and render via message updates | ⚠️ Reactions API not yet captured |
| Sticker (static + animated) | Application-layer + custom message | Define a custom message type carrying `{stickerSetId, stickerId, mediaUrl, lottie?}`; render via Chat UI custom message renderer or Chat SDK custom UI | ⚠️ Confirm custom message type registration API per platform |
| Emoji picker (categorized) | Application chrome | Picker is pure UI; only the resulting text/codepoint is sent through SDK | OK |
| Link preview (Open Graph card) | Application-server | App server fetches OG metadata for outbound URLs; result attached as message extras or as a custom card message | No SDK auto-preview is captured in this skill |
| Voice message recording (browser) | Unsupported in Web Chat UI; Pending review for Web Chat SDK | Web Chat UI does not support sending voice messages. If using Chat SDK custom UI, verify audio/custom media support first | ⚠️ Confirm Web SDK audio message support |
| Voice message playback (waveform / progress) | Application chrome | Render waveform from server-side analysis or downloaded blob; SDK only delivers the audio asset | App owns waveform |
| Folder / Tab grouping (All/Friends/Work) | Application-server | Per-user "folders" config stored in app server; client filters channel list at render layer per `application-layer-rules.md` | Do NOT alter sync scope |
| Folder invite link / "join folder" | Application-server + custom message | App server resolves invite token; client receives a custom message that, when tapped, calls app server to join | Deep link belongs to app, not SDK |
| Forward with "Hide sender name" / anonymize | Application-layer extras | When forwarding, rewrite payload extras: drop original `senderName` / `senderId` references in the rendered card; keep audit trail server-side | App-layer |
| Forward with "Change recipient picker" | Application chrome | Picker UI in app; SDK send call uses the picked channel | App-layer |
| Presence / "last seen recently" | ⚠️ verify | If native presence API exists, subscribe and render; otherwise app server tracks heartbeat | ⚠️ Presence API not yet captured |
| Bot account / system sender | Application-server | App server uses privileged Token to send as a designated user id; client renders by sender id matching | No native bot abstraction |
| Channel list with read/delivered ticks | SDK built-in | Use SDK message status events | OK |
| Outgoing call card / call buttons | Cross-skill (Nexconn Call) + custom message display | The live call action belongs to Call SDK. A historical call-record card can be rendered as a Chat custom/system message after the app server records the call result | See SKILL.md *Out of scope* |
| Login UI (QR / phone / password / 2FA) | Application-layer | SDK only consumes server-issued Token; never invent login UI | See `credentials-and-token.md` |
| Marketing / brand chrome (e.g. Telegram logo, Mobbin watermark) | Discard | Do not replicate third-party branding | — |

## How to use this map

1. After running *Screenshot inventory & discard* (see `../SKILL.md` triage workflow), classify every remaining feature against this map.
2. Merge the result into the gap table required by `integration-workflow.md` "Screenshot-driven implementation":
   - SDK built-in → `Built-in`.
   - SDK-supported with config → `Configurable`.
   - Application-layer → `Application chrome` (UI) for host-app UI, or call out as a separate "Application-layer rules" row referring to `application-layer-rules.md`.
   - Application-server → keep the `Application-server` category from `integration-workflow.md`; do not collapse backend-owned work into UI chrome.
   - Cross-skill / Out-of-scope → goes into the *Out-of-scope items* section of Final Todo Handling, not the gap table.
   - `⚠️ verify` rows → before promising, fetch the relevant doc; if still uncertain, mark the feature as **Pending review** and ask the user to either accept the application-layer fallback or wait for verification.

## Pattern: message extras vs custom message type

A frequent mis-decision is to introduce a new custom message type for features that are really just metadata on a normal text/image/audio message.

| Use **message extras** when… | Use a **custom message type** when… |
| --- | --- |
| You add a boolean flag (silent, hide-sender, scheduled origin) | You introduce a new bubble layout (sticker card, link preview card, folder invite) |
| You attach link preview data to a normal text message | You need a new send/render lifecycle (e.g. interactive cards) |
| You attach reaction state to an existing message | You need a new message *kind* in the timeline (e.g. system event card) |

Both options must be consistent across all clients and all backend audit/search paths. If you cannot guarantee that, fall back to a server-side store keyed by message id and render via SDK message-update events.

## Recommended verification before promising

For any row marked `⚠️`:

```
rg -n "<keyword>" references/llms.txt
bash scripts/fetch-docs.sh <matching-path>
```

If `llms.txt` does not contain the keyword, the feature is **not yet covered by this skill's local doc index**. Treat it as application-layer with an explicit TODO, and surface the gap to the user instead of inventing API names.
