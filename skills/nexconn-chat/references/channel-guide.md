# Nexconn Chat Channel Guide

This document extends `SKILL.md` with detailed channel descriptions that are not suitable for persistent context. Read it only when the user asks about channel differences, the feature support matrix, specific scenario recommendations, or integration trade-offs.

## Terminology: channel deletion vs dissolve vs leave

These three operations are easy to confuse. Always disambiguate before recommending an API.

| Operation | Scope | Effect | Typical caller |
| --- | --- | --- | --- |
| Delete channel (per user) | Local to the current user | Removes the conversation from the current user's channel list and (depending on platform) clears the user's local message history. Other members are unaffected. | Any member |
| Delete-for-me (single message) | Local to the current user | Removes the message from the current user's local view only. | Sender or any member where supported |
| Delete-for-everyone (single message) | Server-side | Recalls the message for all members. Time and role limits apply. | Sender (within window), administrator |
| Leave channel | Server-side, current user only | Removes the current user from the channel membership. Other members keep the channel. | Any member |
| Dissolve channel | Server-side, all members | Tears down the channel for everyone. The channel ID is no longer usable. | Channel owner / administrator |

When a user says "删除会话 / delete the chat" and you are not sure which operation they mean, ask one short clarifying question before generating code.

## Terminology: channel pinning vs message pinning

Do not confuse these two "pin" operations:

| Operation | What it pins | Current skill baseline |
| --- | --- | --- |
| Channel pinning / stick-to-top | A conversation row in the channel list | Covered in the channel feature matrix below |
| Message pinning / pinned-message header | One or more messages inside a channel | Pending review unless verified in official docs or installed SDK |

If a screenshot shows a top banner like "Pinned Message", classify it as **message pinning**, not channel pinning. If no native SDK API is verified, implement the banner as application chrome backed by app-server state keyed by channel id and message id.

## Direct Channels

Suitable for one-on-one private chats, one-on-one customer support, and peer-to-peer user communication.

Core capabilities:

- Channel is automatically created when users send their first message to each other
- Supports 1-7 days of offline message storage, 7 days by default
- Supports offline push notifications
- Supports text, image, voice, video, and file messages
- Supports message deletion, reply, editing, and historical messages
- Supports unread count retrieval and clearing
- Supports recent conversation list, channel deletion, channel pinning, and do-not-disturb
- Supports local storage, search, read receipts, and blocklist
- Cloud messages are retained for 6 months by default

## Group Channels

Suitable for small teams, interest groups, customer support groups, and project team communication.

Core capabilities:

- Up to 3,000 members per group
- Users can join an unlimited number of groups
- Supports 1-7 days of offline message storage, 7 days by default
- Supports offline push notifications
- Supports text, image, voice, video, file messages, and @ mentions
- Supports message deletion, reply, editing, and historical messages
- Supports viewing read/unread member status
- Supports unread count retrieval and clearing
- Supports recent conversation list, channel deletion, channel pinning, and do-not-disturb
- Supports local storage and search; cloud messages are retained for 6 months by default
- Supports controlling whether new members can view message history from before they joined
- Supports channel creation, dissolution, adding/removing members, muting members, freezing channels, and targeted messages

## Community Channels

Suitable for large communities, gaming guilds, open source project collaboration, fan communities, and large enterprise organizations.

Core capabilities:

- Unlimited members
- Users can join up to 100 community channels
- Up to 50 sub-channels per community, with all sub-channels sharing the member list
- Supports offline push with configurable push types, e.g. push only on @ mentions
- Supports local storage
- Cloud messages are retained for 7 days by default, extendable
- Supports controlling whether new members can view message history from before they joined
- Supports message editing, recall, @ mentions, and do-not-disturb
- Supports muting members and freezing channels

## Open Channels

Suitable for live streaming chat rooms, real-time gaming chat, online forum discussions, temporary event chats, and real-time Q&A interactions.

Core capabilities:

