<template>
  <main class="app-shell">
    <section class="workspace">
      <aside class="sidebar">
        <div class="brand-block">
          <p class="eyebrow">Nexconn Chat</p>
          <h1>IM Console</h1>
          <p class="status" :class="statusTone">{{ connectionLabel }}</p>
        </div>

        <form class="connect-panel" @submit.prevent="connect">
          <label>
            <span>App Key</span>
            <input
              v-model.trim="form.appKey"
              autocomplete="off"
              placeholder="YOUR_APP_KEY"
              :disabled="isConnected || isConnecting"
            />
          </label>

          <label>
            <span>User Token</span>
            <textarea
              v-model.trim="form.token"
              autocomplete="off"
              placeholder="Paste a server-issued test token"
              rows="4"
              :disabled="isConnected || isConnecting"
            />
          </label>

          <button class="primary-button" type="submit" :disabled="isConnected || isConnecting">
            {{ isConnecting ? 'Connecting...' : 'Connect' }}
          </button>
          <button class="ghost-button" type="button" :disabled="!isConnected" @click="disconnect">
            Disconnect
          </button>
        </form>

        <form class="open-panel" @submit.prevent="openSelectedChannel">
          <div class="segmented" role="radiogroup" aria-label="Channel type">
            <button
              v-for="option in channelOptions"
              :key="option.value"
              type="button"
              :class="{ active: form.channelType === option.value }"
              :aria-pressed="form.channelType === option.value"
              @click="form.channelType = option.value"
            >
              {{ option.label }}
            </button>
          </div>

          <label>
            <span>{{ channelTargetLabel }}</span>
            <input
              v-model.trim="form.channelId"
              autocomplete="off"
              :placeholder="channelPlaceholder"
              :disabled="!isConnected"
            />
          </label>

          <button class="primary-button" type="submit" :disabled="!isConnected || !form.channelId">
            Open Channel
          </button>
        </form>

        <p v-if="currentUserId" class="meta-line">Signed in as {{ currentUserId }}</p>
        <p v-if="errorMessage" class="error-line">{{ errorMessage }}</p>
      </aside>

      <section class="chat-surface">
        <div id="nc-chat-modal-root"></div>
        <nc-chat-ui-app-provider v-if="chatUiReady" class="chat-provider" />
        <div v-else class="empty-state">
          <p>Connect with an App Key and server-issued Token to load ChatUI.</p>
        </div>
      </section>
    </section>
  </main>
</template>

<script setup>
import { computed, onBeforeUnmount, reactive, ref } from 'vue';
import {
  ConnectionStatusHandler,
  DirectChannelIdentifier,
  GroupChannelIdentifier,
  LogLevel,
  NCEngine,
} from '@nexconn/chat';
import { NCChatUIApplication } from '@nexconn/chatui';

const STORAGE_KEY = 'nexconn-chat-demo-app-key';
const STATUS_HANDLER_ID = 'vue-im-console';

const form = reactive({
  appKey: localStorage.getItem(STORAGE_KEY) || import.meta.env.VITE_NEXCONN_APP_KEY || '',
  token: import.meta.env.VITE_NEXCONN_TEST_TOKEN || '',
  channelType: 'direct',
  channelId: '',
});

const channelOptions = [
  { label: 'Direct', value: 'direct' },
  { label: 'Group', value: 'group' },
];

const isConnecting = ref(false);
const isConnected = ref(false);
const chatUiReady = ref(false);
const currentUserId = ref('');
const connectionStatus = ref('Idle');
const errorMessage = ref('');
let chatUiApp = null;
let initializedAppKey = '';

const connectionLabel = computed(() => {
  if (isConnecting.value) return 'Connecting';
  if (isConnected.value) return `Connected${connectionStatus.value ? ` · ${connectionStatus.value}` : ''}`;
  return connectionStatus.value;
});

const statusTone = computed(() => ({
  good: isConnected.value,
  busy: isConnecting.value,
}));

const channelTargetLabel = computed(() =>
  form.channelType === 'direct' ? 'Peer User ID' : 'Group ID',
);

const channelPlaceholder = computed(() =>
  form.channelType === 'direct' ? 'user-1002' : 'group-1001',
);

