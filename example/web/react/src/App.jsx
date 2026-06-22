import { useEffect, useState } from 'react';
import { NCEngine, LogLevel, DirectChannelIdentifier, ConnectionStatusHandler } from '@nexconn/chat';
import { NCChatUIApplication } from '@nexconn/chatui';

// ============================================================================
// PRODUCTION TODO（请在生产环境替换以下占位符 / mock 实现）：
//   1. appKey 改为通过 import.meta.env.VITE_NEXCONN_APP_KEY 等环境变量注入。
//   2. token 必须由你的后端服务调用 Nexconn Server API 签发，禁止把 App Secret 放到客户端。
//   3. 下方 ServiceHooks 中的 reqUserProfiles / reqGroupProfiles / reqGroupMembers / reqSystemProfiles
//      目前返回 mock 数据（含 memberCount: 0、空成员列表），需要换成真实数据源。
//   4. logLevel 当前为 Debug 便于集成验证；上线前请切换为 LogLevel.WARN 或 LogLevel.ERROR。
// ============================================================================

const appKey = import.meta.env?.VITE_NEXCONN_APP_KEY ?? 'YOUR_APP_KEY';

// 由后端 API 返回 Token；此处为 demo 占位，禁止把真实 Token 提交进仓库。
async function fetchTokenFromYourServer() {
  // 例：const res = await fetch('/api/nexconn/token'); return (await res.json()).token;
  return 'YOUR_TEST_TOKEN';
}

function App() {
  const [chatApp, setChatApp] = useState(null);
  const [isConnected, setIsConnected] = useState(false);
  const [currentUserId, setCurrentUserId] = useState('');
  const [targetUserId, setTargetUserId] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    initializeChatUI();

    return () => {
      if (chatApp) {
        chatApp.destroy();
      }
    };
  }, []);

  const initializeChatUI = async () => {
    try {
      // 1. Initialize Nexconn Chat Engine
      //    Debug log level helps integration verification; switch to WARN/ERROR for production.
      NCEngine.initialize({
        appKey,
        logLevel: LogLevel.Debug,
      });

      // 2. ServiceHooks - provide user / group / system channel profile data
      //    TODO(production): replace mock implementations with real data sources.
      const hooks = {
        async reqUserProfiles(userIds) {
          // TODO(production): fetch from your user profile service.
          return userIds.map((userId) => ({
            userId,
            name: `User ${userId}`,
            portraitUrl: `https://ui-avatars.com/api/?name=${userId}&background=random`,
          }));
        },
        async reqGroupProfiles(groupIds) {
          // TODO(production): fetch from your group service; do not hardcode memberCount.
          return groupIds.map((groupId) => ({
            groupId,
            name: `Group ${groupId}`,
            memberCount: 0, // TODO(production): replace with real count.
          }));
        },
        async reqGroupMembers(groupId) {
          // TODO(production): fetch real members; current mock returns empty list.
          return [];
        },
        async reqSystemProfiles(systemIds) {
          return systemIds.map((systemId) => ({
            systemId,
            name: `System ${systemId}`,
          }));
        },
      };

      // 3. Initialize ChatUI application (default English; override per project convention).
      const app = NCChatUIApplication.initialize({
        hooks,
        language: 'en_US',
      });

      if (!app) {
        throw new Error('ChatUI initialization failed');
      }

      // 4. Apply configuration and call ready()
      app.ready();
      setChatApp(app);

      // 5. Listen for connection status
      NCEngine.addConnectionStatusHandler(
        'demo',
        new ConnectionStatusHandler({
          onConnectionStatusChanged({ status, code }) {
            console.log('Connection status:', status, 'code:', code);
            setIsConnected(status === 'CONNECTED');
          },
        })
      );

      // 6. Connect to Nexconn Chat using a server-issued Token
      const token = await fetchTokenFromYourServer();
      const result = await NCEngine.connect({ token });
      if (result.isOk) {
        console.log('Connected, user id:', result.data.userId);
        setCurrentUserId(result.data.userId);
        setIsConnected(true);
      } else {
        const errorMsg = `Connect failed, code: ${result.code}`;
        console.error(errorMsg);
        setError(errorMsg);
      }
    } catch (err) {
      const errorMsg = `Initialization failed: ${err.message}`;
      console.error(errorMsg, err);
      setError(errorMsg);
    }
  };

  const handleOpenChat = async () => {
    if (!chatApp || !chatApp.ifReady()) {
      setError('ChatUI is not ready yet');
      return;
    }

    if (!targetUserId.trim()) {
      setError('Please enter the target user id');
      return;
    }

    try {
      await chatApp.openChannel(new DirectChannelIdentifier(targetUserId), true);
      setError('');
    } catch (err) {
      setError(`Open chat failed: ${err.message}`);
    }
  };

  return (
    <div style={{ width: '100vw', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Top control bar */}
      <div style={{
        padding: '16px',
        background: '#f5f5f5',
        borderBottom: '1px solid #ddd',
        display: 'flex',
        alignItems: 'center',
        gap: '12px'
      }}>
        <div style={{ flex: 1 }}>
          <strong>Nexconn Chat UI Demo - Direct Channel</strong>
          <div style={{ fontSize: '12px', color: '#666', marginTop: '4px' }}>
            {isConnected ? (
              <span style={{ color: '#52c41a' }}>✓ Connected (user id: {currentUserId})</span>
            ) : (
              <span style={{ color: '#999' }}>○ Not connected</span>
            )}
          </div>
        </div>

        <input
          type="text"
          placeholder="Target user id"
          value={targetUserId}
          onChange={(e) => setTargetUserId(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleOpenChat()}
          style={{
            padding: '8px 12px',
            border: '1px solid #d9d9d9',
            borderRadius: '4px',
            width: '200px'
          }}
        />

        <button
          onClick={handleOpenChat}
          disabled={!isConnected}
          style={{
            padding: '8px 16px',
            background: isConnected ? '#1890ff' : '#d9d9d9',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: isConnected ? 'pointer' : 'not-allowed'
          }}
        >
          Open chat
        </button>
      </div>

      {/* Error banner */}
      {error && (
        <div style={{
          padding: '12px 16px',
          background: '#fff2e8',
          borderBottom: '1px solid #ffbb96',
          color: '#d4380d'
        }}>
          {error}
        </div>
      )}

      {/* ChatUI container */}
      <div style={{ flex: 1, position: 'relative' }}>
        <nc-chat-ui-app-provider style={{
          width: '100%',
          height: '100%',
          display: 'block'
        }} />
      </div>
    </div>
  );
}

export default App;
