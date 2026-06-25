# Nexconn Chat Application-Layer Rules

This file is loaded when the user request includes time-window, character-limit, role-based gating, or trigger-rule logic that is **not enforced by the Chat SDK or Chat UI itself**. The skill must implement these checks in the application layer, often combined with a server-side rule for tamper-resistance.

Use this guide to:
- Recognize which requirements are application-layer (versus SDK-enforced).
- Pick the right enforcement layer (client-only, client + server).
- Avoid common pitfalls (treating client checks as authoritative, mis-using recall as edit, etc.).

## Quick classification

| Requirement | SDK-enforced? | Recommended layering |
| --- | --- | --- |
| "Within X minutes the sender can edit the message" | ❌ | Client-side gate for UX + server-side validation for tamper resistance |
| "Within X minutes the sender can recall (delete-for-everyone)" | ⚠️ Some platforms expose a default window; verify in cached docs | Use SDK default if it matches; otherwise wrap with application rule |
| "Only admins can pin / mute / freeze" | ⚠️ Group/Community administrators are SDK roles, but custom role mappings are app-layer | Map app roles to Nexconn roles; gate UI in app, validate in app server |
| "Message text must be ≤ N chars" | ❌ | App-layer validation in composer; server-side validation if you sign messages |
| "Cannot @ more than N users" | ❌ | App-layer validation in composer |
| "Double-tap avatar = @user" | ❌ | App-layer interaction wired to Chat UI mention insertion API |
| "Click name = @user" | ❌ | App-layer interaction; same as above |
| "Custom message contains user-card payload" | ✅ via custom message types | Register custom message type; render in UI; payload schema is app-defined |
| "Hide channels of type X from the conversation list" | ❌ | App-layer filter on channel list query/render; do NOT alter sync scope |
| "Show 'Read by N / Unread N' next to message" | ✅ for Direct/Group | Use SDK read-receipt API for data; app-layer renders the format |

## Edit window pattern

A common request: "let the sender edit a text message within 1 hour after sending succeeds."

Layering:

1. SDK provides message edit/update API and exposes `sentTime` (or equivalent) on the message.
2. Application layer:
   - On long-press / edit menu trigger, check `now - sentTime < 60 * 60 * 1000`. If false, hide or disable the menu item.
   - On confirm, call the SDK edit API with the new content.
   - When rendering, show an "edited" badge if the message has an edit timestamp (SDK usually exposes `updatedAt`).
3. Application server (recommended for tamper resistance):
   - When you sign or audit messages on the server, reject updates whose original `sentTime` is older than the policy window.

Pitfalls:
- Do not implement the window as "send a recall + send a new message" — this loses message identity, ordering, and read-state.
- Do not rely on the client clock alone for the cutoff — fall back to a server timestamp where possible.
- For multi-device clients, after editing succeeds, push the updated message through the SDK's standard message-update event so other devices re-render.

## Recall (delete-for-everyone) window pattern

Most users mean "let the sender unsend a message within X minutes."

Layering:

1. Verify the SDK's default recall window for the target platform / channel type from cached docs.
2. If the user's window matches the default, use the SDK API directly.
3. If the user's window is shorter, gate the UI menu in the application layer the same way as the edit window.
4. If the user's window is longer, request a Nexconn-side configuration change — do not "fake" recall in the client (it cannot tamper with peers' local history).

## @ mention trigger patterns

The SDK supports mention metadata on the sent message; the *trigger* is application-defined.

Common triggers:
- Type `@` in the composer → show a member picker.
- Click a user name in the message list → insert `@<name>` into the composer.
- Double-tap a user avatar → insert `@<name>` into the composer.
- Long-press a user avatar → quick reaction menu including `@`.

Implementation rules:
- Always store the mention as structured metadata on the outbound message (mentioned user IDs, plus the literal text), not just as plain text. Otherwise downstream features (mention notifications, "@me" filter) will break.
- Only enable mention triggers in channel types that support mentions (Group ✅, Community ✅, Direct ❌, Open ❌); see the channel feature matrix at [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic).
- For Chat UI Web, prefer the documented mention insertion API rather than directly mutating the composer DOM.

## Channel-list filtering pattern

When the product wants to show only some channel types (e.g. only Group), keep filtering at the **render layer**, not the **sync layer**.

- ✅ Filter the channel list query result before rendering.
- ✅ Hide unwanted channel rows in the Chat UI conversation list via the documented hook.
- ❌ Do not delete the underlying channels to make them disappear.
- ❌ Do not unsubscribe from message events for the hidden channels — unread counts and notifications will silently break.

If the user's intent is "really get rid of those channels" (not just hide), confirm whether they mean leave-channel or dissolve-channel (see the [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic) terminology section).

## Avatar / bubble visual rules

Pure visual changes (square avatar with rounded corners, bubble color per role, density) are application-layer:

- For Chat UI: prefer theme tokens, CSS variables, and documented cell/component customization points.
- For Chat SDK custom UI: implement directly in your own components.
- Layout *direction* (left/right alignment) is often locked by Chat UI Web Components — see the *Constrained* category in `integration-workflow.md`.

## Verification rule

For every application-layer rule you implement, add a verification step to the testing list:

- Bypass the client check via a tampered request and confirm the server rejects it (when applicable).
- Multi-device: confirm that an edited / recalled message updates on every signed-in client.
- Channel-type sensitivity: confirm the rule does not silently apply to channel types that do not support the underlying SDK feature.

## See also

For broader feature → layer mapping (self chat, scheduled send, reactions, stickers, voice messages, link preview, folders, presence, anonymized forward, bot accounts), load `./feature-pattern-map.md`. This file (`application-layer-rules.md`) covers *time-window / role-gated / trigger-rule* policies; `feature-pattern-map.md` covers *which layer owns each common IM feature*.