function createHooks() {
  return {
    async reqUserProfiles(userIds) {
      return userIds.map((userId) => ({
        userId,
        name: `User ${userId}`,
      }));
    },
    async reqGroupProfiles(groupIds) {
      return groupIds.map((groupId) => ({
        groupId,
        name: `Group ${groupId}`,
        memberCount: 0,
      }));
    },
    async reqSystemProfiles(systemIds) {
      return systemIds.map((targetId) => ({
        targetId,
        name: `System ${targetId}`,
      }));
    },
    async reqGroupMembers() {
      return currentUserId.value ? [{ userId: currentUserId.value, nickname: 'Me' }] : [];
    },
    getDefaultUserProfile(userId) {
      return {
        userId,
        name: `User ${userId}`,
      };
    },
    getDefaultGroupProfile(groupId) {
      return {
        groupId,
        name: `Group ${groupId}`,
        memberCount: 0,
      };
    },
    getDefaultSystemProfile(targetId) {
      return {
        targetId,
        name: `System ${targetId}`,
      };
    },
  };
}

function ensureInitialized() {
  if (chatUiApp && initializedAppKey === form.appKey) return;

  if (chatUiApp) {
    chatUiApp.destroy();
    chatUiApp = null;
    chatUiReady.value = false;
  }

  NCEngine.initialize({
    appKey: form.appKey,
    logLevel: LogLevel.DEBUG,
  });

  NCEngine.removeConnectionStatusHandler(STATUS_HANDLER_ID);
  NCEngine.addConnectionStatusHandler(
    STATUS_HANDLER_ID,
    new ConnectionStatusHandler({
      onConnectionStatusChanged({ status, code }) {
        connectionStatus.value = code ? `${status} (${code})` : String(status);
      },
    }),
  );

  chatUiApp = NCChatUIApplication.initialize({
    hooks: createHooks(),
    language: 'en_US',
    logLevel: LogLevel.DEBUG,
    modalContainerId: 'nc-chat-modal-root',
  });

  if (!chatUiApp) {
    throw new Error('ChatUI initialize failed');
  }

  chatUiApp.ready();
  initializedAppKey = form.appKey;
}

async function connect() {
  errorMessage.value = '';

  if (!form.appKey || !form.token) {
    errorMessage.value = 'App Key and Token are required.';
    return;
  }

  isConnecting.value = true;
  connectionStatus.value = 'Initializing';

  try {
    ensureInitialized();
    const result = await NCEngine.connect({ token: form.token });

    if (!result.isOk) {
      throw new Error(result.msg || `Connect failed with code ${result.code}`);
    }

    currentUserId.value = result.data?.userId || NCEngine.getCurrentUserId();
    localStorage.setItem(STORAGE_KEY, form.appKey);
    isConnected.value = true;
    chatUiReady.value = true;
    connectionStatus.value = 'Online';
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Connect failed.';
    isConnected.value = false;
    chatUiReady.value = false;
  } finally {
    isConnecting.value = false;
  }
}

async function disconnect() {
  errorMessage.value = '';

  try {
    await NCEngine.disconnect();
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Disconnect failed.';
  } finally {
    isConnected.value = false;
    chatUiReady.value = false;
    currentUserId.value = '';
    connectionStatus.value = 'Disconnected';
  }
}

async function openSelectedChannel() {
  if (!chatUiApp?.ifReady() || !form.channelId) return;

  errorMessage.value = '';

  try {
    const identifier =
      form.channelType === 'direct'
        ? new DirectChannelIdentifier(form.channelId)
        : new GroupChannelIdentifier(form.channelId);
    const result = await chatUiApp.openChannel(identifier, true);

    if (result && result.isOk === false) {
      throw new Error(result.msg || `Open channel failed with code ${result.code}`);
    }
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Open channel failed.';
  }
}

onBeforeUnmount(async () => {
  NCEngine.removeConnectionStatusHandler(STATUS_HANDLER_ID);

  if (chatUiApp) {
    chatUiApp.destroy();
    chatUiApp = null;
  }

  if (isConnected.value) {
    await NCEngine.disconnect();
  }
});

