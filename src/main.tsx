import { useState } from 'react';
import { createRoot } from 'react-dom/client';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <h1>React Template</h1>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Click me</button>
      <p>Nix template</p>
      <ul>
        <li>security scanning</li>
        <li>dependabot</li>
        <li>cachix binary cache</li>
        <li>commit hooks</li>
      </ul>
    </div>
  );
}

const root = document.getElementById('root')!;
createRoot(root).render(<App />);
