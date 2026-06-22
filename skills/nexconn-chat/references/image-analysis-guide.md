# Visual SDK Feature Identification Guide

This guide describes how to use IM/chat screenshots, UI mockups, and product reference images to identify which Nexconn Chat SDK or Chat UI capability the user wants to integrate.

Default behavior: analyze the visible product behavior first, map it to canonical Nexconn Chat terminology and SDK integration surfaces, then decide whether the user is asking for an explanation, an implementation plan, or code changes. Do not treat every image as an AI vision/OCR integration request.

## Non-Chat screenshot triage

Before applying the IM feature template, decide whether the image is actually a Chat SDK integration surface.

| Visible screen | Classification | Response rule |
| --- | --- | --- |
| Login, signup, phone number, QR login, password, 2FA, "keep me signed in" | Application auth | Explain that Chat only consumes a server-issued Token; do not invent SDK login APIs. If useful, point to `credentials-and-token.md`. |
| Marketing page, download page, app store page, competitor brand splash, Mobbin watermark | Non-SDK product chrome | Discard from feature mapping. Do not reproduce competitor branding. |
| Call controls, meeting UI, screen sharing, recording | Cross-skill / Out of scope | Split from Chat and route to Nexconn Call or support. A call-record card in the message timeline may still be a Chat custom message. |
| Settings page unrelated to messages/channels | Usually application chrome | Extract only Chat-relevant settings, if any; otherwise ask for the target Chat feature. |

If the image is not a Chat integration surface and the user did not provide a Chat-specific requirement, stop after explaining the classification and ask one short follow-up question.

## IM Screenshot SDK Feature Identification

When the user provides a screenshot of an IM, chat, or messaging product and asks to analyze "this feature", "the image function", "what capability this is", "how to integrate this", or similar wording, first identify the SDK feature being referenced. Do not start implementation unless the user explicitly asks to build it and the confirmation gates in `../SKILL.md` are satisfied.

Analyze the screenshot in this order:

1. **Visible UI Context**
   - Identify the product surface shown in the screenshot, such as conversation list, message thread, composer, media preview, message action menu, pinned message area, search, call controls, or notification state.
   - Describe the key visible elements and their relationship to the current user action.

2. **Core SDK Feature Identification**
   - Name the primary IM capability shown, using canonical Chat terminology where possible.
   - Examples include message forwarding, sender-name hiding, recipient change, forwarded-message preview, message reply, pinned message, media message, voice message, file message, read receipt, unread count, search, member management, moderation, or channel navigation.

3. **Chat SDK/Chat UI Capability Mapping**
   - Map the visible feature to likely Chat SDK or Chat UI capabilities and channel types when inferable.
   - If the screenshot involves private conversations or small groups, mention Direct Channels or Group Channels as likely candidates.
   - If the screenshot shows large community, forum, guild, sub-channel, or public discussion behavior, mention Community Channels.
   - If the screenshot shows live, online-only event chat behavior, mention Open Channels.
   - If the screenshot includes calls, voice/video controls, meetings, or conferencing, clarify that those parts may belong outside Chat messaging scope and may require Nexconn Call or support consultation.

4. **Integration Surface Breakdown**
   - Explain the user flow: trigger, intermediate states, confirmation/cancel path, final outcome, and any privacy or permission implications.
   - Identify the likely integration surface: message action menu, composer/input extension, conversation list item, message cell rendering, channel header, member list, notification handling, SDK event listener, custom message type, message extension metadata, or app-server API.
   - Call out sender privacy, recipient validation, message attribution, auditability, moderation, and user trust concerns when relevant.

5. **Verification Requirements**
   - For analysis-only requests, do not generate code unless the user asks to implement.
   - If the user asks to implement the feature, then follow the Confirmation Gates in `../SKILL.md` before writing integration code.
   - Verify exact SDK APIs, component props, event handlers, and message fields from documentation, installed package source, or existing project code before implementing.
   - When proceeding to implementation with Chat UI, follow the "Screenshot-driven implementation" rules in `./integration-workflow.md` to ensure application chrome features are not skipped.

Default response shape for screenshot analysis:

```markdown
This image shows: [feature name]

Key features:

...
...
...
Corresponding SDK features in Nexconn Chat:

...
Integration considerations:

...
```

## Multi-screenshot batch processing

When the user provides 2 or more screenshots (a UI walkthrough, a competitor app set, a Mobbin curated set, etc.), do NOT apply the single-image template to every screenshot. Instead:

1. **Inventory in one table.** One row per screenshot: `Screen | Subject (≤ 5 words) | Tag`. Tags: `chat`, `auth`, `marketing`, `call`, `media`, `composer`, `menu`, `settings`, `other`.
2. **Discard pass.** Drop rows tagged `marketing` (e.g. landing pages) and any third-party brand chrome / watermarks (Mobbin, competitor logos). Note them once in the response, do not re-cite them.
3. **Auth split.** Move all `auth` rows into a single bullet: *"Login / signup / 2FA / QR-code-login screens are application-layer; the Chat SDK only consumes a server-issued Token. Will not be re-counted as Chat features."*
4. **Cross-skill split.** Move all `call` rows into an *Out-of-scope* section that explicitly suggests Nexconn Call (see SKILL.md *Out of scope*).
5. **Deduplicate.** Many screenshots show the same feature in different states (e.g. emoji picker open / closed, scheduled menu / scheduled list). Collapse them to one feature entry with a note about which states are visible.
6. **Then** produce ONE consolidated feature list. Each entry: `Feature | Source screen(s) | Layer (Built-in / Configurable / Constrained / Application chrome / Application-layer / Application-server / Pending review / Cross-skill / Out-of-scope) | Notes`. Use `./feature-pattern-map.md` to assign the layer.
7. STOP if the user did not explicitly ask for implementation. If they did, hand the consolidated list to `./integration-workflow.md` "Screenshot-driven implementation" — that step will refine the gap table and run Confirmation Gates.

This batch workflow prevents the single-image template from ballooning into N pages of repeated analysis when the user just dropped a competitor app screenshot set.
