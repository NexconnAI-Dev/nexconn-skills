# Chat UI Source Repositories

This document lists the Chat UI source repositories for each platform. Use it to obtain the source code when reaching Layer 4, "Source Code Modification Assessment," of the [SDK Integration Decision Framework](./sdk-integration-decision-framework.md).

## Web

**Repository**: `https://github.com/NexconnAI-Dev/nexconn-chatui-web.git`

## Android

**Repository**: `https://github.com/NexconnAI-Dev/nexconn-chatui-android.git`

## iOS

**Repository**: `https://github.com/NexconnAI-Dev/nexconn-chatui-ios.git`

## Flutter

**Repository**: `https://github.com/NexconnAI-Dev/nexconn-chatui-sdk-flutter.git`

## Usage

### When to Use This Document

When the SDK Integration Decision Framework reaches Layer 4, "Source Code Modification Assessment," obtain the Chat UI source code for the target platform:

1. Find the relevant section based on the integration project's platform (Web, Android, iOS, or Flutter).
2. Clone the source code locally using the repository URL, or fork it to the team's repository.
3. Make and test the required customizations locally.
4. Record the modified files and the reasons for each change to simplify migration during future version upgrades.

### How to Obtain the Source Code

You can clone the source repository directly into the project root or into the team's designated dependency directory. `chat-ui-source` is only an optional directory for centrally managing source code in multi-platform projects; it is not an integration requirement.

```bash
# Run from the project root
cd /path/to/your/project

# Clone the repository for the target platform (Android in this example)
git clone https://github.com/NexconnAI-Dev/nexconn-chatui-android.git

# Alternatively, fork it to the team's repository and then clone the fork
git clone <your-forked-repo-url>

# Enter the repository directory
cd nexconn-chatui-android

# View available branches and versions
git branch -a
git tag

# Create a custom branch (naming format: custom/chat-ui-<platform>-<feature>)
git checkout -b custom/chat-ui-android-your-feature
```

To store source code for multiple platforms in one place, set the clone destination to `chat-ui-source/<repository>`. Git creates the repository directory, but the parent directory must already exist:

```bash
git clone https://github.com/NexconnAI-Dev/nexconn-chatui-android.git chat-ui-source/nexconn-chatui-android
git clone https://github.com/NexconnAI-Dev/nexconn-chatui-ios.git chat-ui-source/nexconn-chatui-ios
```

**Example of an optional multi-platform directory structure**:
```
your-project/
├── src/                    # Your project source code
├── chat-ui-source/         # Optional: centrally stored Chat UI source code for multiple platforms
│   ├── nexconn-chatui-android/
│   ├── nexconn-chatui-ios/
│   └── nexconn-chatui-flutter/
└── package.json
```

The name of the source directory does not determine whether the integration will work. After cloning, you must still configure a Gradle module, Swift Package Manager/CocoaPods, or a Flutter `path`/`git` dependency, depending on the target platform.

### Important Notes

1. **Modify the source code only as a last resort**: Consider this option only when the first three layers—native capabilities, custom extensions, and Chat SDK APIs—cannot meet the requirements.
2. **Obtain explicit user approval**: Before modifying the source code, explain the impact and risks to the user and obtain their explicit approval.
3. **Document all changes**: Use Git branches to manage changes and describe the reasons for each modification in detail in commit messages.
4. **Plan for version upgrades**: After modifying the source code, reassess and migrate the changes when upgrading to future SDK versions.

## Related Documents

- [SDK Integration Decision Framework](./sdk-integration-decision-framework.md) - Detailed description of the five-layer decision process
- [Integration Workflow](./integration-workflow.md) - Complete integration workflow