- Unlimited members
- No offline messages; only online users receive messages
- No push notifications
- Local messages are cleared when the user leaves the channel
- Cloud messages are retained for 2 months
- Supports retrieving participant information, up to 500 people
- Supports muting specific participants or global muting
- Supports banning members, kicking out, and restricting re-entry
- Supports channel freezing
- Supports low-priority messages that can be dropped first under high load
- Supports priority message types to protect specific message types from being dropped
- Participants automatically exit after 30 seconds offline, timed from the first new message
- Up to 100 custom metadata key-value pairs per channel

### Telegram-style "Channel" ≠ Nexconn Open Channel

When a user's mockup or product reference shows a "broadcast Channel" pattern (Telegram Channel, WeChat 公众号-style one-way feed, Discord announcement channel), do NOT map it directly to a Nexconn Open Channel. The semantics differ:

| Concern | Telegram-style Channel | Nexconn Open Channel |
| --- | --- | --- |
| Persistence | Persists offline; users see history when they come back | Online-only; no offline messages |
| Push notifications | Yes | No |
| Unread count across sessions | Yes | No |
| Reliability | Standard delivery | Low-priority messages may be dropped under high load |
| Membership cap | Unlimited | Unlimited |
| Send permission | Restricted to admins | Anyone (configure with mutes / freezes) |

If the user really wants a Telegram-style broadcast feed, recommend a **Group Channel with role-based send permission** (only admins can send) instead of Open. Use Open only when the user explicitly accepts the online-only / no-push constraint (e.g. live event chat, gaming room).

## Feature Comparison

| Feature | Direct | Group | Community | Open |
| --- | --- | --- | --- | --- |
| Member limit | 2 | 3,000 | Unlimited | Unlimited |
| Offline message storage | 7 days | 7 days | Not supported | Not supported |
| Offline push notifications | Supported | Supported | Configurable | Not supported |
| Local storage | Supported | Supported | Supported | Cleared on leave |
| Cloud retention | 6 months | 6 months | 7 days, extendable | 2 months |
| Message editing | Supported | Supported | Supported | Not supported |
| Message copy | Supported | Supported | Supported | Supported |
| Message sending | Supported | Supported | Supported | Supported |
| Message forwarding | Supported | Supported | Supported | Not supported |
| Message reply | Supported | Supported | Supported | Not supported |
| Message read status | Supported | Supported | Not supported | Not supported |
| Delete for everyone | Supported | Supported | Supported | Supported |
| Delete for me | Supported | Supported | Supported | Not supported |
| View message history | Supported | Supported | Supported | Not supported |
| @ mentions | Not supported | Supported | Supported | Not supported |
| Get channel unread count | Supported | Supported | Supported | Not supported |
| Clear channel unread count | Supported | Supported | Supported | Not supported |
| Get channel list | Supported | Supported | Supported | Not supported |
| Delete channel | Supported | Supported | Supported | Not supported |
| Channel do-not-disturb | Supported | Supported | Supported | Not supported |
| Channel pinning | Supported | Supported | Supported | Not supported |
| Sub-channels | Not supported | Not supported | Up to 50 | Not supported |
| Add/remove channel members | Not supported | Supported | Supported | Supported |
| Channel member list | Not supported | Supported | Supported | Supported |
| Channel administrators | Not supported | Supported | Supported | Not supported |
| Dissolve channel | Not supported | Supported | Supported | Supported |
| Message reliability | 100% | 100% | 100% | Low-priority messages may be dropped under high load |

## Common Combinations

| Scenario | Recommended Combination |
| --- | --- |
| Social app | Direct for private chats, Group for small groups, Community for large themed communities |
| Live streaming platform | Open for live room chat rooms, Direct for private messages, Group for fan groups |
| Enterprise collaboration | Direct for colleague private chats, Group for project/department groups, Community for company-wide groups |
| Gaming app | Open for real-time battle chat, Group for team chat, Community for guilds |
| Customer support system | Direct for one-on-one consultations, Group for multi-agent collaboration |
