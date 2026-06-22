# Nexconn Chat Integration Workflow

This file is loaded when the request is classified as **Integration** in SKILL.md's triage workflow. Terminology normalization and scope check are already complete at this point.

## Execution Steps

1. Project identification — infer platform/SDK from project files, then read the matching platform file under `references/platform-setup/`
2. Confirmation gates — confirm what cannot be inferred
3. Documentation & code verification — fetch official docs, then confirm with installed code
4. Implementation — generate code following rules below
5. Testing & verification — provide verification steps
6. Final todo handling — output implemented/unimplemented summary

## Project Identification

Inspect local project files before asking the user when the platform or SDK can be inferred:

| Platform | Files To Check |
| --- | --- |
| Android | `build.gradle`, `settings.gradle`, Gradle module files |
| iOS | `Podfile`, `*.xcodeproj`, `Package.swift` |
| Web | `package.json`, `tsconfig.json`, framework config files |
| Flutter | `pubspec.yaml` |

Search project source, examples, installed SDK packages, and type definitions with `rg` to find:

- Existing Nexconn initialization or wrappers.
- Installed package names and versions.
- Existing Chat UI customization points.
- Existing token fetching logic.
- Existing localization and UI copy conventions.

If the project stack cannot be identified from files, ask one concise question.

Once the platform is identified, read the matching file under `references/platform-setup/` (`web.md` / `android.md` / `ios.md` / `flutter.md`; index at `platform-setup/index.md`) before confirming SDK/channel choices. Those files are navigation only — a doc-path index plus cross-doc difference flags. For what you can promise per channel, cross-check the *Chat UI channel coverage* matrix in SKILL.md (the source of truth).

## Confirmation Gates

Required inputs before writing integration code: **Platform**, **SDK selection**, **Channel type**, and **Business scenario**.

Infer from project files first (see Project Identification above). If a missing value can be inferred from project files or the user's wording, state the inference. If it cannot be inferred, ask the user.

- From the skill root, read `references/channel-guide.md` when limits, feature support, or tradeoffs matter.
- Do not repeat questions for information the user already gave.
- If multiple channel types are needed, recommend a combination and explain the responsibility of each.
- If the project already has Nexconn Chat integration code (initialization, connection, channel usage), treat existing choices as confirmed. Only ask about values that are new or changing.

**Credential gate**:
- App Key and Token are required for runnable initialization and connection code.
- Never put App Secret, signing logic, or privileged Token-generation code in client-side code.
- If App Key is missing, ask for it or provide a clearly marked non-runnable scaffold.
- If Token is missing, wire the client to a server-provided Token value or a placeholder marked as pending.

## Documentation And Code Verification

**MANDATORY: Documentation-first rule**

Before reading installed SDK source code, type definitions, or package internals, you MUST first:

1. From the skill root, search `references/llms.txt` (use `rg` or read in segments) for the relevant integration guide or quickstart path.
2. Run `bash scripts/fetch-docs.sh <path>` from the skill root to cache the guide under `references/cache/`. Add `--force` before the path only when the cached file must be refreshed.
3. Read the cached guide under `references/cache/` to understand the overall integration workflow, initialization sequence, and component usage.

Only AFTER reading the official guide, use installed SDK code or type definitions to confirm exact signatures, imports, props, event names, and version-specific details.

Do NOT reverse-engineer integration flow from type definitions or SDK source alone.

- Prefer integration guides/playbooks over full API references for workflows.
- If documentation and code disagree, prefer installed SDK/code for implementation details, mention the conflict briefly, and keep the implementation compatible with the project version.
- If no source confirms a detail, do not invent it. Fetch the relevant documentation, inspect installed packages, ask a clarifying question, or mark it pending review.

## Implementation Rules

Follow existing project code style, directory structure, state-management patterns, and UI conventions.

For Chat SDK custom UI:

- Wire initialization, connection, channel creation/opening, message send/receive, listeners, and cleanup according to verified SDK APIs.
- Keep UI state and product policy checks in the application layer when they are not SDK-enforced.
- Include basic error handling and visible loading/error states where the surrounding app pattern supports them.

For Chat UI:

