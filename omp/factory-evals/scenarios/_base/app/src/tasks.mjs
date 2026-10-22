import { readFileSync, writeFileSync, existsSync } from 'node:fs';

export function load(path) {
  return existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : [];
}

export function save(path, tasks) {
  writeFileSync(path, JSON.stringify(tasks, null, 2));
}

export function addTask(tasks, title) {
  if (!title.trim()) throw new Error('title required');
  return [...tasks, { id: tasks.length + 1, title, done: false }];
}

export function completeTask(tasks, id) {
  return tasks.map((t) => (t.id === id ? { ...t, done: true } : t));
}

export function deleteTask(tasks, id) {
  return tasks.filter((t) => t.id !== id);
}
