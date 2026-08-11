# Nexconn Chat Integration Skill

A coding agent skill for rapid [Nexconn Chat](https://www.nexconn.ai/product/chat) integration. This skill guides AI coding assistants through the complete integration workflow: channel type selection, SDK vs. UI decision-making, platform-specific setup, credential management, push notification configuration, and common integration patterns.

**Supported platforms:** Android, iOS, Web, Flutter

## Quick Links

- [Sign up](https://console.nexconn.ai/agile/register?utm_source=ConsolegithubChatSDKSkills) to get a Nexconn App Key
- [Documentation](https://docs.nexconn.ai/)
- [Demo app](https://www.nexconn.ai/demos/chat)
- [Chat UI](https://www.nexconn.ai/product/chat#ui-showcase)

## Use Cases

With the Nexconn Chat component library, you can build a variety of chat experiences, including:

- Livestream chat like Twitch or YouTube
- Team collaboration chat like Slack
- Messaging experiences like WhatsApp or Facebook Messenger
- Customer support chat like Drift or Intercom

## Nexconn Chat Integration Guide

Start with the [Nexconn Chat documentation](https://docs.nexconn.ai/). It guides you through SDK initialization, user connections, conversation management, and sending and receiving messages.

This Skill recommends Direct, Group, Community, or Open Channels based on your use case and helps you choose between the ready-to-use Chat UI and the deeply customizable Chat SDK.

## Core Features

- **User Management**: Centrally manage user profiles and relationships, with blocking and banning to help maintain a healthy community.

- **User Presence**: Track online, offline, and custom user states in real time for more timely communication.

- **Message Read Receipts**: Synchronize read state across devices so senders can immediately confirm that a message was read.

- **Rich Message Types**: Built-in support for text, emojis, images, audio, video, files, and custom messages.

- **Message Operations**: Send, delete, edit, reply to, and forward messages, with message history and search.

- **Real-time Webhooks**: Receive real-time message, user, and group events to capture user activity accurately.

- **Broadcast Announcements**: Target all users, online users, users with specific tags, or selected users for precise delivery.

- **Moderation & Safety**: Intelligently moderate message content and identify risks in real time to keep conversations safe.

## Installation

Install the Nexconn Chat Skill with the Skills CLI:

```bash
npx skills add https://github.com/NexconnAI-Dev/nexconn-skills.git --skill nexconn-chat
```

## Quick Start

After installation, ask your coding agent to use the `nexconn-chat` Skill for your integration task. For example:

> Use the `nexconn-chat` Skill to integrate Nexconn Chat into this project.

For a more tailored integration, include your target platform and chat scenario.

## Usage

When integrating Nexconn Chat, use this Skill in the following order:

1. Identify the target platform and existing SDK state from the project files.
2. Choose a Channel type based on member count, message persistence, and real-time requirements.
3. First evaluate whether Chat UI meets your needs; use Chat SDK for custom interfaces or Channel types not covered by Chat UI.
4. Confirm the initialization, connection, and messaging flow in the official documentation, then verify the exact APIs against the installed SDK.
5. Use the App Key for client initialization. Keep the App Secret, signing logic, and Token generation on the server.

### Channel Selection

| Use case | Recommended Channel | Key features |
| --- | --- | --- |
| One-to-one private conversations | Direct Channel | Offline messages and push notifications |
| Small teams, interest groups, and customer support | Group Channel | Up to 3,000 members |
| Large communities, forums, guilds, and organizations | Community Channel | No member limit; supports sub-channels |
| Livestream chat and temporary events | Open Channel | Online-only messages for high-concurrency real-time interaction |

See the [Channel Guide](https://docs.nexconn.ai/guides/realtime-chat/intro-chat/im-feature-basic.md) for a complete capability comparison.

## Contributing

Contributions are welcome. Before opening an issue or pull request:

- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) for reproducible problems.
- Use the [Pull Request template](.github/PULL_REQUEST_TEMPLATE.md) when proposing documentation, skill, or example changes.
- Add or update tests where appropriate, preserve existing API behavior, and describe user-facing changes clearly.

## License

This project is licensed under the [Apache License 2.0](LICENSE).
