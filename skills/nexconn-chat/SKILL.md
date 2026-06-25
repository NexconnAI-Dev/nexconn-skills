---
name: nexconn-chat
description: >-
  Guides Nexconn Chat integration decisions — channel selection (Direct, Group,
  Community, Open), SDK choice (Chat SDK vs Chat UI), platform setup, credential
  management, and push notifications. Use when building chat/messaging features,
  implementing IM, choosing channel types, integrating Chat SDK or Chat UI,
  analyzing IM screenshots, or asking about messaging capabilities.
version: 1.0.0
last_updated: 2026-06-18
---

# Nexconn Chat Integration Skill

Use this skill as the entry point for Nexconn Chat work. Route the request, confirm scope, then load detailed guidance from references on demand.

## Integration routing

| Building…                              | Recommended approach          | Details                               |
| -------------------------------------- | ----------------------------- | ------------------------------------- |
| 1v1 private conversations              | Chat SDK/UI + Direct Channel  | [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic)         |
| Small groups, customer service (≤3000) | Chat SDK/UI + Group Channel   | [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic)         |
| Large communities, forums, guilds      | Chat SDK + Community Channel  | [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic)         |
| Live chat rooms, temporary events      | Chat SDK + Open Channel       | [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic)         |
| Quick launch, standard IM experience   | Chat UI                       | `integration-workflow.md`  |
| Custom UI, deep customization          | Chat SDK                      | `integration-workflow.md`  |
| Platform-specific setup (iOS / Android / Flutter / Web) | Read platform notes for that platform | `platform-setup/index.md` |
| Credential / Token management          | See credential reference      | `credentials-and-token.md` |

SDK decision rules:
- For Direct/Group, prefer Chat UI on every platform (iOS / Android / Web / Flutter); fall back to Chat SDK only for channel types Chat UI does not cover.
- The routing table is organized by scenario, not platform — whether a channel type is reachable via Chat UI depends on the platform, so always cross-check the *Chat UI channel coverage* table below before committing to Chat SDK vs Chat UI.

## Chat UI channel coverage

Chat UI only ships built-in support for a subset of channel types per platform. If the user needs a channel type that Chat UI does not cover, fall back to Chat SDK. `⚠️ Unverified` means no official doc confirms it — default to Chat SDK and tell the user it is unverified, **not** that it is unsupported (see `references/platform-setup/`).

| Platform | Direct | Group | Community | Open | System (read-only) |
| --- | --- | --- | --- | --- | --- |
| Web      | ✅ | ✅ | ❌ Use Chat SDK | ❌ Use Chat SDK | ✅ |
| Android  | ✅ | ✅ | ❌ Use Chat SDK | ❌ Use Chat SDK | ✅ |
| iOS      | ✅ | ✅ | ❌ Use Chat SDK | ❌ Use Chat SDK | ✅ |
| Flutter  | ✅ | ✅ | ❌ Use Chat SDK | ❌ Use Chat SDK | ✅ |

If the request mixes covered and uncovered channels (e.g. Web Group + Open), recommend Chat UI for the covered part and Chat SDK for the rest, and call out the split explicitly.

## Channel capabilities

For any "does <channel> support <capability>" question (member limits, offline storage/push, @ mentions, read receipts, unread count, edit/reply/forward, delete-for-me vs delete-for-everyone, channel deletion vs server-side dissolve, sub-channels, pinning, reliability), refer to the [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic) — it holds the channel feature matrix. Capabilities not documented there (e.g. message pinning, emoji reactions, presence/last-seen) are unverified: fetch the relevant doc with `scripts/fetch-docs.sh` or treat them as application-layer (see `references/application-layer-rules.md`) before promising them.

Two recurring traps when answering:
- *Channel deletion* removes the conversation from the current user's list; *Dissolve channel* removes the channel server-side for everyone. Do not conflate.
- *Telegram-style "Channel" (broadcast) ≠ Nexconn Open Channel.* Telegram channels persist offline and push notify; Nexconn Open is online-only. When a user's mockup shows a one-way broadcast list, recommend **Group + role-based send permission** rather than Open, unless they explicitly accept the online-only constraint.

## Critical rules

