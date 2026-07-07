---
name: nexconn-chat
description: >-
  Guides Nexconn Chat integration decisions — channel selection (Direct, Group,
  Community, Open), SDK choice (Chat SDK vs Chat UI), platform setup, credential
  management, and push notifications. Use when building chat/messaging features,
  implementing IM, choosing channel types, integrating Chat SDK or Chat UI,
  analyzing IM screenshots, or asking about messaging capabilities.
version: 1.0.1
last_updated: 2026-08-06
---

# Nexconn Chat Integration Skill

Use this skill as the entry point for Nexconn Chat work. Route the request, confirm scope, then load detailed guidance from references on demand.

## Integration routing

**CRITICAL**: For every integration request, load the [SDK Integration Decision Framework](references/sdk-integration-decision-framework.md) as the decision checklist. First identify the project platform and existing SDK state, then read the relevant official documentation and inspect installed SDK artifacts when available; only after that, execute the five-layer judgment process using the collected evidence. If the user explicitly selects Chat UI or Chat SDK, treat that selection as a constraint; do not switch to the other integration layer without explaining the trade-off and obtaining approval. Do not implement until the decision layer is recorded.

| Building…                              | Recommended approach          | Details                               |
| -------------------------------------- | ----------------------------- | ------------------------------------- |
| 1v1 private conversations              | Chat SDK/UI + Direct Channel  | Query channel capabilities via Channel Guide (see Channel capabilities section)         |
| Small groups, customer service (≤3000) | Chat SDK/UI + Group Channel   | Query channel capabilities via Channel Guide (see Channel capabilities section)         |
| Large communities, forums, guilds      | Chat SDK + Community Channel  | Query channel capabilities via Channel Guide (see Channel capabilities section)         |
| Live chat rooms, temporary events      | Chat SDK + Open Channel       | Query channel capabilities via Channel Guide (see Channel capabilities section)         |
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

For any "does <channel> support <capability>" question (member limits, offline storage/push, @ mentions, read receipts, unread count, edit/reply/forward, delete-for-me vs delete-for-everyone, channel deletion vs server-side dissolve, sub-channels, pinning, reliability), fetch and read the Channel Guide:

1. From the skill root, run: `bash scripts/fetch-docs.sh /guides/realtime-chat/intro-chat/im-feature-basic.md`
2. Read the cached guide: `references/cache/guides/realtime-chat/intro-chat/im-feature-basic.md`
3. If fetch fails due to network issues, continue with available information and mark the answer as pending verification

The Channel Guide holds the channel feature matrix. Capabilities not documented there (e.g. message pinning, emoji reactions, presence/last-seen) are unverified: fetch the relevant doc with `scripts/fetch-docs.sh` or treat them as application-layer (see `references/application-layer-rules.md`) before promising them.

Two recurring traps when answering:
- *Channel deletion* removes the conversation from the current user's list; *Dissolve channel* removes the channel server-side for everyone. Do not conflate.
- *Telegram-style "Channel" (broadcast) ≠ Nexconn Open Channel.* Telegram channels persist offline and push notify; Nexconn Open is online-only. When a user's mockup shows a one-way broadcast list, recommend **Group + role-based send permission** rather than Open, unless they explicitly accept the online-only constraint.

## Critical rules

**INTEGRATION WORKFLOW ENFORCEMENT** (最高优先级):
- **For EVERY integration request, you MUST fetch official documentation BEFORE writing any code**
  - Use `bash scripts/fetch-docs.sh <doc-path>` to fetch quickstart/integration guides from skill root
  - Read the fetched documentation completely to understand initialization sequence and workflow
  - Only after understanding the documented workflow, proceed to implementation
  - **Violation of this rule leads to incorrect initialization sequences and integration failures**
  - DO NOT assume integration flow based on TypeScript definitions or "similar SDKs"

