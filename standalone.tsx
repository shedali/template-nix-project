// Standalone React app that bundles everything
// This will be used for Nix builds

// Working React-like implementation with actual state management
let currentComponent: any = null;
let stateIndex = 0;
let states: any[] = [];

const React = {
  createElement(type: any, props: any, ...children: any[]) {
    return { type, props: { ...props, children } };
  },
  useState(initial: any) {
    const index = stateIndex++;
    if (states[index] === undefined) {
      states[index] = initial;
    }

    const setState = (newValue: any) => {
      states[index] =
        typeof newValue === 'function' ? newValue(states[index]) : newValue;
      rerender();
    };

    return [states[index], setState];
  },
};

function App() {
  const [count, setCount] = React.useState(0);

  return React.createElement(
    'div',
    {
      className: 'app',
      style: 'padding: 20px; font-family: system-ui, sans-serif;',
    },
    React.createElement('h1', { style: 'color: #333;' }, 'Bun + React + Nix'),
    React.createElement(
      'p',
      { style: 'font-size: 18px; margin: 20px 0;' },
      'Count: ',
      count
    ),
    React.createElement(
      'button',
      {
        onclick: () => {
          console.log('Button clicked! Current count:', count);
          setCount(count + 1);
        },
        style:
          'padding: 10px 20px; font-size: 16px; background: #0066cc; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 10px 0;',
      },
      'Increment'
    ),
    React.createElement(
      'button',
      {
        onclick: () => {
          console.log('Reset clicked!');
          setCount(0);
        },
        style:
          'padding: 10px 20px; font-size: 16px; background: #666; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 0 10px;',
      },
      'Reset'
    ),
    React.createElement(
      'p',
      { style: 'color: #666; font-style: italic;' },
      'This is a standalone build with working React state! 🎉'
    )
  );
}

// Simple DOM rendering
function render(element: any, container: HTMLElement) {
  if (typeof element === 'string' || typeof element === 'number') {
    container.appendChild(document.createTextNode(String(element)));
    return;
  }

  const domElement = document.createElement(element.type);

  if (element.props) {
    Object.keys(element.props).forEach((key) => {
      if (key === 'children') {
        const children = Array.isArray(element.props.children)
          ? element.props.children
          : [element.props.children];
        children.forEach((child: any) => {
          if (child) render(child, domElement);
        });
      } else if (key === 'className') {
        domElement.className = element.props[key];
      } else if (key.startsWith('on')) {
        const eventName = key.substring(2).toLowerCase();
        domElement.addEventListener(eventName, element.props[key]);
      } else {
        domElement.setAttribute(key, element.props[key]);
      }
    });
  }

  container.appendChild(domElement);
}

// Re-render function for state updates
function rerender() {
  const container = document.getElementById('root');
  if (container) {
    stateIndex = 0; // Reset state index for re-render
    container.innerHTML = ''; // Clear previous render
    render(App(), container);
  }
}

// Mount the app
if (typeof document !== 'undefined') {
  console.log('Script running in browser');
  const container = document.getElementById('root');
  console.log('Root container found:', container);
  if (container) {
    console.log('Rendering app...');
    try {
      render(App(), container);
      console.log('App rendered successfully!');
    } catch (error) {
      console.error('Error rendering app:', error);
      container.innerHTML = '<h1>Error rendering app - check console</h1>';
    }
  } else {
    console.error('No root element found!');
  }
} else {
  console.log('Not in browser environment');
}