</script>

<style scoped>
* {
  box-sizing: border-box;
}

.app-shell {
  min-height: 100vh;
  background: #f4f1eb;
  color: #1e2428;
  font-family:
    Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.workspace {
  display: grid;
  grid-template-columns: minmax(280px, 340px) minmax(0, 1fr);
  min-height: 100vh;
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: 22px;
  padding: 28px;
  background: #182127;
  color: #f7f3ec;
  border-right: 1px solid rgba(30, 36, 40, 0.12);
}

.brand-block {
  display: grid;
  gap: 8px;
}

.eyebrow {
  margin: 0;
  color: #8fd0c8;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: 32px;
  line-height: 1.05;
  letter-spacing: 0;
}

.status {
  width: fit-content;
  max-width: 100%;
  margin: 6px 0 0;
  padding: 6px 10px;
  border: 1px solid rgba(247, 243, 236, 0.18);
  border-radius: 999px;
  color: #cfd7d4;
  font-size: 13px;
  overflow-wrap: anywhere;
}

.status.good {
  border-color: rgba(106, 196, 157, 0.45);
  color: #b5f0d1;
}

.status.busy {
  border-color: rgba(235, 180, 92, 0.45);
  color: #ffd696;
}

.connect-panel,
.open-panel {
  display: grid;
  gap: 14px;
  padding-top: 4px;
}

label {
  display: grid;
  gap: 7px;
  color: #dfe8e5;
  font-size: 13px;
  font-weight: 700;
}

input,
textarea {
  width: 100%;
  border: 1px solid rgba(247, 243, 236, 0.18);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.08);
  color: #ffffff;
  font: inherit;
  font-size: 14px;
  line-height: 1.35;
  outline: none;
  padding: 11px 12px;
  transition:
    border-color 150ms ease,
    background 150ms ease;
}

textarea {
  min-height: 96px;
  resize: vertical;
}

input::placeholder,
textarea::placeholder {
  color: rgba(247, 243, 236, 0.45);
}

input:focus,
textarea:focus {
  border-color: #8fd0c8;
  background: rgba(255, 255, 255, 0.12);
}

input:disabled,
textarea:disabled {
  cursor: not-allowed;
  opacity: 0.66;
}

button {
  min-height: 42px;
  border: 0;
  border-radius: 8px;
  cursor: pointer;
  font: inherit;
  font-size: 14px;
  font-weight: 800;
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.55;
}

.primary-button {
  background: #27b389;
  color: #06120f;
}

.primary-button:not(:disabled):hover {
  background: #38c89b;
}

.ghost-button {
  border: 1px solid rgba(247, 243, 236, 0.22);
  background: transparent;
  color: #f7f3ec;
}

.ghost-button:not(:disabled):hover {
  border-color: rgba(247, 243, 236, 0.42);
}

.segmented {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 4px;
  padding: 4px;
  border: 1px solid rgba(247, 243, 236, 0.16);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
}

.segmented button {
  min-height: 34px;
  background: transparent;
  color: #cfd7d4;
}

.segmented button.active {
  background: #f7f3ec;
  color: #182127;
}

.meta-line,
.error-line {
  margin: 0;
  font-size: 13px;
  line-height: 1.45;
  overflow-wrap: anywhere;
}

.meta-line {
  color: #b7c8c2;
}

.error-line {
  color: #ffb0a5;
}

.chat-surface {
  position: relative;
  min-width: 0;
  min-height: 100vh;
  background: #fffdfa;
}

.chat-provider {
  display: block;
  width: 100%;
  height: 100vh;
}

.empty-state {
  display: grid;
  min-height: 100vh;
  place-items: center;
  padding: 32px;
  color: #67716d;
  text-align: center;
}

.empty-state p {
  max-width: 360px;
  margin: 0;
  font-size: 16px;
  line-height: 1.5;
}

@media (max-width: 840px) {
  .workspace {
    grid-template-columns: 1fr;
  }

  .sidebar {
    min-height: auto;
  }

  .chat-surface,
  .empty-state {
    min-height: 68vh;
  }

  .chat-provider {
    height: 68vh;
  }
}

</style>