- *Never place App Secret, signing logic, or Token-generation code in client-side code.*
- *Follow a two-phase documentation approach*: (1) Read official documentation first to understand integration workflow, initialization sequence, and best practices; (2) Then verify exact API signatures, enum names, and type definitions in the installed SDK code. Do not reverse-engineer integration flow from type definitions alone.
- *Never invent API details* — if neither docs nor code confirms it, fetch the doc, inspect packages, or mark as pending review.
- *Never infer SDK enum or constant member names from generic IM knowledge* — after reading documentation, verify exact names in the installed SDK artifacts for the target platform. For Web/TypeScript, grep `node_modules/@nexconn/**/*.d.ts`; for Android, grep the installed Gradle/Maven SDK declarations or extracted AAR classes/sources; for iOS, grep the installed CocoaPods/SPM SDK headers, Swift interfaces, or generated module interfaces. If the platform artifact is unavailable, mark the name as pending verification instead of guessing.
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
  ├─ Step 1: Normalize terminology (see below)
  │
  ├─ Step 2: Scope check → non-Chat (calls, meetings, auth, marketing)? reject per "Out of scope"
  │
  └─ Step 3: Classify request type, then execute
        │
        ├─ CONSULTATION (asking about features, capabilities, limits):
        │     │
        │     ├─ Check official documentation and capability matrices first
        │     │   → Verify exact details in the installed SDK when available
        │     │   → Answer capability, limitations, and recommended integration layer
        │     │
        │     ├─ Has screenshot(s)?
        │     │     YES → If 2+ images: run inventory & discard first (per image-analysis-guide.md)
        │     │           → Analyze per image-analysis-guide.md
        │     │           → Output capability analysis and recommendation, STOP
        │     │     NO  → Answer capability, limitations, and recommendation, STOP
        │     
        └─ INTEGRATION (writing code, implementing features):
              │
              ├─ **STEP 1 - MANDATORY DOCUMENTATION FETCH** ⚠️:
              │   From skill root, execute: `bash scripts/fetch-docs.sh /<platform-quickstart-path>`
              │   Examples:
              │     - Web: `bash scripts/fetch-docs.sh /chatui-web/quickstart.md`
              │     - Android: `bash scripts/fetch-docs.sh /chatui-android/quickstart.md`
              │     - iOS: `bash scripts/fetch-docs.sh /chatui-ios/quickstart.md`
              │   Then read: `references/cache/<platform>/quickstart.md`
              │   ⚠️ THIS STEP IS NOT OPTIONAL - DO NOT PROCEED WITHOUT READING DOCS
              │
              ├─ STEP 2 - Project Identification:
              │   → infer the platform/SDK from project files
              │   → check installed SDK versions and state
              │
              ├─ STEP 3 - Verify SDK Details:
              │   → verify exact API signatures in installed SDK artifacts
              │   → check enum names, type definitions, method signatures
              │
              ├─ STEP 4 - Execute Five-Layer Decision Framework (sdk-integration-decision-framework.md)
              │   using the evidence collected from Steps 1-3:
              │   Layer 1: Chat UI native capability check
              │   Layer 2: Chat UI extension capability check
              │   Layer 3: Chat SDK API check
              │   Layer 4: Source code modification feasibility (if reached, read chat-ui-repositories.md)
              │   Layer 5: Workaround or reject
              │
              ├─ STEP 5 - Record decision outcome: "Using Layer X approach because..."
              │
              ├─ STEP 6 - Implement:
              │   Has screenshot(s)?
              │     YES → If 2+ images: run inventory & discard first (per image-analysis-guide.md)
              │           → Load integration-workflow.md in "Screenshot-driven implementation" mode
              │           → Implement per decision framework result
              │     NO  → Load integration-workflow.md in standard mode
              │           → Implement per decision framework result
