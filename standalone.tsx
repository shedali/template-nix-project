// Standalone React app that bundles everything
// This will be used for Nix builds

// Inline a minimal React-like implementation for the build
const React = {
  createElement(type: any, props: any, ...children: any[]) {
    return { type, props: { ...props, children } };
  },
  useState(initial: any) {
    console.log('useState called with:', initial);
    return [initial, () => {}];
  },
};

function App() {
  const [count, setCount] = React.useState(0);

  return React.createElement(
    'div',
    { className: 'app' },
    React.createElement('h1', null, 'Bun + React + Nix'),
    React.createElement('p', null, 'Count: ', count),
    React.createElement(
      'button',
      {
        onclick: () => console.log('Button clicked!'),
      },
      'Increment'
    ),
    React.createElement(
      'p',
      null,
      'This is a standalone build without external dependencies!'
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