- *Never place App Secret, signing logic, or Token-generation code in client-side code.*
- *Always read official documentation before reading SDK source code* — type definitions lack initialization order, lifecycle, and best-practice context.
- *Never invent API details* — if neither docs nor code confirms it, fetch the doc, inspect packages, or mark as pending review.
- *Never infer SDK enum or constant member names from generic IM knowledge* — whenever guidance or code involves Nexconn SDK enum/constant members, verify exact names in the installed SDK artifacts for the target platform before using them. For Web/TypeScript, grep `node_modules/@nexconn/**/*.d.ts`; for Android, grep the installed Gradle/Maven SDK declarations or extracted AAR classes/sources; for iOS, grep the installed CocoaPods/SPM SDK headers, Swift interfaces, or generated module interfaces. If the platform artifact is unavailable, mark the name as pending verification instead of guessing.
- *If documentation and installed code disagree*, implement against the installed code and mention the conflict briefly; if the cached doc looks outdated, refresh it with `bash scripts/fetch-docs.sh --force <path>`.
- *Default generated UI copy and Chat UI language to `en_US`* unless the user requests otherwise or the project already standardizes on another locale.
- *Default `NCEngine.initialize` log level to Debug* during integration; remind the user to switch to WARN/ERROR before production.
- *Login / signup / 2FA / QR-code-login screens are application-layer and out of SDK scope.* The Chat SDK only consumes a server-issued Token; do not promise built-in login UI.
- *When a screenshot bundle includes third-party brand chrome (e.g. Telegram logo, Mobbin watermark, marketing landing pages), discard it.* Never replicate competitor branding; never treat marketing pages as IM features.
- *When a screenshot bundle mixes Chat with Call/RTC/meeting surfaces*, split scopes: handle the Chat part in this skill, route the Call part to Nexconn Call (or `Out of scope` table) and never silently merge them.

## Out of scope

| User keywords | How to handle |
| --- | --- |
| Video conferencing, meetings, conference | Not Nexconn Chat; suggest support: https://www.nexconn.ai/contact-us |
| Live streaming, video streaming | Not Chat; if the need is live text chat, use Open Channels |
| Audio/video calls, 1v1 video | Not a Chat messaging capability; suggest support: https://www.nexconn.ai/contact-us |
| Login, signup, QR login, phone login, 2FA | Application authentication, not Chat; Chat only consumes a server-issued Token |
| Marketing page, app store/download page, third-party brand chrome | Not an SDK integration surface; discard it during screenshot analysis |

If only part of the request is in scope, handle the Chat messaging part and explicitly separate the non-Chat capability.

## Triage workflow

```
User Request
  │
  ├─ Normalize terminology (see below)
  │
  ├─ Scope check → non-Chat? reject per "Out of scope"
  │
  ├─ Contains image/screenshot?
  │     ├─ If 2 or more images: run *Screenshot inventory & discard* first
  │     │     → list each screen's subject in one line
  │     │     → discard third-party brand chrome / marketing pages / watermarks
  │     │     → mark Auth/Onboarding screens as application-layer (out of SDK scope)
  │     │     → mark Call/RTC/meeting screens as cross-skill (Nexconn Call)
  │     ├─ User explicitly requests implementation
  │     │     → analyze per image-analysis-guide.md
  │     │     → enter integration-workflow.md "Screenshot-driven implementation"
  │     │     → run Confirmation Gates, then implement
  │     └─ Otherwise (analysis-only / unclear intent)
  │           → analyze per image-analysis-guide.md
  │           → output analysis, STOP, wait for user confirmation
  │
  └─ Route by request type
        ├─ Consultation → answer from references/docs. Done.
        └─ Integration → load integration-workflow.md, follow from step 1.
```

Request type definitions:
- **Consultation**: asking about features, channel differences, capabilities, limits.
- **Integration**: writing code, modifying integration, building an IM app, implementing a feature.

"Explicitly requests implementation" examples: "按这个截图实现 / build this UI / 给我代码 / generate code / integrate this". "Analyze only" examples: "这是什么功能 / what is this / can Chat SDK do this".

## Terminology normalization

Before scope check, rewrite user wording into Nexconn's official terms when the request contains ambiguous, non-standard, or cross-product terminology:

1. Search `references/llms.txt` (with `rg`) for `Chat glossary` and `Call glossary` paths. If `references/llms.txt` is missing or older than 1 day, run `bash scripts/fetch-docs.sh` from the skill root to download/refresh the remote index, then retry the search.
2. From the skill root, fetch glossary: `bash scripts/fetch-docs.sh <path>`. Also fetch Call glossary if user mentions calls, audio/video, meetings, RTC, or any cross-boundary term. Documents are cached under `references/cache/` with a 7-day expiry.
3. Read cached Markdown under `references/cache/`.
4. Keep user's business intent intact. If a normalized term changes scope, mention it once.
5. If mapping is uncertain, ask one short clarifying question.

If the glossary cannot be fetched because network access is unavailable, continue with the local references and mark any uncertain terminology as pending verification instead of blocking the whole task.

## References

Only load a reference file when its trigger condition is met. Do NOT preload all references.

| File | Purpose | Load when |
| --- | --- | --- |
| `integration-workflow.md` | Full execution workflow: project ID, confirmation, docs, implementation, testing, todo | Request is Integration type |
| `platform-setup/<platform>.md` | Navigation only: per-platform (`web`/`android`/`ios`/`flutter`) doc-path index plus cross-doc difference flags (e.g. iOS vs Android pin UI, iOS data-center default). Channel coverage lives in SKILL.md; the channel capability matrix is available at [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic); start from `platform-setup/index.md` | Target platform is known and you need its doc map or platform-specific difference flags |
| `credentials-and-token.md` | App Key, App Secret, Token, security rules | Handling credentials or security-sensitive guidance |
| `application-layer-rules.md` | Application-level policies (edit window, recall window, mention triggers, etc.) | Request includes time-window, character-limit, or trigger-rule logic that the SDK does not enforce |
| `feature-pattern-map.md` | Common modern-IM feature → Nexconn classification (self chat, scheduled, reactions, stickers, voice, link preview, folders, presence, etc.) | Screenshot/mockup contains modern IM features beyond the basic message timeline |
| `image-analysis-guide.md` | Screenshot/mockup → SDK feature mapping | User's message contains IM screenshots or visual material |
| `llms.txt` | Official documentation index (search with `rg`, do not read in full) | Need to locate documentation paths or glossaries |
| `api-references.md` | Official API reference URLs for each SDK and UI component | User asks about specific API methods, types, events, or component props |

## llms.txt search cheat sheet

`llms.txt` is large (~800 lines). Always search with `rg` rather than reading top-to-bottom. Common starting points:

If `references/llms.txt` is missing, run `bash scripts/fetch-docs.sh` from the skill root to download `https://docs.nexconn.ai/llms.txt`, then retry the `rg` search. The index is cached with a 1-day expiry; the script automatically refreshes stale copies. If the download fails because network access is unavailable, continue with local references and mark missing doc paths as pending verification.

| Need | `rg` keyword | Likely path prefix |
| --- | --- | --- |
| Glossary / terminology | `Chat glossary`, `Call glossary` | `/guides/glossary/...` |
| Quickstart / first message | `quickstart`, `Send your first message`, `Make your first call` | `/chatsdk-<platform>.md`, `/chatui-<platform>/quickstart.md` |
| Multi-device sync | `multi-device`, `multiple-client-sync`, `multiple-platform` | `/chatsdk-<platform>/connection/...` |
| Read receipts | `read receipt`, `read/unread` | `/chatsdk-<platform>/group-channels/...` |
| @ mentions | `mention`, `@mention` | `/chatsdk-<platform>/group-channels/...`, `/chatui-<platform>/...` |
| Custom messages | `custom message`, `customize` | `/chatsdk-<platform>/message/customize.md` |
| ChatUI extension points | `hooks`, `theme`, `customize`, `extension` | `/chatui-<platform>/...` |
| Token / signing | `token`, `signing`, `server api` | `/platform-chat-api/...` |
| Status codes / errors | `status codes`, `code` | `/chatsdk-<platform>/code.md` |

If a search returns nothing, fall back to: (1) read llms.txt in segments around the relevant SDK heading, or (2) ask the user one short clarifying question rather than guessing.
