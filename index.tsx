import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>React + Bun + Nix</h1>
      <p>A modern React app built with Bun and deployed with Nix</p>
      <div style={{ marginTop: '2rem' }}>
        <button
          onClick={() => setCount(count + 1)}
          style={{
            padding: '0.5rem 1rem',
            fontSize: '1.2rem',
            borderRadius: '8px',
            border: '1px solid #ccc',
            cursor: 'pointer',
          }}
        >
          Count: {count}
        </button>
      </div>

      <div style={{ marginTop: '2rem', color: '#666' }}>
        <p>Built with:</p>
        <ul>
          <li>React {React.version}</li>
          <li>Bun bundler</li>
          <li>Nix flakes</li>
        </ul>
      </div>
    </div>
  );
}

// Mount the app
const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(<App />);
}