- Prefer documented extension points, hooks, theme/custom view APIs, or component overrides.
- Keep custom filtering or rendering separate from underlying message/channel synchronization unless the SDK explicitly supports altering sync scope.
- Set Chat UI language to `en_US` by default unless the user requests another language or the project convention says otherwise.

Screenshot-driven implementation (Chat UI):

When the user provides a screenshot or mockup as the target UI and selects Chat UI:

0. If the input is a *bundle* of 2+ screenshots, first complete the *Multi-screenshot batch processing* steps in `./image-analysis-guide.md` (inventory → discard brand/marketing → split auth → split call → deduplicate). Use `./feature-pattern-map.md` to assign the layer for every modern-IM feature (self chat, scheduled, reactions, stickers, voice, link preview, folders, presence, anonymized forward, bot accounts). Only then proceed to step 1.

1. Produce a single feature gap table with a "Category" column classifying every visible feature. Use this format:

   | Feature | Category | Notes |
   | --- | --- | --- |
   | Channel list, message bubbles, input area | Built-in | Chat UI renders without configuration |
   | Message menu items, input toolbar actions | Configurable | Via hooks, menus, switches, theme, or extension points |
   | Bubble background color (per role) | Configurable | Style token / theme / bubble configuration |
   | All bubbles left-aligned in Chat UI Web | Constrained | Layout direction may be locked by the Web Component; use Chat SDK for full structural control |
   | Search bar, tab filters, online status | Application chrome | Must be implemented by the application around `nc-chat-ui-app-provider` |
   | Scheduled sending, link preview enrichment, saved-message store | Application-server | Requires app backend state or jobs; do not invent client SDK APIs |
   | Reactions, message pinning, presence | Pending review | Fetch docs or inspect installed SDK before promising |
   | Voice messages (Web) | Unsupported | Chat UI capability matrix explicitly marks as not supported |

   Category definitions:
   - **Built-in**: Chat UI renders without configuration.
   - **Configurable**: Chat UI supports via hooks, menus, switches, theme, or extension points.
   - **Constrained**: A subset of the visual is reachable (colors, sizes, copy, density), but layout direction, DOM hierarchy, or interaction model is locked by Chat UI Web Components. If the user requires a structural change (e.g. all bubbles left-aligned, swap of avatar/name positions, custom message lifecycle), recommend either accepting the locked layout or migrating that surface to Chat SDK.
   - **Application chrome**: Must be implemented by the application around `nc-chat-ui-app-provider` (Web). On Android/iOS the equivalent is the host activity/view-controller surrounding the Chat UI fragment/controller.
   - **Application-server**: Requires backend state, jobs, enrichment, role checks, or privileged sends. The client may render the result, but the SDK does not own the product workflow.
   - **Pending review**: Capability is visible in the mockup but not confirmed by cached docs or installed SDK. Fetch docs or mark as TODO before implementation.
   - **Unsupported**: Chat UI capability matrix explicitly marks as not supported on the target platform.

2. Present the gap table to the user for scope confirmation before writing code. For every `Constrained` and `Unsupported` row, surface the trade-off explicitly so the user can choose between (a) accepting the limitation, (b) escalating that surface to Chat SDK, or (c) dropping the requirement.
3. Implement all confirmed categories: mount the provider, apply configuration, AND build application chrome components. Do NOT leave only the bare provider mounted.
4. For unsupported items, inform the user explicitly and skip — do not silently omit or invent workarounds.

For all integrations:

- Default generated product UI and interaction copy to English unless instructed otherwise or the project already standardizes on another locale.
- Set `NCEngine.initialize` or platform equivalent log level to Debug by default for integration verification.
- Remind the user to switch to a higher log level such as WARN or ERROR before production.
- Never place App Secret, signing logic, or privileged Token-generation code in client-side code. Read `references/credentials-and-token.md` for credential handling.

## Testing And Verification

Provide concrete verification steps after implementation or in a detailed implementation plan:

- Build or typecheck the project when an appropriate command is known.
- Verify initialization succeeds and logs are visible.
- Verify Token acquisition or placeholder injection path.
- Verify user connection and disconnect/reconnect behavior.
- Verify the selected channel type works for the scenario.
- Verify offline message, push, unread count, read receipt, mention, custom message, or moderation behavior only when relevant to the request.
- Verify UI behavior on desktop and mobile for Web UI changes.
- Explain common troubleshooting paths such as invalid App Key, expired Token, wrong channel type, missing listener cleanup, or unsupported SDK surface.

