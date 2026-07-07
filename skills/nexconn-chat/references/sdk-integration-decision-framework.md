# SDK Integration Decision Framework

This document defines a five-layer decision process for integrating the Nexconn Chat SDK. It is designed to evaluate implementation paths systematically and ensure that requirements are met with the optimal approach.

## Decision Process Overview

Before implementing any integration code, evaluate the implementation path from top to bottom using the following five-layer decision process. Each layer is a fallback option to use only when the previous layer cannot meet the requirements.

## Layer 1: Assess Chat UI Native Capabilities

**Objective**: Prioritize the lowest-cost, out-of-the-box solution.

First, check whether Chat UI already provides an interface that meets the requirement. If Chat UI natively supports the feature, integrate it directly using the provided API or component without additional development.

**Evaluation criteria**:

- Whether the feature is explicitly listed in the Chat UI documentation
- Whether a corresponding API, component, or configuration option exists
- Whether the feature is available on the target platform

**If satisfied**: Integrate directly. This is the lowest-cost and most maintainable path.

**If not satisfied**: Proceed to Layer 2.

## Layer 2: Assess Chat UI Customization and Extension Capabilities

**Objective**: Implement the requirement through extension points within the Chat UI ecosystem.

When Chat UI does not directly provide the required feature, do not immediately drop down to the underlying SDK. First evaluate whether Chat UI exposes customization capabilities that can implement the requirement indirectly.

**Common extension capabilities**:

- Custom UI views/components
- Event callbacks and lifecycle hooks (hooks/listeners)
- Theme and style overrides
- Configuration options and feature flags
- Slots and render props

**Evaluation criteria**:

- Whether Chat UI provides relevant extension interfaces or hooks
- Whether the desired result can be achieved through these extension points
- Whether the implementation remains consistent with Chat UI's design patterns

**If satisfied**: Implement the feature using Chat UI's customization capabilities. This keeps the implementation within the Chat UI ecosystem and preserves compatibility with future version upgrades.

**If not satisfied**: Proceed to Layer 3.

## Layer 3: Assess the Chat SDK API Layer

**Objective**: Drop down to the underlying SDK and use Chat SDK APIs to supplement capabilities not wrapped by Chat UI.

If neither Chat UI nor its customization capabilities can meet the requirement, evaluate the underlying Chat SDK API layer. Determine whether Chat SDK provides the corresponding low-level functionality.

**Implementation strategies**:

- If Chat SDK provides the feature but Chat UI does not wrap it, develop the required functionality directly against the Chat SDK API.
- Combine Chat SDK capabilities with existing Chat UI components.
- Build a supplementary implementation layer on top of Chat UI.

**Evaluation criteria**:

- Whether the Chat SDK API documentation provides the feature
- Whether the feature can be used alongside Chat UI
- Whether the implementation complexity and maintenance cost are acceptable

**If satisfied**: Implement the feature using the Chat SDK API together with Chat UI. Clearly mark it in the code as a supplementary implementation to facilitate future maintenance.

**If not satisfied**: Proceed to Layer 4.

## Layer 4: Assess Source Code Modification

**Objective**: Evaluate the feasibility of implementing the requirement by modifying Chat UI source code.

If the Chat SDK also lacks the feature, the current SDK version does not support it through any official interface. At this point, evaluate whether modifying the Chat UI source code could provide the required functionality.

**Evaluation considerations**:

- Technical feasibility: whether the source code is available and the required modification points can be identified
- Scope of impact: whether the changes could affect other SDK features
- Maintenance cost: the cost of migrating the changes during future SDK upgrades
- Risk level: whether the changes could introduce stability or security issues

**Execution steps**:

1. Evaluate the technical feasibility and risks of modifying the source code.
2. Clearly explain to the user:
   - Why source code modification is necessary (the first three layers cannot meet the requirement)
   - The specific modification points and scope of impact
   - The resulting maintenance costs and upgrade risks
3. Explicitly ask whether the user accepts the source modification approach.
4. Wait for the user's explicit response before proceeding to Layer 5.

**Do not**: Modify the source code directly without explaining the impact to the user and obtaining confirmation.

## Layer 5: Final Decision

**Objective**: Determine the final implementation approach based on the user's feedback.

Based on the user's feedback in Layer 4, follow one of the decision branches below.

### Branch A: The User Approves Source Code Modification

- Obtain the Chat UI source code:
  - See [Chat UI Source Repositories](./chat-ui-repositories.md) for the Git repository URL for the target platform.
  - Clone the source code locally or fork it to the team's repository.
- Develop and customize the implementation in the local or forked repository.
- Implement the changes and perform comprehensive testing.
- Provide a change description document that includes:
  - The modified files and code locations
  - The reason for each change and the implementation logic
  - Considerations for future version upgrades

### Branch B: The User Does Not Approve Source Code Modification

Try to find a workaround that does not require source code changes:

- Revisit the requirement and determine whether it can be avoided through product design changes.
- Evaluate whether an application-layer wrapper can simulate a similar result.
- Explore other technical paths, such as native platform capabilities or WebView injection.

If a viable workaround is found, explain its trade-offs and limitations to the user, obtain approval, and then implement it.

### Branch C: No Viable Solution

If neither source code modification nor an alternative workaround is possible:

1. Clearly tell the user that the requirement cannot be implemented with the current SDK version.
2. Explain the specific technical limitations that prevent implementation.
3. Recommend one of the following actions:
   - Contact [Nexconn Technical Support](https://www.nexconn.ai/contact-us) to submit a feature request.
   - Adjust the product requirement to use an approach supported by the SDK's existing capabilities.
   - Wait for a future SDK version.

## Usage Recommendations

### Follow the Layered Order

Always begin with Layer 1 and do not skip layers. Even if a feature appears to obviously require source code changes, complete the evaluation for the first three layers because:

- The SDK may provide capabilities beyond your initial expectations.
- Extension points or configuration options may have been overlooked.
- The underlying API may already support the feature even if the documentation does not state it explicitly.

### Record the Decision Path

When implementing a solution, record the following in code comments or documentation:

- Which layers were evaluated
- Why the earlier layers did not meet the requirement
- Which layer's solution was ultimately selected
- Any ongoing maintenance considerations if the Layer 3 or Layer 4 approach was selected

### Prioritization Principles

- **Stability first**: Layer 1 and Layer 2 solutions are the most stable because they fall within the SDK's official support scope.
- **Maintainability first**: Avoid unnecessary source code changes; source modification should be the last resort.
- **Transparency first**: Fully explain and obtain approval for any decision involving source code modification or a fallback approach.

## Related Documents

- [Integration Workflow](./integration-workflow.md) - Complete integration workflow
- [Platform Setup Index](./platform-setup/index.md) - Platform-specific setup guides
- [Feature Pattern Map](./feature-pattern-map.md) - Mapping between features and implementation layers
- [Chat UI Source Repositories](./chat-ui-repositories.md) - Chat UI source repository configuration for each platform