```

**Request type signals**:
- Consultation: `这是什么功能 / what is this / can Chat SDK do this / does it support`
- Integration: `怎么实现 / how to implement / implementation approach / 按这个截图实现 / build this / 给我代码 / generate code / integrate this`
- A capability question becomes Integration when the user explicitly asks how to implement, integrate, customize, or modify the capability.
- If unclear: ask one short clarifying question before proceeding to Step 3 execution

**Inventory & discard** (for 2+ screenshots):
- List each screen's subject in one line
- Discard: third-party brand chrome, marketing pages, watermarks
- Mark as out-of-scope: Auth/Onboarding screens (application-layer), Call/RTC/meeting screens (Nexconn Call)
- Keep only Chat-relevant screenshots for analysis/implementation

**Execution notes**:
- **Consultation responses**: Report the supported capability, documented limitations, and recommended integration layer. Do not execute the full five-layer framework or evaluate source modification/workarounds unless the user asks how to implement the requirement.
- **Integration responses**: MUST start with STEP 1 (fetch documentation). Must include a decision layer annotation (e.g., "Layer 1: Chat UI native capability", "Layer 3: Chat SDK API + custom wrapper").
- **When an Integration request reaches Layer 4**: Must explicitly ask user for approval before cloning source code (see chat-ui-repositories.md).
- **NEVER skip STEP 1 documentation fetch** - even if you think you know the SDK, even if TypeScript definitions are available, even if it "looks simple"
- All paths are mutually exclusive; once a path executes, the workflow ends at its terminal point (STOP or Implement)
- If all screenshots are discarded in inventory, treat as "No screenshot" in the execution branch


## Terminology normalization

Before scope check, rewrite user wording into Nexconn's official terms when the request contains ambiguous, non-standard, or cross-product terminology:

1. Search `references/llms.txt` (with `rg`) for `Chat glossary` and `Call glossary` paths. If `references/llms.txt` is missing or older than 1 day, run `bash scripts/fetch-docs.sh` from the skill root to download/refresh the remote index, then retry the search.
2. From the skill root, fetch glossary: `bash scripts/fetch-docs.sh <path>`. Also fetch Call glossary if user mentions calls, audio/video, meetings, RTC, or any cross-boundary term. Documents are cached under `references/cache/` with a 7-day expiry.
3. Read cached Markdown under `references/cache/`.
4. Keep user's business intent intact. If a normalized term changes scope, mention it once.
5. If mapping is uncertain, ask one short clarifying question.

**Network unavailability fallback**: If documentation cannot be fetched due to network issues, continue with cached files (if available) or local references. Mark any uncertain terminology as pending verification instead of blocking the whole task. This fallback strategy applies to all documentation fetch operations throughout the skill workflow.


## References

Only load a reference file when its trigger condition is met. Do NOT preload all references.

| File | Purpose | Load when |
| --- | --- | --- |
| `sdk-integration-decision-framework.md` | Five-layer decision checklist: Chat UI native → Chat UI extensions → Chat SDK API → source code modification → workaround. Use the evidence collected during project identification and documentation/code verification to determine the implementation path | Load for every Integration request; execute after the preflight evidence is collected and before implementation |
| `integration-workflow.md` | Full execution workflow: project identification, confirmation, documentation/code verification, implementation, testing, todo | Request is Integration type; use its Project Identification and Documentation & Code Verification sections as preflight before the decision framework, then continue with the remaining implementation sections |
| `chat-ui-repositories.md` | Chat UI source code repository URLs for each platform (Web/Android/iOS/Flutter) | Decision framework reaches Layer 4 "source code modification" AND user explicitly agrees to modify source code |
| `platform-setup/<platform>.md` | Navigation only: per-platform (`web`/`android`/`ios`/`flutter`) doc-path index plus cross-doc difference flags (e.g. iOS vs Android pin UI, iOS data-center default). Channel coverage lives in SKILL.md; the channel capability matrix is fetched via `fetch-docs.sh` as described in Channel capabilities section; start from `platform-setup/index.md` | Target platform is known and you need its doc map or platform-specific difference flags |
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