## Final Todo Handling

After generating integration code, output a structured summary containing both an implemented features list and a TODO/unimplemented features list.

### Implemented Features List

List all features that were successfully implemented in this generation, grouped by category:

- **Built-in**: Chat UI features that work without additional configuration after mounting.
- **Configurable**: Features enabled through Chat UI hooks, menus, switches, theme, or extension points.
- **Application chrome**: Custom UI components built around `nc-chat-ui-app-provider` (search bar, tab filters, header, layout, etc.).
- **Application-server**: Backend-owned features that were wired to the UI, such as token endpoints, scheduled send queues, link preview enrichment, or role checks.

### Unimplemented Features List

List features visible in the user's screenshot or requirements that were NOT implemented, with status and reason:

| Feature | Status | Reason |
| --- | --- | --- |
| (feature name) | Not implemented / Not supported / Out of scope / Pending review | (brief explanation) |

Use these status values:
- **Not implemented**: feasible but not included in this generation; can be added later.
- **Not supported**: Chat UI capability matrix explicitly marks as unsupported on the target platform.
- **Out of scope**: belongs to a different product (e.g., Nexconn Call) or requires server-side-only work.
- **Pending review**: capability is requested but not yet documented in this skill (e.g. message pinning, emoji reactions, presence/last-seen — capabilities absent from the `channel-guide.md` feature matrix; see also `references/feature-pattern-map.md`). Treat as application-layer with TODO until verified.

### Out-of-scope items (mandatory section)

Whenever the input mockup or screenshot bundle contained any of: voice/video calls, conferencing, live streaming, login/signup/2FA UI, third-party brand chrome, or any feature mapped to `Out-of-scope` / `Cross-skill` in `./feature-pattern-map.md`, output a separate *Out-of-scope items* section. For each item, state:

- What was visible (brief).
- Why it is out of scope for `nexconn-chat` (e.g. requires Nexconn Call SDK, requires application auth flow, third-party branding).
- Where the user should look next (Nexconn Call docs, their own auth provider, etc.).

Do NOT mix out-of-scope items into the *Not supported* row — that row is only for things Chat UI explicitly does not support on the target platform. Mixing them gives the user a false expectation that Nexconn Chat will eventually ship those features.

### TODO Checklist

Create a final checklist using the available todo tool if one exists; otherwise include a short pending list in the final answer.

Include pending items for:

- Replacing placeholder App Key or Token values.
- Implementing or connecting the app-server Token endpoint.
- Implementing real data for `ServiceHooks` (user profiles, group profiles, members).
- Scan all generated code for hardcoded mock/placeholder data (string literals, static arrays, dummy return values, empty strings used as URLs, fixed numeric values like `memberCount: 0`). For each occurrence, generate a TODO item listing the file, the mock value, and what real data source should replace it.
- Reviewing any SDK detail that could not be verified.
- Switching Debug logs to a production log level.
- Running build/test commands that could not be run.
- Any unimplemented feature that the user may want to add next.

Mark pending user actions as pending, not completed.

## Common Issue Handling

| Issue | How To Handle |
| --- | --- |
| User unsure about channel type | Ask about business scenario, recommend channel combination, explain rationale |
| User uses non-standard or ambiguous terminology | Normalize against Chat/Call glossaries first; ask if mapping is unclear |
| User need exceeds Chat scope | Clarify scope, handle only Chat messaging part, suggest support for non-Chat capability |
| Local documentation insufficient | Find path in `references/llms.txt`, run `bash scripts/fetch-docs.sh <path>` from the skill root, use `--force` only when refreshing stale cached docs, read cached doc under `references/cache/` |
| API/component detail missing from docs but visible in code | Use project code, SDK source, or type definitions; mention source if non-obvious |
| Project tech stack cannot be identified | Ask platform/language or request config path |
| `llms.txt` is too large | Search it with `rg` or read in segments |
| User needs multiple channel types | Recommend a combination and explain data isolation/responsibility |
