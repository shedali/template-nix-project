// Simple vanilla JS with JSX-like syntax
let count = 0;

function createElement(tag: string, props?: any, ...children: any[]) {
  const element = document.createElement(tag);
  if (props) {
    Object.entries(props).forEach(([key, value]) => {
      if (key.startsWith('on')) {
        element.addEventListener(key.slice(2).toLowerCase(), value);
      } else {
        (element as any)[key] = value;
      }
    });
  }
  children.forEach((child) => {
    if (typeof child === 'string' || typeof child === 'number') {
      element.appendChild(document.createTextNode(child.toString()));
    } else if (child) {
      element.appendChild(child);
    }
  });
  return element;
}

function App() {
  return createElement(
    'div',
    null,
    createElement('h1', null, 'Hello from Bun + React!'),
    createElement('p', null, `Count: ${count}`),
    createElement(
      'button',
      {
        onClick: () => {
          count++;
          render();
        },
      },
      'Click me'
    )
  );
}

function render() {
  const root = document.getElementById('root')!;
  root.innerHTML = '';
  root.appendChild(App());
}

render();
