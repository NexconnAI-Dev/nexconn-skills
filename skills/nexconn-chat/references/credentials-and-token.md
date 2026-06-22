# Nexconn Chat Credentials And Token Guide

Read this file before handling App Key, App Secret, Token, Postman testing, placeholder credentials, or client/server security boundaries.

## Table Of Contents

- Required credentials
- App Key handling
- Token handling
- Placeholder policy
- Postman testing path
- Security boundaries

## Required Credentials

Nexconn Chat runtime integration needs:

- App Key: application identifier used by the client SDK.
- Token: user identity credential used to connect to Nexconn messaging services.
- App Secret: server-side secret used for signing or privileged server API calls. It must never be exposed in client-side code.

App Key and Token are required for runnable initialization and connection code. Missing credentials do not block architecture discussion, code review, project inspection, documentation lookup, or non-runnable scaffolding that is explicitly marked as using placeholders.

### Login UI is application-layer (not SDK)

When a user's mockup, screenshot, or feature list mentions login forms (phone number entry, country code picker, password entry, 2FA / OTP, QR-code login, "keep me signed in"), classify those screens as application-layer and OUT of `nexconn-chat` scope. The Chat SDK only consumes a server-issued **Token**; it does not provide:

- Login screens or sign-up screens.
- Password / 2FA / OTP verification flows.
- QR-code login pairing.
- Session persistence UI ("keep me signed in" toggle).

Recommended split:
- The application owns its auth provider (your app server, OIDC/OAuth, custom SMS/email OTP, etc.).
- After auth succeeds, the app server issues a Nexconn Token bound to the authenticated user id.
- The client passes that Token to `NCEngine.connect` / platform equivalent.

Never invent SDK login APIs to match a competitor's screenshot.

## App Key Handling

If the user has not provided an App Key, guide them to obtain one:

```markdown
Please provide your Nexconn App Key. If you don't have one yet:

1. Log in to [Nexconn Console](https://console.nexconn.ai/agile/apps/list)
2. Create a new application or select an existing one
3. Copy the App Key from the application details page

Security note: App Secret is only for server-side signing and must never be exposed in client-side code.
```

If the user directly asks for runnable initialization or connection code but says they do not have an App Key, ask for the App Key first. Do not present placeholder initialization as runnable.

If the user explicitly wants a non-runnable scaffold, use a visible placeholder such as `YOUR_APP_KEY`, label it as pending, and include a final pending item identifying the file where it must be replaced.

## Token Handling

Token must be obtained through a server-side API flow. Do not generate frontend/mobile code that signs requests with App Secret or calls privileged Token APIs directly from the client.

For server-side Token acquisition API details:

1. From the skill root, find the corresponding documentation path in `./references/llms.txt`.
2. From the skill root, run `bash scripts/fetch-docs.sh <path>` or adjust the relative path to the current working directory.
3. Read the cached Markdown under `./references/cache/`.
4. Use the official documentation for signing, parameters, examples, and security requirements.

If the user's app already has a server Token endpoint, wire the client to that endpoint or to the existing server-provided variable. Do not replace server-issued Tokens with hardcoded test values.

If the user has not provided a Token but asks for client integration, prefer a placeholder such as `YOUR_TEST_TOKEN` or a clearly named injected variable such as `chatToken`, then include a final pending item to obtain or wire the real Token.

## Placeholder Policy

Use this decision rule:

| Situation | Behavior |
| --- | --- |
| User asks for advice, plan, or architecture | Proceed without credentials and list credential prerequisites |
| User asks for code and accepts placeholders | Generate clearly non-runnable scaffold with placeholders and final pending tasks |
| User asks for runnable initialization/connection code and App Key is missing | Ask for App Key first; do not generate runnable initialization code |
| Token is missing but App Key exists | Wire to server-provided Token source if available; otherwise use a marked placeholder and pending task |
| User wants client-side App Secret signing | Refuse that implementation and provide a safe server-side or Postman testing alternative |

## Postman Testing Path

If the project has no app server yet and the user wants to verify a demo quickly:

- Explain that production Tokens must come from an app server.
- Suggest the official Postman Collection for manually obtaining a test Token: https://docs.nexconn.ai/platform-chat-api/explore-api-with-postman
- Remind the user not to commit real Tokens, App Secret, or signed request material.

## Security Boundaries

Never generate code that:

- Places App Secret in Web, Android, iOS, or Flutter client code.
- Performs privileged server-side signing directly in a browser or mobile app.
- Logs App Secret, Token, signed request payloads, private image URLs, or sensitive message contents.
- Treats a test Token or manually copied Token as a production authentication design.

Acceptable patterns:

- Client receives Token from the app server after app authentication.
- Client uses an environment-injected App Key when the framework supports safe public configuration.
- Demo code uses explicit placeholders with pending replacement tasks.
- Server-side snippets keep App Secret in environment variables or secret storage.
