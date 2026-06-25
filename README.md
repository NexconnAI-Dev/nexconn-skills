# Nexconn Skills

A collection of Nexconn AI skills for quickly integrating Nexconn platform capabilities.

## 📦 Available Skills

### nexconn-chat

An instant messaging (IM) integration skill supporting direct messages, group chats, community channels, open channels, and more.

**Trigger conditions:**
- User mentions Nexconn Chat or adding chat/messaging features
- Implementing instant messaging or building a chat application
- Asking about channel types or messaging capabilities

**Supported platforms:**
- Android / iOS / Web / Flutter

**Core capabilities:**
- ✅ Direct Channels - one-on-one private conversations
- ✅ Group Channels - small team collaboration (≤3,000 members)
- ✅ Community Channels - large communities and forums (no member limit)
- ✅ Open Channels - live chat rooms, real-time interaction
- ✅ Offline messages and push notifications
- ✅ Chat SDK (custom UI) and Chat UI (out of the box)

**Quick start:**
```bash
# View the skill documentation
cat skills/nexconn-chat/SKILL.md

# Fetch the latest official docs
bash skills/nexconn-chat/scripts/fetch-docs.sh <path>
```

## 🚀 Usage

### Prerequisites

1. **Get your App Key and App Secret**
   - Log in to the [Nexconn Console](https://console.nexconn.ai/agile/apps/list)
   - Create a new app or select an existing one
   - Copy the **App Key** and **App Secret**

2. **Get a Token (access token)**
   - The Token must be obtained through a server-side API
   - During testing, you can fetch it manually using the [Postman Collection](https://docs.nexconn.ai/platform-chat-api/explore-api-with-postman)

### Integration example

```javascript
// Example configuration (placeholders, replace with your own values)
// App Key comes from the Nexconn Console; the Token must be returned by your server-side API. Never put the App Secret in the client.
const appKey = import.meta.env.VITE_NEXCONN_APP_KEY ?? 'YOUR_APP_KEY';
const token = await fetchTokenFromYourServer(); // Issued server-side, e.g. a string like 'xxxx@xxx.rongnav.com;xxx.rongcfg.com'

// Initialize the Chat SDK
// Refer to the docs for your target platform for the actual integration code
```

> ⚠️ Security rule: **Do not** commit real Tokens, App Secrets, or signing material to your repository. During testing, you can use the [Postman Collection](https://docs.nexconn.ai/platform-chat-api/explore-api-with-postman) to fetch a one-time Token manually.

## 📚 Documentation structure

```
nexconn-skills/
├── skills/
│   └── nexconn-chat/
│       ├── SKILL.md                    # Main skill documentation
│       ├── references/
│       │   ├── channel-guide.md        # Detailed channel type comparison
│       │   ├── llms.txt                # Official documentation index
│       │   └── cache/                  # Cached remote docs
│       └── scripts/
│           └── fetch-docs.sh           # Documentation download script
└── example/
    └── web/
        └── react/                      # React integration example
```

## 🎯 Channel selection guide

| Use case | Recommended channel | Key features |
| --- | --- | --- |
| One-on-one private conversations between users | Direct Channels | Offline messages, push notifications |
| Small teams, interest groups, support groups | Group Channels | ≤3,000 members |
| Large communities, forums, guilds, organizations | Community Channels | No member limit, supports sub-channels |
| Live chat rooms, real-time interaction, temporary events | Open Channels | Online-only, high concurrency |

For a detailed capability comparison, see [skills/nexconn-chat/references/channel-guide.md](skills/nexconn-chat/references/channel-guide.md)

## 📖 Related resources

- [Nexconn official documentation](https://docs.nexconn.ai/)
- [Nexconn Console](https://console.nexconn.ai/)
- [Contact support](https://www.nexconn.ai/contact-us)
