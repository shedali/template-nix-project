#!/usr/bin/env bun

console.log("Hello from Bun!");
console.log(`Bun version: ${Bun.version}`);

// Simple HTTP server example
const server = Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello World from Bun server!");
  },
});

console.log(`Server running at http://localhost:${server.port}`);