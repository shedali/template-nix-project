#!/usr/bin/env bun

// Example of how dependencies would work
// import { observable, action } from "mobx";

console.log('Hello from Bun!');
console.log(`Bun version: ${Bun.version}`);

// Example MobX usage (commented out since not installed)
// const store = observable({
//   count: 0,
//   increment: action(() => store.count++)
// });

console.log('Ready for MobX integration!');
